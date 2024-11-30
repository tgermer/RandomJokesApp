import Foundation

struct TranslationRequest: Codable {
    let q: String
    let source: Language
    let target: Language
}

//enum Language: String, CaseIterable, Identifiable, Codable {
//    case english = "en"
//    case spanish = "es"
//    case french = "fr"
//    case german = "de"
//
//    var id: String { rawValue }
//    
//    var name: String {
//            switch self {
//            case .english: return "English"
//            case .spanish: return "Español"
//            case .french: return "Français"
//            case .german: return "Deutsch"
//            }
//        }
//}

enum Language: String, CaseIterable, Identifiable, Codable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case italian = "it"
    case portuguese = "pt"
    case dutch = "nl"
    case polish = "pl"
    case swedish = "sv"
    case danish = "da"
    case norwegian = "no"
    case russian = "ru"

    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .italian: return "Italiano"
        case .portuguese: return "Português"
        case .dutch: return "Nederlands"
        case .polish: return "Polski"
        case .swedish: return "Svenska"
        case .danish: return "Dansk"
        case .norwegian: return "Norsk"
        case .russian: return "Русский"
        }
    }
}
