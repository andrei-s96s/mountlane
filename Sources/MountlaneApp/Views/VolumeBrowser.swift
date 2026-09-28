import AppKit
import SwiftUI

private enum RemountResult: Sendable {
    case success
    case failure(String)
}

struct VolumeBrowser: View {
    @EnvironmentObject private var volumeStore: VolumeStore
    @EnvironmentObject private var transferStore: TransferStore
    let volume: VolumeInfo
    @State private var currentDirectory: URL
    @State private var items: [FileItem] = []
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var sortOrder: FileSortOrder = .name
    @State private var showHiddenFiles = false
    @State private var isRemounting = false
    @State private var showingRemountConfirmation = false
    @State private var showingNTFSSetup = false
    @State private var selection = Set<FileItem.ID>()
    @State private var collisionPolicy: CollisionPolicy = .keepBoth
    @State private var pendingDestination: URL?
    @State private var showingReplaceConfirmation = false

    init(volume: VolumeInfo) {
        self.volume = volume
        _currentDirectory = State(initialValue: volume.url)
    }

    var body: some View {
        VStack(spacing: 0) {
            VolumeHeader(volume: volume)
            if volume.isNTFS {
                NTFSStatusCard(
                    volume: volume,
                    isRemounting: isRemounting,
                    remount: { showingRemountConfirmation = true },
                    prepare: { showingNTFSSetup = true }
                )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)
            }
            Divider()
            HStack(spacing: 10) {
                Button(action: goUp) { Image(systemName: "chevron.left") }
                    .disabled(currentDirectory == volume.url)
                Breadcrumbs(volumeURL: volume.url, currentDirectory: currentDirectory) { destination in
                    currentDirectory = destination
                }
                Spacer()
                Button(L10n.text("action.openFinder"), systemImage: "arrow.up.forward.app") {
                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: currentDirectory.path)
                }
            }
            .padding(12)
            Divider()
            List(visibleItems, selection: $selection) { item in
                FileRow(item: item)
                    .contentShape(Rectangle())
                    .onTapGesture(count: 2) { open(item) }
                .contextMenu { FileActions(item: item) }
            }
            .overlay {
                if visibleItems.isEmpty && errorMessage == nil {
                    ContentUnavailableView(L10n.text("files.empty"), systemImage: "folder", description: Text(L10n.text("files.emptyMessage")))
                }
            }
        }
        .navigationTitle(volume.name)
        .searchable(text: $searchText, prompt: L10n.text("files.search"))
        .toolbar {
            ToolbarItemGroup(placement: .secondaryAction) {
                Menu(L10n.text("files.sort"), systemImage: "arrow.up.arrow.down") {
                    Picker(L10n.text("files.sort"), selection: $sortOrder) {
                        Text(L10n.text("files.sortName")).tag(FileSortOrder.name)
                        Text(L10n.text("files.sortDate")).tag(FileSortOrder.modificationDate)
                        Text(L10n.text("files.sortSize")).tag(FileSortOrder.size)
                    }
                }
                Toggle(L10n.text("files.showHidden"), isOn: $showHiddenFiles)
                Menu(L10n.text("transfer.conflict"), systemImage: "exclamationmark.arrow.trianglehead.2.clockwise.rotate.90") {
                    Picker(L10n.text("transfer.conflict"), selection: $collisionPolicy) {
                        ForEach(CollisionPolicy.allCases) { policy in
                            Text(L10n.text(policy.localizationKey)).tag(policy)
                        }
                    }
                }
                Button(L10n.text("transfer.copy"), systemImage: "doc.on.doc") { chooseCopyDestination() }
                    .disabled(selection.isEmpty)
            }
        }
        .task(id: currentDirectory) { loadItems() }
        .onChange(of: showHiddenFiles) { _, _ in loadItems() }
        .alert(L10n.text("error.title"), isPresented: Binding(
            get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } }
        )) { Button(L10n.text("action.ok"), role: .cancel) {} } message: { Text(errorMessage ?? "") }
        .confirmationDialog(L10n.text("ntfs.remountTitle"), isPresented: $showingRemountConfirmation, titleVisibility: .visible) {
            Button(L10n.text("ntfs.enableWrite")) { remountNTFS() }
            Button(L10n.text("action.cancel"), role: .cancel) {}
        } message: {
            Text(L10n.text("ntfs.remountWarning"))
        }
        .sheet(isPresented: $showingNTFSSetup) { NTFSSetupView() }
        .confirmationDialog(L10n.text("transfer.replaceTitle"), isPresented: $showingReplaceConfirmation, titleVisibility: .visible) {
            Button(L10n.text("transfer.replaceConfirm"), role: .destructive) { beginCopy() }
            Button(L10n.text("action.cancel"), role: .cancel) { pendingDestination = nil }
        } message: {
            Text(L10n.text("transfer.replaceWarning"))
        }
    }

    private func loadItems() {
        do { items = try FileBrowser.contents(of: currentDirectory, includingHiddenFiles: showHiddenFiles); errorMessage = nil }
        catch { items = []; errorMessage = error.localizedDescription }
    }

    private func goUp() {
        guard currentDirectory != volume.url else { return }
        currentDirectory.deleteLastPathComponent()
    }

    private func open(_ item: FileItem) {
        if item.isDirectory { currentDirectory = item.url; loadItems() }
        else { NSWorkspace.shared.open(item.url) }
    }

    private func chooseCopyDestination() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = L10n.text("transfer.copyHere")
        guard panel.runModal() == .OK, let destination = panel.url else { return }
        let sources = items.filter { selection.contains($0.id) }.map(\.url)
        pendingDestination = destination
        if collisionPolicy == .replace && CopyEngine.hasCollisions(sources, in: destination) {
            showingReplaceConfirmation = true
        } else {
            beginCopy()
        }
    }

    private func beginCopy() {
        guard let destination = pendingDestination else { return }
        let sources = items.filter { selection.contains($0.id) }.map(\.url)
        do { try transferStore.copy(sources, to: destination, collisionPolicy: collisionPolicy) }
        catch { errorMessage = error.localizedDescription }
        pendingDestination = nil
    }

    private var visibleItems: [FileItem] {
        let filtered = searchText.isEmpty ? items : items.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
        return sortOrder.sorted(filtered)
    }

    private func remountNTFS() {
        guard let providerPath = NTFSProviderStatus.detect().executablePath else { return }
        let volumeURL = volume.url
        isRemounting = true
        Task {
            let result: RemountResult = await Task.detached(priority: .userInitiated) {
                do {
                    try NTFSRemounter.remount(volumeURL: volumeURL, providerPath: providerPath)
                    return .success
                } catch {
                    return .failure(error.localizedDescription)
                }
            }.value
            isRemounting = false
            switch result {
            case .success:
                volumeStore.refresh()
            case let .failure(message):
                errorMessage = message
            }
        }
    }
}

