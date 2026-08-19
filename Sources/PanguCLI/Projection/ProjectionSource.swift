import ArgumentParser
import Foundation

/// Resolves the JS query content for `create`/`update`, and keeps the local
/// `<name>Projection.js` file in sync with whatever was actually pushed.
enum ProjectionSource {
    static func createTemplate(name: String) -> String {
        """
        // \(name)Projection.js — continuous JS projection.
        fromAll()
            .when({
                $init() {
                    return {};
                },
                $any(state, event) {
                    return state;
                }
            })
            .outputState();
        """
    }

    /// - Parameters:
    ///   - file: `--file <path>` override — read directly from this path.
    ///   - edit: `--edit` — open `$EDITOR` seeded with the local file's
    ///     current content (or a blank template for a brand-new projection).
    ///   Neither given: read the local `<name>Projection.js` as-is.
    ///
    ///   Whichever path is used, the result is written back to
    ///   `<name>Projection.js` so the projections directory stays the source
    ///   of truth for `rebuild` / bulk operations.
    static func resolve(
        name: String,
        file: String?,
        edit: Bool,
        projectionsDir: URL
    ) throws -> String {
        let localFile = ProjectionTargets.projectionFile(name: name, in: projectionsDir)

        let content: String
        if let file {
            content = try String(contentsOfFile: file, encoding: .utf8)
        } else if edit {
            let seed = (try? String(contentsOf: localFile, encoding: .utf8))
                ?? createTemplate(name: name)
            content = try ProjectionEditor.edit(seed: seed)
        } else if let existing = try? String(contentsOf: localFile, encoding: .utf8) {
            content = existing
        } else {
            throw ValidationError(
                "\(name) 沒有對應的 \(localFile.lastPathComponent)，請用 --edit 現場編輯或 --file 指定內容來源。"
            )
        }

        try FileManager.default.createDirectory(
            at: projectionsDir, withIntermediateDirectories: true
        )
        try content.write(to: localFile, atomically: true, encoding: .utf8)
        return content
    }
}
