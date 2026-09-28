import SwiftUI

struct NTFSStatusCard: View {
    let volume: VolumeInfo
    let isRemounting: Bool
    let remount: () -> Void
    let prepare: () -> Void
    private let provider = NTFSProviderStatus.detect()

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label(L10n.text("ntfs.title"), systemImage: "externaldrive.badge.checkmark")
                        .font(.headline)
                    Spacer()
                    Text(L10n.text(volume.isReadOnly ? "access.readOnly" : "access.readWrite"))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(volume.isReadOnly ? Color.orange : Color.green)
                }

                if provider.isDetected {
                    Text(volume.isReadOnly ? L10n.text("ntfs.providerDetectedReadOnly") : L10n.text("ntfs.providerDetectedWritable"))
                        .foregroundStyle(.secondary)
                    if volume.isReadOnly {
                        Button(L10n.text("ntfs.enableWrite"), systemImage: "arrow.triangle.2.circlepath") { remount() }
                            .disabled(isRemounting)
                    }
                } else {
                    Text(L10n.text("ntfs.providerMissing"))
                        .foregroundStyle(.secondary)
                    Button(L10n.text("ntfs.prepare"), systemImage: "wrench.and.screwdriver") { prepare() }
                }

                Text(L10n.text("ntfs.safety"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } label: {
            Text("NTFS")
        }
    }
}
