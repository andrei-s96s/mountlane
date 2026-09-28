import Foundation

private enum CopyResult: Sendable {
    case completed
    case failed(String)
}

@MainActor
final class TransferStore: ObservableObject {
    @Published private(set) var operations: [TransferOperation] = []

    func copy(_ sourceURLs: [URL], to destinationURL: URL) {
        guard !sourceURLs.isEmpty else { return }
        var operation = TransferOperation(sourceURLs: sourceURLs, destinationURL: destinationURL)
        operations.insert(operation, at: 0)
        let operationID = operation.id

        Task {
            update(operationID, state: .copying)
            let result: CopyResult = await Task.detached(priority: .userInitiated) {
                do {
                    try CopyEngine.copy(sourceURLs, to: destinationURL)
                    return .completed
                } catch {
                    return .failed(error.localizedDescription)
                }
            }.value
            switch result {
            case .completed: update(operationID, state: .completed)
            case let .failed(message): update(operationID, state: .failed(message))
            }
        }
    }

    func clearFinished() {
        operations.removeAll {
            if case .copying = $0.state { return false }
            if case .queued = $0.state { return false }
            return true
        }
    }

    private func update(_ id: UUID, state: TransferState) {
        guard let index = operations.firstIndex(where: { $0.id == id }) else { return }
        operations[index].state = state
    }
}

enum CopyEngine {
    static func copy(_ sources: [URL], to destination: URL, fileManager: FileManager = .default) throws {
        for source in sources {
            let target = availableDestination(for: source, in: destination, fileManager: fileManager)
            try fileManager.copyItem(at: source, to: target)
        }
    }

    static func availableDestination(for source: URL, in directory: URL, fileManager: FileManager = .default) -> URL {
        let originalName = source.lastPathComponent
        var candidate = directory.appendingPathComponent(originalName)
        var index = 2
        while fileManager.fileExists(atPath: candidate.path) {
            let base = source.deletingPathExtension().lastPathComponent
            let extensionName = source.pathExtension
            let name = extensionName.isEmpty ? "\(base) \(index)" : "\(base) \(index).\(extensionName)"
            candidate = directory.appendingPathComponent(name)
            index += 1
        }
        return candidate
    }
}
