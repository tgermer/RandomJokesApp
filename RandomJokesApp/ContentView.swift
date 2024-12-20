import SwiftUI
import Translation
import TipKit

struct ContentView: View {

    @AppStorage("selectedTranslationLanguage") private
        var storedTranslationLanguage: String = Language.german.rawValue
    @State private var selectedTranslationLanguage: Language = .german
    
    @AppStorage("selectedTranslationTypeNative") private
        var storedTranslationTypeNative: Bool = false

    @AppStorage("selectedJokeType") private
    var storedJokeType: String = JokeType.all.rawValue

    @AppStorage("showPunchlineOnDemand") private
    var showPunchlineOnDemand: Bool = false
    
    @State private var isPunchlineVisible: Bool = false

    private var currentJokeType: JokeType {
        JokeType.allCases.first(where: { $0.rawValue == storedJokeType }) ?? .all
    }

    @State private var joke: String = ""
    @State private var type: String = ""
    @State private var setup: String = ""
    @State private var punchline: String = ""
    @State private var id: Int = 0
    @State private var jokeColor: Color = Color("AppPrimary")

    // Zustände für die Animation
    @State private var showSetup: Bool = false
    @State private var showPunchline: Bool = false
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""

    @State private var textToTranslate = ""
    @State private var translatedText = ""
    @State private var fromLanguage = Language.english
    @State private var toLanguage: Language = Language.german

    @State private var showLanguageSelectionViewTvOs: Bool = false
    @FocusState private var focusedButtonTvOs: Bool?  // Fokus für den Button speichern
    
    @State private var showTranslation = false

    //@State private var selectedJokeType: JokeType = .all // Zustand für den ausgewählten Witztyp

