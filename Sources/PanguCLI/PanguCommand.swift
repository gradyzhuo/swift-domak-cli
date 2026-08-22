import ArgumentParser

@main
struct PanguCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "pangu",
        abstract: "盤古 — scaffolds and manages DDD/Event-Sourcing projects built on swift-ddd-kit.",
        subcommands: [
            CreateCommand.self,
        ]
    )
}
