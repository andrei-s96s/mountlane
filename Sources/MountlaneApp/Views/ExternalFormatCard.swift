import SwiftUI

struct ExternalFormatCard: View {
    let format: String

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 7) {
                Label(L10n.text("externalFormat.title", format), systemImage: "lock.doc")
                    .font(.headline)
                Text(L10n.text("externalFormat.message"))
                    .foregroundStyle(.secondary)
                Text(L10n.text("externalFormat.safety"))
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}
