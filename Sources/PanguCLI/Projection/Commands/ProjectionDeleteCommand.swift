import ArgumentParser

struct ProjectionDeleteCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Disable and delete projections, including their state/checkpoint/emitted streams."
    )

    @Argument(help: "Projection names. Omit to delete every *Projection.js in the projections directory.")
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
            Terminal.warn("處理 projection: \(name)")
            do {
                guard try await ProjectionOperations.exists(name: name, client: client) else {
                    Terminal.warn("  ⚠ 不存在，跳過\n")
                    continue
                }
                try await ProjectionOperations.disable(name: name, client: client)
                try await ProjectionOperations.delete(name: name, client: client)
                Terminal.success("✓ \(name) 已刪除\n")
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
