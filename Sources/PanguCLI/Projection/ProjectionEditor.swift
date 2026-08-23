import Foundation

/// Opens `$EDITOR` (falling back to `vi`) on a seeded temp file and returns
/// what the user saved, for `--edit` mode on `create`/`update`.
enum ProjectionEditor {
    struct Cancelled: Error, CustomStringConvertible {
        var description: String { "編輯已取消（內容為空）" }
    }

    static func edit(seed: String) throws -> String {
        let editor = ProcessInfo.processInfo.environment["EDITOR"] ?? "vi"

        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("pangu-projection-\(UUID().uuidString).js")
        try seed.write(to: tempFile, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: tempFile) }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", "\(editor) \"\(tempFile.path)\""]
        process.standardInput = FileHandle.standardInput
        process.standardOutput = FileHandle.standardOutput
        process.standardError = FileHandle.standardError

        try process.run()
        process.waitUntilExit()

        let content = try String(contentsOf: tempFile, encoding: .utf8)
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw Cancelled()
        }
        return content
    }
}
