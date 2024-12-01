import SwiftUI
import Translation

struct ContentView: View {

    @AppStorage("selectedTranslationLanguage") private
        var storedTranslationLanguage: String = Language.german.rawValue
    @State private var selectedTranslationLanguage: Language = .german
    
    @AppStorage("selectedTranslationTypeNative") private
        var storedTranslationTypeNative: Bool = false

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

    var body: some View {
        NavigationStack {
            ZStack {
                withAnimation {
                    Rectangle().fill(jokeColor.gradient)
                        .rotationEffect(.degrees(180))
                        .ignoresSafeArea()
                }

                VStack {
                    if type.isEmpty {
                    } else {
                        Label(type.capitalized, systemImage: "tag")
                            .font(.caption2)
                            .bold()
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(Color.white.opacity(0.1))
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }

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
                                //                                    .transition(.move(edge: .bottom))
                                Text(punchline)
                                    .font(.title)
                                    .multilineTextAlignment(.center)
                                    .padding(.bottom, 40)
                                    .transition(.move(edge: .bottom))
                            }
                            .copyGesture(joke) { joke in
                                //                                copyToClipboard(joke)
                            }
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
                        /// Button Fetch Joke
                        Button(action: {
                            //                                withAnimation {
                            resetAnimation()
                            fetchJoke()
                            //                                }
                        }) {
                            Text(
                                NSLocalizedString(
                                    "fetch_joke_button", comment: "")
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
                    Text(toastMessage)
                        .font(.body)
                        .padding()
                        .background(
                            Color.black.opacity(0.7),
                            in: RoundedRectangle(cornerRadius: 10)
                        )
                        .foregroundColor(.white)
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut, value: showToast)
                        .padding(.bottom, 40)
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

    func fetchJoke() {
        joke = NSLocalizedString("loading_status", comment: "")
        setup = NSLocalizedString("loading_status", comment: "")
        punchline = NSLocalizedString("thinking_status", comment: "")
        type = ""
        translatedText = ""

        guard
            let url = URL(
                string: "https://official-joke-api.appspot.com/random_joke")
        else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.joke =
                        "Failed to fetch joke: \(error.localizedDescription)"
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

            if let decodedResponse = try? JSONDecoder().decode(
                Joke.self, from: data)
            {
                DispatchQueue.main.async {
                    // Animation hinzufügen
                    self.joke =
                        "\(decodedResponse.setup)\n\n\(decodedResponse.punchline)"
                    self.textToTranslate =
                        "\(decodedResponse.setup)\n\n\(decodedResponse.punchline)"
                    self.setup = decodedResponse.setup
                    self.id = decodedResponse.id
                    self.type = decodedResponse.type
                    withAnimation(.linear(duration: 0.5)) {
                        self.jokeColor = colorForType(decodedResponse.type)
                    }
                    withAnimation(.linear(duration: 0.1).delay(0.8)) {
                        self.punchline = decodedResponse.punchline
                    }
                }
            } else {
                print("Failed to decode JSON")
                DispatchQueue.main.async {
                    self.joke = "Failed to decode joke"
                }
            }
        }.resume()
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

struct Joke: Codable {
    var id: Int
    var type: String
    var setup: String
    var punchline: String
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

#Preview {
    ContentView()
}
