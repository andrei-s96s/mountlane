import AppKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var volumeStore: VolumeStore
    @State private var showingSettings = false
    @State private var showingSupport = false

    private var selectedVolume: VolumeInfo? {
        volumeStore.volumes.first { $0.id == volumeStore.selectedVolumeID }
    }

    var body: some View {
        NavigationSplitView {
            VolumeSidebar(selection: $volumeStore.selectedVolumeID)
                .navigationSplitViewColumnWidth(min: 230, ideal: 270)
        } detail: {
            if let volume = selectedVolume {
                VolumeBrowser(volume: volume)
            } else {
                ContentUnavailableView(L10n.text("empty.title"), systemImage: "externaldrive.badge.questionmark", description: Text(L10n.text("empty.message")))
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(L10n.text("toolbar.refresh"), systemImage: "arrow.clockwise") { volumeStore.refresh() }
                    .help(L10n.text("toolbar.refresh"))
                Button(L10n.text("toolbar.settings"), systemImage: "gearshape") { showingSettings = true }
                    .help(L10n.text("toolbar.settings"))
                Button(L10n.text("toolbar.support"), systemImage: "heart") { showingSupport = true }
                    .help(L10n.text("toolbar.support"))
            }
        }
        .sheet(isPresented: $showingSettings) { SettingsView() }
        .sheet(isPresented: $showingSupport) { SupportView() }
        .alert(L10n.text("error.title"), isPresented: Binding(
            get: { volumeStore.lastError != nil },
            set: { if !$0 { volumeStore.lastError = nil } }
        )) {
            Button(L10n.text("action.ok"), role: .cancel) { volumeStore.lastError = nil }
        } message: {
            Text(volumeStore.lastError ?? "")
        }
    }
}

private struct VolumeSidebar: View {
    @EnvironmentObject private var volumeStore: VolumeStore
    @Binding var selection: VolumeInfo.ID?

    var body: some View {
        List(selection: $selection) {
            Section(L10n.text("sidebar.volumes")) {
                ForEach(volumeStore.volumes) { volume in
                    VolumeRow(volume: volume)
                        .tag(volume.id)
                        .contextMenu {
                            Button(L10n.text("action.openFinder")) { NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: volume.url.path) }
                            if volume.isEjectable {
                                Button(L10n.text("action.eject")) { volumeStore.eject(volume) }
                            }
                        }
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle(L10n.text("app.name"))
    }
}

private struct VolumeRow: View {
    let volume: VolumeInfo

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: volume.isRemovable ? "externaldrive.fill" : "internaldrive.fill")
                .foregroundStyle(volume.isReadOnly ? Color.secondary : Color.accentColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(volume.name).lineLimit(1)
                Text("\(volume.fileSystem) · \(L10n.text(volume.accessModeKey))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
