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

struct TransferOperation: Identifiable, Equatable {
    let id: UUID
    let sourceURLs: [URL]
    let destinationURL: URL
    var state: TransferState
    let startedAt: Date

    init(sourceURLs: [URL], destinationURL: URL) {
        id = UUID()
        self.sourceURLs = sourceURLs
        self.destinationURL = destinationURL
        state = .queued
        startedAt = Date()
    }
}
