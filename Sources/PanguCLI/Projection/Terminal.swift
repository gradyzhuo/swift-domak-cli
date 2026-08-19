/// ANSI color helpers matching the team's original `projection.sh` output style.
enum Terminal {
    private static let green = "\u{1B}[0;32m"
    private static let red = "\u{1B}[0;31m"
    private static let yellow = "\u{1B}[1;33m"
    private static let blue = "\u{1B}[0;34m"
    private static let reset = "\u{1B}[0m"

    static func success(_ message: String) {
        print("\(green)\(message)\(reset)")
    }

    static func failure(_ message: String) {
        print("\(red)\(message)\(reset)")
    }

    static func warn(_ message: String) {
        print("\(yellow)\(message)\(reset)")
    }

    static func info(_ message: String) {
        print("\(blue)\(message)\(reset)")
    }
}
