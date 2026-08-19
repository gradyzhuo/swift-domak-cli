import ArgumentParser
import KurrentDB

struct ProjectionEnableSystemCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "enable-system",
        abstract: "Enable the built-in system projections ($by_category, $stream_by_category, $streams, $by_event_type) — for a fresh KurrentDB instance."
    )

    @OptionGroup var connection: KDBConnectionOptions

    private static let systemProjections: [NameTarget.Predefined] = [
        .byCategory, .streamByCategory, .streams, .byEventType,
    ]

    func run() async throws {
        let client = try connection.makeClient()
        print("啟用系統 projections...")

        var failures = 0
        for predefined in Self.systemProjections {
            Terminal.info("  → \(predefined.rawValue)")
            do {
                try await client.projections(system: predefined).enable()
                Terminal.success("    ✓ Enabled")
            } catch {
                Terminal.failure("    ✗ \(error)")
                failures += 1
            }
        }

        if failures > 0 {
            throw ExitCode.failure
        }
    }
}
