import ArgumentParser

struct ProjectionDisableCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "disable",
        abstract: "Disable projections (writes a checkpoint first)."
    )

    @Argument(help: "Projection names. Omit to disable every *Projection.js in the projections directory.")
    var names: [String] = []

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
            do {
                try await ProjectionOperations.disable(name: name, client: client)
            } catch {
                Terminal.failure("✗ \(name) 失敗: \(error)")
                failures += 1
            }
        }

        if failures > 0 {
            throw ExitCode.failure
        }
    }
}
