import Foundation

enum NTFSRemountError: LocalizedError {
    case deviceNotFound
    case unsafeDeviceIdentifier
    case commandFailed(String)

    var errorDescription: String? {
        switch self {
        case .deviceNotFound: L10n.text("ntfs.deviceNotFound")
        case .unsafeDeviceIdentifier: L10n.text("ntfs.deviceNotFound")
        case let .commandFailed(message): message
        }
    }
}

struct NTFSRemountPlan: Equatable {
    let deviceIdentifier: String
    let providerPath: String

    var mountPoint: String { "/Volumes/Mountlane-\(deviceIdentifier)" }

    var shellCommand: String {
        let device = "/dev/\(deviceIdentifier)"
        return "/usr/sbin/diskutil unmount \(ShellEscape.value(device)) && "
            + "/bin/mkdir -p \(ShellEscape.value(mountPoint)) && "
            + "\(ShellEscape.value(providerPath)) \(ShellEscape.value(device)) \(ShellEscape.value(mountPoint)) "
            + "-o local -o auto_xattr -o auto_cache"
    }

    static func make(deviceIdentifier: String, providerPath: String) throws -> NTFSRemountPlan {
        guard deviceIdentifier.range(of: "^disk[0-9]+(s[0-9]+)?$", options: .regularExpression) != nil else {
            throw NTFSRemountError.unsafeDeviceIdentifier
        }
        return NTFSRemountPlan(deviceIdentifier: deviceIdentifier, providerPath: providerPath)
    }
}

enum NTFSRemounter {
    static func remount(volumeURL: URL, providerPath: String) throws {
        let deviceIdentifier = try deviceIdentifier(for: volumeURL)
        let plan = try NTFSRemountPlan.make(deviceIdentifier: deviceIdentifier, providerPath: providerPath)
        try runPrivileged(command: plan.shellCommand)
    }

    private static func deviceIdentifier(for volumeURL: URL) throws -> String {
        let output = try run(executable: "/usr/sbin/diskutil", arguments: ["info", "-plist", volumeURL.path])
        guard let plist = try PropertyListSerialization.propertyList(from: output, format: nil) as? [String: Any],
              let identifier = plist["DeviceIdentifier"] as? String else {
            throw NTFSRemountError.deviceNotFound
        }
        return identifier
    }

    private static func runPrivileged(command: String) throws {
        let escaped = command
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        let script = "do shell script \"\(escaped)\" with administrator privileges"
        _ = try run(executable: "/usr/bin/osascript", arguments: ["-e", script])
    }

    private static func run(executable: String, arguments: [String]) throws -> Data {
        let process = Process()
        let output = Pipe()
        let errors = Pipe()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.standardOutput = output
        process.standardError = errors
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            let errorData = errors.fileHandleForReading.readDataToEndOfFile()
            let message = String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            throw NTFSRemountError.commandFailed(message?.isEmpty == false ? message! : L10n.text("ntfs.remountFailed"))
        }
        return output.fileHandleForReading.readDataToEndOfFile()
    }
}

private enum ShellEscape {
    static func value(_ value: String) -> String {
        "'\(value.replacingOccurrences(of: "'", with: "'\\\"'\\\"'"))'"
    }
}
