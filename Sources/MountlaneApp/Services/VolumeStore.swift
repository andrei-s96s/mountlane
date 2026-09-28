import AppKit
import Foundation

@MainActor
final class VolumeStore: ObservableObject {
    @Published private(set) var volumes: [VolumeInfo] = []
    @Published var selectedVolumeID: VolumeInfo.ID?
    @Published var lastError: String?

    private var observers: [NSObjectProtocol] = []
    private var hasStarted = false

    deinit {
        observers.forEach(NotificationCenter.default.removeObserver)
    }

    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        refresh()

        let center = NSWorkspace.shared.notificationCenter
        let names: [NSNotification.Name] = [
            NSWorkspace.didMountNotification,
            NSWorkspace.didUnmountNotification,
            NSWorkspace.didRenameVolumeNotification
        ]
        observers = names.map { name in
            center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor in self?.refresh() }
            }
        }
    }

    func refresh() {
        let keys: Set<URLResourceKey> = [
            .volumeNameKey, .volumeLocalizedNameKey, .volumeUUIDStringKey,
            .volumeIsReadOnlyKey, .volumeIsRemovableKey, .volumeIsEjectableKey,
            .volumeTotalCapacityKey, .volumeAvailableCapacityKey, .volumeLocalizedFormatDescriptionKey
        ]
        let urls = FileManager.default.mountedVolumeURLs(
            includingResourceValuesForKeys: Array(keys),
            options: [.skipHiddenVolumes]
        ) ?? []

        volumes = urls.compactMap { url in
            guard let values = try? url.resourceValues(forKeys: keys) else { return nil }
            let name = values.volumeLocalizedName ?? values.volumeName ?? url.lastPathComponent
            return VolumeInfo(
                id: values.volumeUUIDString ?? url.path,
                url: url,
                name: name,
                fileSystem: values.volumeLocalizedFormatDescription ?? L10n.text("format.unknown"),
                isReadOnly: values.volumeIsReadOnly ?? true,
                isRemovable: values.volumeIsRemovable ?? false,
                isEjectable: values.volumeIsEjectable ?? false,
                totalCapacity: values.volumeTotalCapacity.map(Int64.init),
                availableCapacity: values.volumeAvailableCapacity.map(Int64.init)
            )
        }.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }

        if selectedVolumeID == nil || !volumes.contains(where: { $0.id == selectedVolumeID }) {
            selectedVolumeID = volumes.first?.id
        }
    }

    func eject(_ volume: VolumeInfo) {
        NSWorkspace.shared.unmountAndEjectDevice(at: volume.url)
        refresh()
    }
}
