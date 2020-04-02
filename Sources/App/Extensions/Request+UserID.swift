import Vapor

extension Request {
    
    var userID: UUID? {
        guard let id = headers.firstValue(name: .init("X-User")) else { return nil }
        return UUID(uuidString: id)
    }
    
    func requireUserID() throws -> UUID {
        guard let id = userID else {
            throw Abort(.unauthorized)
        }
        return id
    }
    
    func retrievePreferredLanguages() -> [Locale] {
        guard let languageHeader = headers.firstValue(name: .acceptLanguage)?.stringByRemovingWhitespaces else { return [] }
        let list = languageHeader.split(separator: ",").map(String.init)
        let locales: [Locale] = list.reduce(into: []) { (result, item) in
            let split = item.split(separator: ";").map(String.init)
            var quality: Double = 1
            if let qualityString = split[safe: 1]?.replacingOccurrences(of: "q=", with: "") {
                quality = Double(qualityString) ?? 1
            }
            let locales = split.first?.split(separator: ",").compactMap(String.init).map { Locale(locale: $0, quality: quality) } ?? []
            result.append(contentsOf: locales)
        }
        return locales.sorted(by: { $0.quality > $1.quality })
    }
}

extension Collection where Element == Locale {
    
    func preferredLanguage() -> String {
        let supportedLanguages: [String: String] = ["nl": "dutch", "be": "dutch", "en": "english", "de": "german", "fr": "french"]
        let languages = compactMap { item in
            return supportedLanguages.first { key, value -> Bool in
                return item.locale.lowercased().hasPrefix(key)
            }
        }
        return languages.first?.value ?? "english"
    }
}

struct Locale {
    
    let locale: String
    let quality: Double
}

public extension Array {

    subscript (safe index: Int) -> Element? {
        get {
            return index < count && index >= 0 ? self[index] : nil
        }
        set {
            if let element = newValue, index < count, index >= 0 {
                self[index] = element
            }
        }
    }
}
