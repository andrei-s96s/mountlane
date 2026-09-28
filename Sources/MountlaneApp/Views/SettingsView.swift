import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedLanguage") private var selectedLanguage = AppLanguage.system.rawValue

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(L10n.text("settings.title")).font(.title2.weight(.semibold))
            Picker(L10n.text("settings.language"), selection: $selectedLanguage) {
                ForEach(AppLanguage.allCases) { language in Text(language.title).tag(language.rawValue) }
            }
            .pickerStyle(.radioGroup)
            Spacer()
            HStack { Spacer(); Button(L10n.text("action.done")) { dismiss() }.keyboardShortcut(.defaultAction) }
        }
        .padding(24)
        .frame(width: 370, height: 240)
    }
}
