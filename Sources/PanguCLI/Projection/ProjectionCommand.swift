import ArgumentParser

struct ProjectionCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "projection",
        abstract: "Manage KurrentDB continuous JS projections (projections/*.js).",
        subcommands: [
            ProjectionCreateCommand.self,
            ProjectionUpdateCommand.self,
            ProjectionRebuildCommand.self,
            ProjectionDeleteCommand.self,
            ProjectionEnableCommand.self,
            ProjectionDisableCommand.self,
            ProjectionStatusCommand.self,
            ProjectionListCommand.self,
            ProjectionEnableSystemCommand.self,
        ]
    )
}
