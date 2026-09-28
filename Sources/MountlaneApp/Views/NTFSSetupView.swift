import SwiftUI

struct NTFSSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var runtime = NTFSRuntimeStatus.detect()

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                Image(systemName: "wrench.and.screwdriver.fill")
                    .font(.title).foregroundStyle(Color.accentColor)
                VStack(alignment: .leading) {
                    Text(L10n.text("ntfs.setupTitle")).font(.title2.weight(.semibold))
                    Text(L10n.text("ntfs.setupSubtitle")).foregroundStyle(.secondary)
                }
            }

            SetupCheck(isReady: runtime.isFuseTInstalled, title: L10n.text("ntfs.fuseT"), detail: L10n.text("ntfs.fuseTDetail"))
            SetupCheck(isReady: runtime.provider.isDetected, title: L10n.text("ntfs.driver"), detail: L10n.text("ntfs.driverDetail"))

            if !runtime.isFuseTInstalled {
                Link(L10n.text("ntfs.downloadFuseT"), destination: URL(string: "https://www.fuse-t.org/downloads")!)
            }
            if !runtime.provider.isDetected {
                Link(L10n.text("ntfs.getDriver"), destination: URL(string: "https://github.com/macos-fuse-t/ntfs-3g")!)
            }

            Text(L10n.text("ntfs.setupSafety"))
                .font(.caption).foregroundStyle(.secondary)

            HStack {
                Button(L10n.text("ntfs.checkAgain"), systemImage: "arrow.clockwise") {
                    runtime = NTFSRuntimeStatus.detect()
                }
                Spacer()
                Button(L10n.text("action.done")) { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 510)
    }
}

private struct SetupCheck: View {
    let isReady: Bool
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: isReady ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isReady ? Color.green : Color.secondary)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).fontWeight(.medium)
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}
