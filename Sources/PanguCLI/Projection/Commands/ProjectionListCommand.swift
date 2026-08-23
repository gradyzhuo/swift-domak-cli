import ArgumentParser
import KurrentDB

struct ProjectionListCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List every projection on the server (user-defined and system)."
    )

    @OptionGroup var connection: KDBConnectionOptions

    func run() async throws {
        let client = try connection.makeClient()
        print("KDB 上所有 projections:")
        let details = try await client.projections(of: .anyMode).list()
        for detail in details {
            print("  \(detail.name)\t\(detail.status.rawValue)")
        }
    }
}
