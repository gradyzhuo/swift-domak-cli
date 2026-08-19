# swift-pangu-cli

`pangu` (盤古) scaffolds a runnable [swift-ddd-kit](https://github.com/gradyzhuo/swift-ddd-kit)
starter project — an aggregate root, Create/Rename/Delete use cases, a read-side
projector, KurrentDB wiring, and aggregate-level unit tests — from nothing.

## Build

```bash
swift build -c release
```

The binary is at `.build/release/pangu`.

## Usage

```bash
pangu project create OrderContext
```

```
USAGE: pangu project create <name> [--aggregate <aggregate>] [--output <output>] [--kit-version <kit-version>] [--force]

ARGUMENTS:
  <name>                  The project name, e.g. OrderContext.

OPTIONS:
  --aggregate <aggregate> The aggregate root name, e.g. Order. Defaults to the
                          project name with a trailing 'Context' dropped.
  -o, --output <output>   Directory to create the project in. Defaults to
                          ./<ProjectName>.
  --kit-version <kit-version>
                          swift-ddd-kit version requirement for the generated
                          Package.swift. (default: 1.0.0)
  -f, --force             Overwrite the output directory if it already exists
                          and is non-empty.
```

Then:

```bash
cd OrderContext
swift build
# start KurrentDB locally, then:
swift run OrderContextApp
swift test
```

## License

MIT — see [LICENSE](LICENSE).
