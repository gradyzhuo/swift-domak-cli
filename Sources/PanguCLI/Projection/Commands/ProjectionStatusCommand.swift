import ArgumentParser
import KurrentDB

struct ProjectionStatusCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "status",
        abstract: "Show status and progress for this project's projections."
    )

    @Argument(help: "Projection names. Omit to show every *Projection.js in the projections directory.")
    var names: [String] = []

    @OptionGroup var connection: KDBConnectionOptions

    func run() async throws {
        let targets = try ProjectionTargets.resolve(names: names, projectionsDir: connection.projectionsDir)
        guard !targets.isEmpty else {
            Terminal.warn("\(connection.projectionsDir.path) 內沒有任何 *Projection.js")
            return
        }

        let client = try connection.makeClient()

        for name in targets {
            do {
                guard let detail = try await client.projections(name: name).detail() else {
                    Terminal.warn("  \(name)\t(不存在)")
                    continue
                }
                print("  \(detail.name)\t\(detail.status.rawValue)\tprogress: \(detail.progress)%")
            } catch KurrentError.resourceNotFound {
                Terminal.warn("  \(name)\t(不存在)")
            }
        }
    }
}
