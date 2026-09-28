import Foundation

enum L10n {
    static func text(_ key: String) -> String {
        localizedValue(for: key)
    }

    static func text(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: localizedValue(for: key), locale: AppLanguage.current.locale, arguments: arguments)
    }

    private static func localizedValue(for key: String) -> String {
        let preference = UserDefaults.standard.string(forKey: "selectedLanguage") ?? AppLanguage.system.rawValue
        let language = preference == AppLanguage.system.rawValue
            ? Locale.preferredLanguages.first?.split(separator: "-").first.map(String.init) ?? "en"
            : preference
        let bundle = Bundle.module.path(forResource: language, ofType: "lproj").flatMap(Bundle.init(path:)) ?? Bundle.module
        return bundle.localizedString(forKey: key, value: key, table: nil)
    }
}
