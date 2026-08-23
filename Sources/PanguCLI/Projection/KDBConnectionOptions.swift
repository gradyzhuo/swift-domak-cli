import ArgumentParser
import Foundation
import KurrentDB

/// Shared connection flags for every `pangu projection` subcommand.
///
/// Two ways to point at a KurrentDB instance, both supported side by side:
///   1. `--connection-string` (or `KDB_URL` / `SWIFT_KURRENT_DB_URL` env) — an
///      `esdb://user:pass@host:port?tls=false` URI, matching swift-kurrentdb's
///      own convention.
///   2. Discrete `--host`/`--port`/`--user`/`--password` (or `KDB_HOST`/`KDB_PORT`/
///      `KDB_USER`/`KDB_PASS` env), matching the team's existing `projection.sh`.
///
/// `--connection-string` wins if both are given. Defaults (`localhost:2113`,
/// `admin`/`changeit`, no TLS) match `projection.sh`.
struct KDBConnectionOptions: ParsableArguments {
    @Option(name: .customLong("connection-string"), help: "esdb:// connection string. Overrides --host/--port/--user/--password and KDB_HOST/etc.")
    var connectionString: String?

    @Option(name: .customLong("host"), help: "KurrentDB host. (env: KDB_HOST, default: localhost)")
    var host: String?

    @Option(name: .customLong("port"), help: "KurrentDB port. (env: KDB_PORT, default: 2113)")
    var port: UInt32?

    @Option(name: .customLong("user"), help: "KurrentDB username. (env: KDB_USER, default: admin)")
    var user: String?

    @Option(name: .customLong("password"), help: "KurrentDB password. (env: KDB_PASS, default: changeit)")
    var password: String?

    @Flag(name: .customLong("tls"), help: "Use TLS when connecting via --host/--port. No effect with --connection-string (put tls=true there instead).")
    var tls: Bool = false

    @Option(name: .customLong("projections-dir"), help: "Directory of *Projection.js files. Default: ./projections")
    var projectionsDirPath: String?

    var projectionsDir: URL {
        URL(fileURLWithPath: projectionsDirPath ?? "projections", isDirectory: true)
    }

    func makeClient() throws -> KurrentDBClient {
        let env = ProcessInfo.processInfo.environment

        if let connectionString = connectionString ?? env["KDB_URL"] ?? env["SWIFT_KURRENT_DB_URL"] {
            let settings = try ClientSettings.parse(connectionString: connectionString)
            return KurrentDBClient(settings: settings)
        }

        let host = host ?? env["KDB_HOST"] ?? "localhost"
        let port = port ?? env["KDB_PORT"].flatMap(UInt32.init) ?? DEFAULT_PORT_NUMBER
        let user = user ?? env["KDB_USER"] ?? "admin"
        let password = password ?? env["KDB_PASS"] ?? "changeit"

        let settings = ClientSettings
            .remote(Endpoint(host: host, port: port), secure: tls)
            .authenticated(.credentials(username: user, password: password))
        return KurrentDBClient(settings: settings)
    }
}