private struct Breadcrumbs: View {
    let volumeURL: URL
    let currentDirectory: URL
    let select: (URL) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(path, id: \.self) { entry in
                    if entry != volumeURL { Image(systemName: "chevron.right").font(.caption2).foregroundStyle(.tertiary) }
                    Button(entry == volumeURL ? volumeURL.lastPathComponent : entry.lastPathComponent) { select(entry) }
                        .buttonStyle(.plain)
                        .font(.caption)
                        .lineLimit(1)
                }
            }
        }
    }

    private var path: [URL] {
        let relativePath = currentDirectory.path.dropFirst(volumeURL.path.count)
        return relativePath.split(separator: "/").reduce([volumeURL]) { result, component in
            result + [result.last!.appendingPathComponent(String(component))]
        }
    }
}

private struct FileActions: View {
    let item: FileItem

    var body: some View {
        Button(L10n.text("action.openFinder")) {
            NSWorkspace.shared.activateFileViewerSelecting([item.url])
        }
        Button(L10n.text("action.copyPath")) {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(item.url.path(percentEncoded: false), forType: .string)
        }
    }
}

private struct VolumeHeader: View {
    @EnvironmentObject private var volumeStore: VolumeStore
    let volume: VolumeInfo

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: volume.isRemovable ? "externaldrive.fill" : "internaldrive.fill")
                .font(.system(size: 34))
                .foregroundStyle(volume.isReadOnly ? Color.secondary : Color.accentColor)
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
                .foregroundStyle(item.isDirectory ? Color.accentColor : Color.secondary)
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
