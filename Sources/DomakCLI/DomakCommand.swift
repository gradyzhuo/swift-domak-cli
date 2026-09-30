import ArgumentParser

@main
struct DomakCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "domak",
        abstract: "Scaffolds and manages DDD/Event-Sourcing projects built on swift-ddd-kit.",
        subcommands: [
            CreateCommand.self,
        ]
    )
}
