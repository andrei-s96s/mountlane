import SwiftUI

struct TransfersView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var transferStore: TransferStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(L10n.text("transfer.title")).font(.title2.weight(.semibold))
                Spacer()
                Button(L10n.text("transfer.clear")) { transferStore.clearFinished() }
                    .disabled(transferStore.operations.isEmpty)
            }
            if transferStore.operations.isEmpty {
                ContentUnavailableView(L10n.text("transfer.empty"), systemImage: "arrow.left.arrow.right", description: Text(L10n.text("transfer.emptyMessage")))
            } else {
                List(transferStore.operations) { operation in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(L10n.text("transfer.summary", Int64(operation.sourceURLs.count), operation.destinationURL.lastPathComponent))
                        Text(ByteCountFormatter.string(fromByteCount: operation.totalBytes, countStyle: .file)).font(.caption).foregroundStyle(.secondary)
                        HStack {
                            if case .copying = operation.state { ProgressView().controlSize(.small) }
                            Text(L10n.text(operation.state.localizationKey)).font(.caption).foregroundStyle(.secondary)
                        }
                        if case let .failed(message) = operation.state {
                            Text(message).font(.caption).foregroundStyle(.red).lineLimit(2)
                        }
                    }
                    .padding(.vertical, 3)
                }
            }
            HStack { Spacer(); Button(L10n.text("action.done")) { dismiss() }.keyboardShortcut(.defaultAction) }
        }
        .padding(24)
        .frame(width: 520, height: 360)
    }
}
