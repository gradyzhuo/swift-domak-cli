import ArgumentParser

struct ProjectionRebuildCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "rebuild",
        abstract: "Rebuild: disable → delete → create from the local <name>Projection.js. Existing state/checkpoint is discarded; use `update` to keep it.",
        discussion: """
            If the projection doesn't exist yet, this just creates it — same \
            as `create`.
            """
    )

    @Argument(help: "Projection names. Omit to rebuild every *Projection.js in the projections directory.")
    var names: [String] = []

    @Flag(inversion: .prefixedNo, help: "Emit events from this projection to other streams.")
    var emit: Bool = true

    @Flag(inversion: .prefixedNo, help: "Track streams emitted by this projection (required to delete them later).")
    var trackEmittedStreams: Bool = true

    @OptionGroup var connection: KDBConnectionOptions

    func run() async throws {
        let targets = try ProjectionTargets.resolve(names: names, projectionsDir: connection.projectionsDir)
        guard !targets.isEmpty else {
            Terminal.warn("\(connection.projectionsDir.path) 內沒有任何 *Projection.js")
            return
        }

        let client = try connection.makeClient()
        var failures = 0

        for name in targets {
            Terminal.warn("處理 projection: \(name)")
            do {
                if try await ProjectionOperations.exists(name: name, client: client) {
                    Terminal.info("  ℹ Projection 已存在，將進行重建")
                    try await ProjectionOperations.disable(name: name, client: client)
                    try await ProjectionOperations.delete(name: name, client: client)
                } else {
                    Terminal.info("  ℹ Projection 不存在，直接建立")
                }
                let query = try ProjectionSource.resolve(
                    name: name, file: nil, edit: false, projectionsDir: connection.projectionsDir
                )
                try await ProjectionOperations.create(
                    name: name, query: query, emitEnabled: emit, trackEmittedStreams: trackEmittedStreams, client: client
                )
                Terminal.success("✓ \(name) 完成\n")
            } catch {
                Terminal.failure("✗ \(name) 失敗: \(error)\n")
                failures += 1
            }
        }

        if failures > 0 {
            throw ExitCode.failure
        }
    }
}
