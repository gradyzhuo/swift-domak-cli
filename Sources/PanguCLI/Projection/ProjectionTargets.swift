import ArgumentParser
import Foundation

/// Resolves the projection names a command should act on, and locates their
/// `<name>Projection.js` files under the configured projections directory.
///
/// Mirrors `projection.sh`'s `resolve_targets`: no names given means "every
/// `*Projection.js` file in the directory"; names given are normalized by
/// stripping an optional `Projection.js` / `Projection` suffix.
enum ProjectionTargets {
    /// - Parameter requireExistingFile: When true (the default, matching
    ///   `projection.sh`), an explicitly named target must already have a
    ///   local `<name>Projection.js` file. `create`/`update` relax this via
    ///   `false` since their content can come from `--file` or `--edit`.
    static func resolve(
        names: [String],
        projectionsDir: URL,
        requireExistingFile: Bool = true
    ) throws -> [String] {
        if names.isEmpty {
            let fileManager = FileManager.default
            guard fileManager.fileExists(atPath: projectionsDir.path) else {
                return []
            }
            let files = try fileManager.contentsOfDirectory(atPath: projectionsDir.path)
                .filter { $0.hasSuffix("Projection.js") }
                .sorted()
            return files.map { String($0.dropLast("Projection.js".count)) }
        }

        return try names.map { rawName in
            let name = normalize(rawName)
            if requireExistingFile {
                let file = projectionFile(name: name, in: projectionsDir)
                guard FileManager.default.fileExists(atPath: file.path) else {
                    throw ValidationError("找不到 projection: \(name) (\(file.path))")
                }
            }
            return name
        }
    }

    static func normalize(_ rawName: String) -> String {
        var name = rawName
        if name.hasSuffix("Projection.js") {
            name = String(name.dropLast("Projection.js".count))
        } else if name.hasSuffix("Projection") {
            name = String(name.dropLast("Projection".count))
        }
        return name
    }

    static func projectionFile(name: String, in projectionsDir: URL) -> URL {
        projectionsDir.appendingPathComponent("\(name)Projection.js")
    }
}
