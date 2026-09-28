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
