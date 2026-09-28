import Foundation

enum TransferState: Equatable {
    case queued
    case copying
    case completed
    case failed(String)

    var localizationKey: String {
        switch self {
        case .queued: "transfer.queued"
        case .copying: "transfer.copying"
        case .completed: "transfer.completed"
        case .failed: "transfer.failed"
        }
    }
}

enum CollisionPolicy: String, CaseIterable, Identifiable, Sendable {
    case keepBoth
    case skip
    case replace

    var id: String { rawValue }

    var localizationKey: String {
        switch self {
        case .keepBoth: "transfer.conflictKeepBoth"
        case .skip: "transfer.conflictSkip"
        case .replace: "transfer.conflictReplace"
        }
    }
}

struct TransferOperation: Identifiable, Equatable {
    let id: UUID
    let sourceURLs: [URL]
    let destinationURL: URL
    let collisionPolicy: CollisionPolicy
    let totalBytes: Int64
    var state: TransferState
    let startedAt: Date

    init(sourceURLs: [URL], destinationURL: URL, collisionPolicy: CollisionPolicy, totalBytes: Int64) {
        id = UUID()
        self.sourceURLs = sourceURLs
        self.destinationURL = destinationURL
        self.collisionPolicy = collisionPolicy
        self.totalBytes = totalBytes
        state = .queued
        startedAt = Date()
    }
}
