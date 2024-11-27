import SwiftUI

struct LanguageSelectionView: View {
    @AppStorage("selectedTranslationLanguage") private
    var storedTranslationLanguage: String = Language.german.rawValue
    @State private var selectedTranslationLanguage: Language = .german
    @FocusState private var focusedLanguage: Language?  // Fokussteuerung
    
    @Environment(\.dismiss) private var dismiss // Verwendet, um zur vorherigen View zurückzukehren
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                HStack(spacing: 20) {
                    VStack(alignment: .center) {
                        Spacer()
                        Image(systemName: "translate")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 500)
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("Select a language to translate to")
    //                        .font(.title)
                            .padding()
                        Spacer()
                    }
                    .frame(width: geometry.size.width * 0.5)
                    
                    
                    VStack {
                        // Vorab berechnete gefilterte Liste der Sprachen
                        let filteredLanguages = Language.allCases.filter { $0 != .english }
                        
                        // List of languages with selections
                        List {
                            ForEach(filteredLanguages, id: \.self) { language in
                                Button(action: {
                                    selectLanguage(language)
                                }) {
                                    LanguageSelectionRow(language: language, isSelected: selectedTranslationLanguage == language)
                                        .focused($focusedLanguage, equals: language) // Fokussteuerung
                                }
                            }
                        }
                
                    }
                }
                .navigationTitle("Language Settings")
                .onAppear {
                    selectedTranslationLanguage = Language(rawValue: storedTranslationLanguage) ?? .german
                }
                
            }
            
        }
        
    }
    
    // Helper method to handle language selection
    private func selectLanguage(_ language: Language) {
        selectedTranslationLanguage = language
        storedTranslationLanguage = language.rawValue
        print("Stored tvOS language: \(selectedTranslationLanguage)")
    }
    
    // Save button action
    private func saveLanguageSelection() {
        storedTranslationLanguage = selectedTranslationLanguage.rawValue
    }
}

struct LanguageSelectionRow: View {
    var language: Language
    var isSelected: Bool
    
    var body: some View {

            HStack {
                Text(language.name)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                }
            }
    }
}

#Preview {
    LanguageSelectionView()
}
