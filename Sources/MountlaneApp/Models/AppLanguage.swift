import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case english = "en"
    case russian = "ru"

    var id: String { rawValue }

    static var current: AppLanguage {
        AppLanguage(rawValue: UserDefaults.standard.string(forKey: "selectedLanguage") ?? AppLanguage.system.rawValue) ?? .system
    }

    var locale: Locale {
        switch self {
        case .system: .current
        case .english, .russian: Locale(identifier: rawValue)
        }
    }

    var title: String {
        switch self {
        case .system: L10n.text("language.system")
        case .english: "English"
        case .russian: "Русский"
        }
    }
}
