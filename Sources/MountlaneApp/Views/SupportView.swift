import SwiftUI

struct SupportView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.circle.fill").font(.system(size: 48)).foregroundStyle(.pink)
            Text(L10n.text("support.title")).font(.title2.weight(.semibold))
            Text(L10n.text("support.message")).multilineTextAlignment(.center).foregroundStyle(.secondary)
            Button(L10n.text("action.done")) { dismiss() }.keyboardShortcut(.defaultAction)
        }
        .padding(28).frame(width: 410)
    }
}
