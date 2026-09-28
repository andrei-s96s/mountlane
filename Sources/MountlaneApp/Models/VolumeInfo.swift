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
    var usedFraction: Double? {
        guard let totalCapacity, let availableCapacity, totalCapacity > 0 else { return nil }
        return 1 - (Double(availableCapacity) / Double(totalCapacity))
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