    var body: some View {
        NavigationStack {
            ZStack {
                withAnimation {
                    Rectangle().fill(jokeColor.gradient)
                        .rotationEffect(.degrees(180))
                        .ignoresSafeArea()
                }

                VStack {
                    JokeTypeLabel(type: type)

                    Spacer()

                    Group {
                        if setup.isEmpty {
                            
                            HStack {
                                Spacer()
                                VStack {
                                    Image("CloudJokeFetcher")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 300)
                                        .padding(.bottom, 30)
                                    Text("no_joke_showing")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .fontDesign(.rounded)
                                    Text("click_fetch_joke")
                                }
                                .foregroundColor(.white)
                                Spacer()
                            }
                            
                        } else {
                            Group {
                                Text(setup)
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.center)
                                    .padding(.bottom, 40)
                                
                                if showPunchlineOnDemand {
                                    if isPunchlineVisible {
                                        Text(punchline)
                                            .font(.title)
                                            .multilineTextAlignment(.center)
                                            .padding(.bottom, 40)
                                            .transition(.move(edge: .bottom))
                                    }
                                        else {
                                    }
                                } else {
                                    Text(punchline)
                                        .font(.title)
                                        .multilineTextAlignment(.center)
                                        .padding(.bottom, 40)
                                        .transition(.move(edge: .bottom))
                                }
                            }
                            #if os(iOS)
                            .copyGesture(joke) { joke in
                                copyToClipboard(joke)
                            }
                            #endif
                        }

                    }

                    if !translatedText.isEmpty {
                        Divider()
                            .padding(.bottom)
                    }
                    Text(translatedText)
                        .font(.title3)
                        .multilineTextAlignment(.center)

                    Spacer()

                    #if os(tvOS)
                        HStack {

                            NavigationLink(
                                destination: LanguageSelectionView(),
                                isActive: $showLanguageSelectionViewTvOs,
                                label: {
                                    Label("Settings", systemImage: "gear")
                                        .labelStyle(IconOnlyLabelStyle())
                                }
                            )

                            Button(action: {
//                                withAnimation {
                                    resetAnimation()
                                    fetchJoke()
//                                }
                            }) {
                                Text(
                                    NSLocalizedString(
                                        "fetch_joke_button", comment: ""))
                            }
                            .frame(maxWidth: .infinity)
                            .focused($focusedButtonTvOs, equals: true)  // Setze Fokus auf diesen Button

                            Button(action: {
                                // Perform your action
                                Task {
                                    do {
                                        try await performTranslation()
                                    } catch {
                                        print(error)
                                    }
                                }
                            }) {
                                Label("Translate", systemImage: "translate")
                                    .labelStyle(IconOnlyLabelStyle())  // Shows only the icon
                            }
                            .disabled(!translatedText.isEmpty)
                        }
                    #endif
                    
                    #if os(iOS)
                    ZStack {
                        /// Button Fetch Joke / Show Punchline
                        Button(action: {
                            if showPunchlineOnDemand && !setup.isEmpty && !isPunchlineVisible {
                                withAnimation {
                                    isPunchlineVisible = true
                                }
                            } else {
                                resetAnimation()
                                fetchJoke()
                            }
                        }) {
                            Text(
                                showPunchlineOnDemand && !setup.isEmpty && !isPunchlineVisible ?
                                NSLocalizedString("show_punchline_button", comment: "") :
                                NSLocalizedString("fetch_joke_button", comment: "")
                            )
                            .padding(.vertical, 20)
                            .padding(.horizontal, 40)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        }
                        .background(jokeColor)
                        .cornerRadius(100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(Color.white, lineWidth: 2)
                        )
                        
                        /// Button Translate
                        HStack {
                            Spacer()
                            if storedTranslationTypeNative == true {
                                /// Button Translate Native
                                Button(action: {
                                    showTranslation.toggle()
                                }) {
                                    Image(systemName: "translate")
                                }
                                .disabled(!translatedText.isEmpty)
                                .translationPresentation(isPresented: $showTranslation, text: joke)
                            } else {
                                Button(action: {
                                    Task {
                                        do {
                                            try await performTranslation()
                                        } catch {
                                            print(error)
                                        }
                                    }
                                }) {
                                    Image(systemName: "translate")
                                }
                                .disabled(!translatedText.isEmpty)
                            }
                        }
                        .padding(.trailing, 10)
                    }
                    #endif
                }
                .padding()

                // Toast Message (displayed for a short time)
                if showToast {
                    HStack(alignment: .top, spacing: 15) {
                        Image(systemName: "document.on.clipboard")
                        Text(toastMessage)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: 200)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 40)
                        .background(
                            Material.thin,
                            in: RoundedRectangle(cornerRadius: 10)
                        )
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut, value: showToast)
                }
            }
            #if os(iOS)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink(destination: SettingsView()) {
                            Label("Settings", systemImage: "gearshape")
                        }
                    }
                }
                .background(Color.clear)
            #endif
        }
        .onAppear {
            updateLanguage()
            // Fokus auf den "Fetch Joke"-Button setzen, nachdem die Übersetzung abgeschlossen ist
            focusedButtonTvOs = true
        }
        .onChange(of: storedTranslationLanguage) { _ in
            updateLanguage()
            translatedText = ""  // Reset translated text to enable the translation button
        }

    }

    private func fetchJoke() {
        // Reset states
        isPunchlineVisible = false  // Reset punchline visibility when fetching new joke
        joke = NSLocalizedString("loading_status", comment: "")
        setup = NSLocalizedString("loading_status", comment: "")
        punchline = NSLocalizedString("thinking_status", comment: "")
        type = ""
        translatedText = ""

        guard let url = URL(string: currentJokeType.rawValue) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.joke = "Failed to fetch joke: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    self.joke = "No data received"
                }
                return
            }

            do {
                if currentJokeType == .all {
                    // Für Random: Einzelner Witz
                    let decodedResponse = try JSONDecoder().decode(Joke.self, from: data)
                    updateJokeUI(with: decodedResponse)
                } else {
                    // Für spezifische Typen: Array mit einem Witz
                    let jokes = try JSONDecoder().decode([Joke].self, from: data)
                    if let decodedResponse = jokes.first {
                        updateJokeUI(with: decodedResponse)
                    }
                }
            } catch {
                print("Failed to decode JSON: \(error)")
                DispatchQueue.main.async {
                    self.joke = "Failed to decode joke"
                }
            }
        }.resume()
    }

    private func updateJokeUI(with joke: Joke) {
        DispatchQueue.main.async {
            self.joke = "\(joke.setup)\n\n\(joke.punchline)"
            self.textToTranslate = "\(joke.setup)\n\n\(joke.punchline)"
            self.setup = joke.setup
            self.id = joke.id
            self.type = joke.type
            withAnimation(.linear(duration: 0.5)) {
                self.jokeColor = self.colorForType(joke.type)
            }
            withAnimation(.linear(duration: 0.1).delay(0.8)) {
                self.punchline = joke.punchline
            }
        }
    }

    func colorForType(_ type: String) -> Color {
        switch type.lowercased() {
        case "general": return .orange
        case "programming": return .blue
        case "knock-knock": return .pink
        case "dad": return .brown
        default: return .gray
        }
    }

    func resetAnimation() {
        showSetup = false
        showPunchline = false
    }

    #if os(tvOS)
    #else
        func copyToClipboard(_ text: String) {
            UIPasteboard.general.string = text
            toastMessage = NSLocalizedString("copied_to_clipboard", comment: "")
            showToast = true

            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.prepare()
            impactFeedback.impactOccurred()

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showToast = false
            }
        }
    #endif

    private func updateLanguage() {
        print("CV Stored language: \(storedTranslationLanguage)")  // Debug-Ausgabe
        if let storedLanguage = Language(rawValue: storedTranslationLanguage) {
            toLanguage = storedLanguage
            print("CV Using stored language: \(toLanguage)")  // Debug-Ausgabe
        } else {
            toLanguage = .german
            print("CV Fallback to default language: \(toLanguage)")  // Debug-Ausgabe
        }

    }
}

