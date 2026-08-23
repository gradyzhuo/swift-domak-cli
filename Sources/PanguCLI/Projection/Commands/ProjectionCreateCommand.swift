import ArgumentParser

struct ProjectionCreateCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create projections that don't exist yet on the server. Existing ones are skipped (use `rebuild` to recreate).",
        discussion: """
            Content for each projection comes from, in order: --file, --edit \
            (opens $EDITOR seeded with the current local file, or a blank \
            template for a brand-new one), or the local <name>Projection.js \
            as-is. Whichever is used, the result is written back to \
            <name>Projection.js.
            """
    )

    @Argument(help: "Projection names. Omit to create every *Projection.js not yet on the server.")
    var names: [String] = []

    @Option(help: "Read the query from this file instead of the local convention. Only valid with a single name.")
    var file: String?

    @Flag(help: "Open $EDITOR to author the query inline. Only valid with a single name.")
    var edit: Bool = false

    @Flag(inversion: .prefixedNo, help: "Emit events from this projection to other streams.")
    var emit: Bool = true

    @Flag(inversion: .prefixedNo, help: "Track streams emitted by this projection (required to delete them later).")
    var trackEmittedStreams: Bool = true

    @OptionGroup var connection: KDBConnectionOptions

    func run() async throws {
        let targets = try ProjectionTargets.resolve(
            names: names,
            projectionsDir: connection.projectionsDir,
            requireExistingFile: false
        )
        guard !targets.isEmpty else {
            Terminal.warn("沒有要建立的 projection")
            return
        }
        if targets.count > 1, file != nil || edit {
            throw ValidationError("--file / --edit 只能搭配單一 projection 名稱使用")
        }

        let client = try connection.makeClient()

        for name in targets {
            Terminal.warn("處理 projection: \(name)")
            if try await ProjectionOperations.exists(name: name, client: client) {
                Terminal.warn("  ⚠ 已存在，跳過（要重建請用 rebuild）\n")
                continue
            }
            let query = try ProjectionSource.resolve(
                name: name, file: file, edit: edit, projectionsDir: connection.projectionsDir
            )
            try await ProjectionOperations.create(
                name: name, query: query, emitEnabled: emit, trackEmittedStreams: trackEmittedStreams, client: client
            )
            Terminal.success("✓ \(name) 完成\n")
        }
    }
}
