import ArgumentParser

struct ProjectionUpdateCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update an existing projection's query in place — preserves its state and checkpoint (unlike `rebuild`).",
        discussion: """
            Content comes from --file, --edit (opens $EDITOR seeded with the \
            local <name>Projection.js), or the local file as-is, same as \
            `create`. The result is written back to <name>Projection.js.

            Note: KurrentDB's update call always sets emit explicitly (no \
            "leave unchanged" option) — pass --no-emit if this projection \
            shouldn't emit.
            """
    )

    @Argument(help: "Projection names. Omit to update every local *Projection.js that exists on the server.")
    var names: [String] = []

    @Option(help: "Read the query from this file instead of the local convention. Only valid with a single name.")
    var file: String?

    @Flag(help: "Open $EDITOR to author the query inline. Only valid with a single name.")
    var edit: Bool = false

    @Flag(inversion: .prefixedNo, help: "Emit events from this projection to other streams.")
    var emit: Bool = true

    @OptionGroup var connection: KDBConnectionOptions

    func run() async throws {
        let targets = try ProjectionTargets.resolve(
            names: names,
            projectionsDir: connection.projectionsDir,
            requireExistingFile: false
        )
        guard !targets.isEmpty else {
            Terminal.warn("沒有要更新的 projection")
            return
        }
        if targets.count > 1, file != nil || edit {
            throw ValidationError("--file / --edit 只能搭配單一 projection 名稱使用")
        }

        let client = try connection.makeClient()

        for name in targets {
            Terminal.warn("處理 projection: \(name)")
            guard try await ProjectionOperations.exists(name: name, client: client) else {
                Terminal.failure("  ✗ 不存在，請先用 create\n")
                continue
            }
            let query = try ProjectionSource.resolve(
                name: name, file: file, edit: edit, projectionsDir: connection.projectionsDir
            )
            try await ProjectionOperations.update(name: name, query: query, emitEnabled: emit, client: client)
            Terminal.success("✓ \(name) 完成\n")
        }
    }
}
