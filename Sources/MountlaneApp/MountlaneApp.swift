import SwiftUI

@main
struct MountlaneApp: App {
    @StateObject private var volumeStore = VolumeStore()
    @StateObject private var transferStore = TransferStore()
    @AppStorage("selectedLanguage") private var selectedLanguage = AppLanguage.system.rawValue

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(volumeStore)
                .environmentObject(transferStore)
                .environment(\.locale, AppLanguage(rawValue: selectedLanguage)?.locale ?? .current)
                .task { volumeStore.start() }
        }
        .defaultSize(width: 1120, height: 700)
        .commands {
            CommandGroup(after: .appInfo) {
                Button(L10n.text("menu.refresh")) { volumeStore.refresh() }
                    .keyboardShortcut("r")
            }
        }
    }
}