// MARK: - View Extension
extension View {
    func copyGesture(_ joke: String, copyAction: @escaping (String) -> Void)
        -> some View
    {
        #if os(tvOS)
            self
        #else
            self.onTapGesture {
                // Verwende die übergebene Closure, um den Text zu kopieren
                copyAction(joke)
            }
        #endif
    }
}

// Rapid API Console aufrufen unter https://rapidapi.com/gatzuma/api/deep-translate1/

extension ContentView {

    func performTranslation() async throws {
        guard !textToTranslate.isEmpty else { return }

        await MainActor.run {
            translatedText =
                "\(NSLocalizedString("translating_status", comment: "")) \(toLanguage.name)"
        }
        
        // Fokus auf den "Fetch Joke"-Button setzen, nachdem die Übersetzung abgeschlossen ist
        focusedButtonTvOs = true

        // URL
        let url = URL(
            string:
                "https://deep-translate1.p.rapidapi.com/language/translate/v2")!
        var urlRequest = URLRequest(url: url)

        // Headers
        urlRequest.setValue(
            "application/json", forHTTPHeaderField: "content-type")
        urlRequest.setValue(
            "fa616fbb88msh186798ab6863820p1901b4jsn4b20bf4ab592",  //f46be5a3c2msh5ed6e81a006d250p140fe6jsnfc72cd9799c6
            forHTTPHeaderField: "X-RapidAPI-Key")

        // Method
        urlRequest.httpMethod = "POST"

        // Body
        let requestBody = TranslationRequest(
            q: textToTranslate,
            source: fromLanguage,
            target: toLanguage
        )

        // JSON Data
        let encoder = JSONEncoder()
        let data = try encoder.encode(requestBody)
        urlRequest.httpBody = data

        // Send Request
        let (responseData, _) = try await URLSession.shared.data(
            for: urlRequest)

        // Decode response
        let decoder = JSONDecoder()
        let response = try decoder.decode(
            TranslationResponse.self, from: responseData)

        // Update UI
        await MainActor.run {
            withAnimation(.linear(duration: 0.5)) {  // Animation with easeInOut timing curve
                translatedText = response.data.translations.translatedText
            }
        }
    }
}

#Preview("Start Screen") {
    ContentView()
}
