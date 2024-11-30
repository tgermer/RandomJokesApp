import Foundation

struct TranslationResponse: Codable {
    let data: Data
}

struct Data: Codable {
    let translations: Translations
}

struct Translations: Codable {
    let translatedText: String
}
