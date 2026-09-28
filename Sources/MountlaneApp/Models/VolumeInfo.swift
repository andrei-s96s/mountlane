import Foundation

struct VolumeInfo: Identifiable, Hashable {
    let id: String
    let url: URL
    let name: String
    let fileSystem: String
    let isReadOnly: Bool
    let isRemovable: Bool
    let isEjectable: Bool
    let totalCapacity: Int64?
    let availableCapacity: Int64?

    var accessModeKey: String { isReadOnly ? "access.readOnly" : "access.readWrite" }
    var isNTFS: Bool { fileSystem.localizedCaseInsensitiveContains("ntfs") }
    var usedFraction: Double? {
        guard let totalCapacity, let availableCapacity, totalCapacity > 0 else { return nil }
        return 1 - (Double(availableCapacity) / Double(totalCapacity))
    }
}

enum NTFSProviderStatus: Equatable {
    case notInstalled
    case detected(path: String)

    var isDetected: Bool {
        executablePath != nil
    }

    var executablePath: String? {
        if case let .detected(path) = self { return path }
        return nil
    }

    static func detect(fileManager: FileManager = .default) -> NTFSProviderStatus {
        let candidates = [
            "/opt/homebrew/bin/ntfs-3g",
            "/usr/local/bin/ntfs-3g",
            "/opt/homebrew/sbin/mount.ntfs-3g",
            "/usr/local/sbin/mount.ntfs-3g"
        ]
        if let path = candidates.first(where: fileManager.isExecutableFile(atPath:)) {
            return .detected(path: path)
        }
        return .notInstalled
    }
}

struct NTFSRuntimeStatus: Equatable {
    let provider: NTFSProviderStatus
    let isFuseTInstalled: Bool

    static func detect(fileManager: FileManager = .default) -> NTFSRuntimeStatus {
        NTFSRuntimeStatus(
            provider: .detect(fileManager: fileManager),
            isFuseTInstalled: fileManager.fileExists(atPath: "/Library/Application Support/fuse-t")
                || fileManager.fileExists(atPath: "/Library/Frameworks/fuse-t.framework")
        )
    }
}

struct FileItem: Identifiable, Hashable {
    let url: URL
    let name: String
    let isDirectory: Bool
    let size: Int64?
    let modificationDate: Date?

    var id: URL { url }
}

enum FileSortOrder: String, CaseIterable, Identifiable {
    case name
    case modificationDate
    case size

    var id: String { rawValue }

    func sorted(_ items: [FileItem]) -> [FileItem] {
        items.sorted { lhs, rhs in
            if lhs.isDirectory != rhs.isDirectory { return lhs.isDirectory }
            switch self {
            case .name:
                return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
            case .modificationDate:
                return (lhs.modificationDate ?? .distantPast) > (rhs.modificationDate ?? .distantPast)
            case .size:
                return (lhs.size ?? 0) > (rhs.size ?? 0)
            }
        }
    }
}
