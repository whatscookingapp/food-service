import Foundation

extension String {
    
    func toSearchableQuery() -> String {
        let characterSet = CharacterSet.alphanumerics.union(.whitespacesAndNewlines)
        let query = String(self.unicodeScalars.filter(characterSet.contains)).condenseWhitespace()
        return query.split(separator: " ").map { $0 + ":*" }.joined(separator: " | ")
    }
    
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
    
    var stringByRemovingWhitespaces: String {
        return components(separatedBy: .whitespaces).joined(separator: "")
    }
}
