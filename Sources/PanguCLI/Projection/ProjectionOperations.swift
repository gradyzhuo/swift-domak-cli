import Foundation
import KurrentDB

/// Shared, per-target operations used by the `pangu projection` subcommands.
/// Mirrors `projection.sh`'s helpers (`check_projection_exists`, `enable_projection`,
/// `disable_projection`, `delete_projection`, `create_projection_api`) but on top of
/// swift-kurrentdb's native gRPC client instead of curl + jq.
enum ProjectionOperations {
    static func exists(name: String, client: KurrentDBClient) async throws -> Bool {
        do {
            return try await client.projections(name: name).detail() != nil
        } catch KurrentError.resourceNotFound {
            return false
        }
    }

    static func enable(name: String, client: KurrentDBClient) async throws {
        Terminal.info("  → Enabling \(name)")
        try await client.projections(name: name).enable()
        Terminal.success("  ✓ Enabled")
    }

    /// Disables and waits for KurrentDB's async checkpoint write, matching
    /// `projection.sh`'s fixed 2s `STEP_WAIT` after disable. Tolerates the
    /// projection already being gone (logs and continues, like the bash
    /// script's non-fatal disable failure).
    static func disable(name: String, client: KurrentDBClient) async throws {
        Terminal.info("  → Disabling \(name)")
        do {
            try await client.projections(name: name).disable()
            Terminal.success("  ✓ Disabled")
        } catch KurrentError.resourceNotFound {
            Terminal.warn("  ⚠ Projection 不存在，略過 disable")
        }
        try await Task.sleep(for: .seconds(2))
    }

    /// Deletes state/checkpoint/emitted streams along with the projection.
    /// Tolerates the projection already being gone.
    static func delete(name: String, client: KurrentDBClient) async throws {
        Terminal.info("  → Deleting \(name)")
        do {
            try await client.projections(name: name).delete {
                $0.deleteStateStream = true
                $0.deleteCheckpointStream = true
                $0.deleteEmittedStreams = true
            }
            Terminal.success("  ✓ Deleted")
        } catch KurrentError.resourceNotFound {
            Terminal.warn("  ⚠ Projection 不存在，略過 delete")
        }
        try await Task.sleep(for: .seconds(2))
    }

    /// Creates a continuous projection, retrying on `.resourceAlreadyExists` —
    /// KurrentDB's delete is asynchronous, so a create immediately following a
    /// delete can otherwise race the server's own cleanup (same rationale as
    /// `projection.sh`'s `create_projection_api` 409 retry loop).
    static func create(
        name: String,
        query: String,
        emitEnabled: Bool,
        trackEmittedStreams: Bool,
        client: KurrentDBClient,
        maxAttempts: Int = 10,
        retryWait: Duration = .seconds(2)
    ) async throws {
        Terminal.info("  → Creating \(name)")
        var attempt = 1
        while true {
            do {
                try await client.projections(of: .continuous(name: name)).create(query: query) {
                    $0.emitEnabled = emitEnabled
                    $0.trackEmittedStreams = trackEmittedStreams
                }
                Terminal.success("  ✓ Created")
                return
            } catch KurrentError.resourceAlreadyExists where attempt < maxAttempts {
                Terminal.warn("  ⚠ Duplicate（async delete 未清完），等待 \(retryWait) 後重試 (\(attempt)/\(maxAttempts))")
                try await Task.sleep(for: retryWait)
                attempt += 1
            }
        }
    }

    static func update(
        name: String,
        query: String,
        emitEnabled: Bool,
        client: KurrentDBClient
    ) async throws {
        Terminal.info("  → Updating \(name)")
        try await client.projections(name: name).update(query: query) {
            $0.emitOption = emitEnabled ? .enable(true) : .noEmit
        }
        Terminal.success("  ✓ Updated")
    }
}
