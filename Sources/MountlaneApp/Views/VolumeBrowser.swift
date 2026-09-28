import AppKit
import SwiftUI

struct VolumeBrowser: View {
    @EnvironmentObject private var volumeStore: VolumeStore
    let volume: VolumeInfo
    @State private var currentDirectory: URL
    @State private var items: [FileItem] = []
    @State private var errorMessage: String?

    init(volume: VolumeInfo) {
        self.volume = volume
        _currentDirectory = State(initialValue: volume.url)
    }

    var body: some View {
        VStack(spacing: 0) {
            VolumeHeader(volume: volume)
            Divider()
            HStack {
                Button(action: goUp) { Image(systemName: "chevron.left") }
                    .disabled(currentDirectory == volume.url)
                Text(currentDirectory.path(percentEncoded: false))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer()
                Button(L10n.text("action.openFinder"), systemImage: "arrow.up.forward.app") {
                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: currentDirectory.path)
                }
            }
            .padding(12)
            Divider()
            List(items) { item in
                Button {
                    if item.isDirectory { currentDirectory = item.url; loadItems() }
                    else { NSWorkspace.shared.open(item.url) }
                } label: {
                    FileRow(item: item)
                }
                .buttonStyle(.plain)
            }
            .overlay {
                if items.isEmpty && errorMessage == nil {
                    ContentUnavailableView(L10n.text("files.empty"), systemImage: "folder", description: Text(L10n.text("files.emptyMessage")))
                }
            }
        }
        .navigationTitle(volume.name)
        .task(id: currentDirectory) { loadItems() }
        .alert(L10n.text("error.title"), isPresented: Binding(
            get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } }
        )) { Button(L10n.text("action.ok"), role: .cancel) {} } message: { Text(errorMessage ?? "") }
    }

    private func loadItems() {
        do { items = try FileBrowser.contents(of: currentDirectory); errorMessage = nil }
        catch { items = []; errorMessage = error.localizedDescription }
    }

    private func goUp() {
        guard currentDirectory != volume.url else { return }
        currentDirectory.deleteLastPathComponent()
    }
}

private struct VolumeHeader: View {
    @EnvironmentObject private var volumeStore: VolumeStore
    let volume: VolumeInfo

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: volume.isRemovable ? "externaldrive.fill" : "internaldrive.fill")
                .font(.system(size: 34))
                .foregroundStyle(volume.isReadOnly ? .secondary : .accent)
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(volume.fileSystem).font(.headline)
                    AccessBadge(isReadOnly: volume.isReadOnly)
                }
                if let available = volume.availableCapacity, let total = volume.totalCapacity {
                    Text(L10n.text("volume.available", ByteCountFormatter.string(fromByteCount: available, countStyle: .file), ByteCountFormatter.string(fromByteCount: total, countStyle: .file)))
                        .foregroundStyle(.secondary)
                } else {
                    Text(L10n.text("volume.capacityUnavailable")).foregroundStyle(.secondary)
                }
            }
            Spacer()
            if volume.isEjectable {
                Button(L10n.text("action.eject"), systemImage: "eject") { volumeStore.eject(volume) }
                    .help(L10n.text("eject.hint"))
            }
        }
        .padding(20)
    }
}

private struct AccessBadge: View {
    let isReadOnly: Bool
    var body: some View {
        Text(L10n.text(isReadOnly ? "access.readOnly" : "access.readWrite"))
            .font(.caption.weight(.medium))
            .padding(.horizontal, 7).padding(.vertical, 3)
            .background(isReadOnly ? Color.orange.opacity(0.16) : Color.green.opacity(0.16), in: Capsule())
            .foregroundStyle(isReadOnly ? .orange : .green)
    }
}

private struct FileRow: View {
    let item: FileItem
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: item.isDirectory ? "folder.fill" : "doc")
                .foregroundStyle(item.isDirectory ? .accent : .secondary)
            Text(item.name)
            Spacer()
            if let size = item.size, !item.isDirectory {
                Text(ByteCountFormatter.string(fromByteCount: size, countStyle: .file))
                    .font(.caption).foregroundStyle(.secondary)
            }
            if let date = item.modificationDate {
                Text(date, format: .dateTime.year().month().day())
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
