import Foundation
import UserNotifications

private enum CopyResult: Sendable {
    case completed
    case failed(String)
}

@MainActor
final class TransferStore: ObservableObject {
    @Published private(set) var operations: [TransferOperation] = []
    @Published private(set) var history: [TransferHistoryEntry]

    init() {
        history = Self.loadHistory()
    }

    func copy(_ sourceURLs: [URL], to destinationURL: URL, collisionPolicy: CollisionPolicy) throws {
        guard !sourceURLs.isEmpty else { return }
        let totalBytes = try CopyEngine.totalSize(of: sourceURLs)
        let available = try destinationURL.resourceValues(forKeys: [.volumeAvailableCapacityKey]).volumeAvailableCapacity
        guard available == nil || totalBytes <= Int64(available!) else { throw CopyEngineError.insufficientSpace }
        let operation = TransferOperation(sourceURLs: sourceURLs, destinationURL: destinationURL, collisionPolicy: collisionPolicy, totalBytes: totalBytes)
        operations.insert(operation, at: 0)
        let operationID = operation.id

        Task {
            update(operationID, state: .copying)
            let result: CopyResult = await Task.detached(priority: .userInitiated) {
                do {
                    try CopyEngine.copy(sourceURLs, to: destinationURL, collisionPolicy: collisionPolicy)
                    return .completed
                } catch {
                    return .failed(error.localizedDescription)
                }
            }.value
            switch result {
            case .completed:
                update(operationID, state: .completed)
                finish(operation, succeeded: true)
            case let .failed(message):
                update(operationID, state: .failed(message))
                finish(operation, succeeded: false)
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

    func clearHistory() {
        history = []
        saveHistory()
    }

    private func update(_ id: UUID, state: TransferState) {
        guard let index = operations.firstIndex(where: { $0.id == id }) else { return }
        operations[index].state = state
    }

    private func finish(_ operation: TransferOperation, succeeded: Bool) {
        history.insert(TransferHistoryEntry(id: operation.id, itemCount: operation.sourceURLs.count, destinationName: operation.destinationURL.lastPathComponent, totalBytes: operation.totalBytes, succeeded: succeeded, completedAt: Date()), at: 0)
        history = Array(history.prefix(100))
        saveHistory()
        TransferNotifier.post(itemCount: operation.sourceURLs.count, succeeded: succeeded)
    }

    private func saveHistory() {
        UserDefaults.standard.set(try? JSONEncoder().encode(history), forKey: "transferHistory")
    }

    private static func loadHistory() -> [TransferHistoryEntry] {
        guard let data = UserDefaults.standard.data(forKey: "transferHistory") else { return [] }
        return (try? JSONDecoder().decode([TransferHistoryEntry].self, from: data)) ?? []
    }
}

enum TransferNotifier {
    static func post(itemCount: Int, succeeded: Bool) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = L10n.text(succeeded ? "transfer.notificationDone" : "transfer.notificationFailed")
            content.body = L10n.text("transfer.notificationBody", Int64(itemCount))
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            center.add(request)
        }
    }
}

enum CopyEngine {
    static func totalSize(of sources: [URL], fileManager: FileManager = .default) throws -> Int64 {
        try sources.reduce(0) { total, url in
            let values = try url.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey])
            if values.isDirectory == true {
                let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey], options: [.skipsHiddenFiles])
                let nested = try (enumerator?.allObjects as? [URL] ?? []).reduce(Int64(0)) { partial, child in
                    partial + Int64(try child.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0)
                }
                return total + nested
            }
            return total + Int64(values.fileSize ?? 0)
        }
    }
    static func copy(_ sources: [URL], to destination: URL, collisionPolicy: CollisionPolicy, fileManager: FileManager = .default) throws {
        for source in sources {
            let originalTarget = destination.appendingPathComponent(source.lastPathComponent)
            if fileManager.fileExists(atPath: originalTarget.path) {
                switch collisionPolicy {
                case .keepBoth:
                    try fileManager.copyItem(at: source, to: availableDestination(for: source, in: destination, fileManager: fileManager))
                case .skip:
                    continue
                case .replace:
                    try fileManager.removeItem(at: originalTarget)
                    try fileManager.copyItem(at: source, to: originalTarget)
                }
            } else {
                try fileManager.copyItem(at: source, to: originalTarget)
            }
        }
    }

    static func hasCollisions(_ sources: [URL], in destination: URL, fileManager: FileManager = .default) -> Bool {
        sources.contains { fileManager.fileExists(atPath: destination.appendingPathComponent($0.lastPathComponent).path) }
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

enum CopyEngineError: LocalizedError {
    case insufficientSpace
    var errorDescription: String? { L10n.text("transfer.insufficientSpace") }
}
