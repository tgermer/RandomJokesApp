//
//  SettingsView.swift
//  RandomJokesApp
//
//  Created by Tristan Germer on 27.11.24.
//

import SwiftUI

struct SettingsView: View {

    @AppStorage("selectedTranslationLanguage") private
        var storedTranslationLanguage: String = Language.german.rawValue
    @State private var selectedTranslationLanguage: Language = .german
    @State private var showRoadmapSheet: Bool = false
    @State private var showAboutDeveloperSheet: Bool = false

    var body: some View {
        NavigationStack {
            //            ScrollView {

            Form {
                Section("Give Feedback") {
                    CustomLinkRow(
                        label: "Give Feedback", systemImage: "envelope.fill",
                        destinationString:
                            "mailto:tristan.germer+jokes@gmail.com")
                    CustomLinkRow(
                        label: "Rate Jokes in App Store",
                        systemImage: "star.fill",
                        destinationString: "https://apps.apple.com/app/id15/")
                }
                Section(
                    header: Text("Translation"),
                    footer: Text("translation_info")
                ) {
                    HStack {
                        Label("Translate to", systemImage: "translate")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(Color("AppPrimary"))
                        Spacer()
                        Menu {
                            Picker(
                                "Language",
                                selection: $selectedTranslationLanguage
                            ) {
                                ForEach(
                                    Language.allCases.filter { $0 != .english }
                                        .sorted { $0.name < $1.name }
                                ) { language in
                                    Text(language.name).tag(language)
                                }
                            }
                        } label: {
                            Text(selectedTranslationLanguage.name)
                                .foregroundColor(.secondary)
                        }
                        .onChange(of: selectedTranslationLanguage) { newValue in
                            // Aktion, wenn die Sprache geändert wird
                            print(
                                "SV Selected Language: \(newValue.name) (\(newValue.rawValue))"
                            )
                            // Speichern der neuen Sprache in @AppStorage
                            storedTranslationLanguage = newValue.rawValue
                            print(
                                "SV Stored Language: \(storedTranslationLanguage)"
                            )
                        }

                    }
                }
                Section {
                    Label("Roadmap", systemImage: "checklist")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(Color("AppPrimary"))
                        .onTapGesture {
                            showRoadmapSheet.toggle()
                        }
                    Label("About Developer", systemImage: "person.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(Color("AppPrimary"))
                        .onTapGesture {
                            showAboutDeveloperSheet.toggle()
                        }

                    CustomLinkRow(
                        label: "Privacy Policy", systemImage: "lock.fill",
                        destinationString:
                            "https://quiet-cornucopia-54f.notion.site/Privacy-Policy-14b9872c5b2880439c2acd10d2b80c24?pvs=4"
                    )
                    CustomLinkRow(
                        label: "Terms of Use", systemImage: "signature",
                        destinationString:
                            "https://quiet-cornucopia-54f.notion.site/Terms-of-Use-Nutzungsbedingungen-14b9872c5b28807caeb5d051fd0a5226?pvs=4"
                    )
                }

                Section(
                    header: Text("Third-Party Libraries"),
                    footer: Text("third_party_libraries_info")
                ) {
                    HStack {
                        Text("Official Joke API")
                        Spacer()
                        Link(
                            "GitHub Repository",
                            destination: URL(
                                string:
                                    "https://github.com/15Dkatz/official_joke_api"
                            )!
                        )
                        .foregroundColor(.blue)
                    }
                }
            }
            //            }
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
        .onAppear {
            selectedTranslationLanguage =
                Language(rawValue: storedTranslationLanguage) ?? .german
        }
        .onChange(of: selectedTranslationLanguage) { newValue in
            storedTranslationLanguage = newValue.rawValue
        }
        .sheet(isPresented: $showRoadmapSheet) {
            RoadmapView(isPresented: $showRoadmapSheet)
        }
        .sheet(isPresented: $showAboutDeveloperSheet) {
            AboutDeveloperView(isPresented: $showAboutDeveloperSheet)
        }
    }
}

struct CustomLinkRow: View {
    var label: String
    var systemImage: String
    var destinationString: String

    var body: some View {
        Link(destination: URL(string: destinationString)!) {
            HStack {
                Label {
                    Text(label)
                } icon: {
                    Image(systemName: systemImage)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(Color("AppPrimary"))
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .foregroundColor(.gray)
            }
        }
    }
}

struct RoadmapView: View {
    @Binding var isPresented: Bool  // Wird genutzt, um das Sheet zu schließen

    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .fill(Color("AppPrimary"))
                    .rotationEffect(.degrees(180))
                    .ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Roadmap")
                            .font(.largeTitle)
                        Text(
                            "Some of these features may be available in the future."
                        )
                        .font(.title2)
                        .padding(.vertical)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Label(
                                "Display only new jokes",
                                systemImage: "circle")
                            Label("Mark jokes as favorites", systemImage: "circle")
                            Label("View your favorite jokes", systemImage: "circle")
                        }
                        .padding(.bottom, 30)
                        
                        Text("Done")
                            .font(.title2)
                            .padding(.vertical)
                        VStack(alignment: .leading, spacing: 15) {
                            Label(
                                "Jokes translated into German",
                                systemImage: "checkmark.circle")
                            Label(
                                "Jokes translated into other languages",
                                systemImage: "checkmark.circle")
                            Label(
                                "Change joke translation in settings",
                                systemImage: "checkmark.circle")
                            Label(
                                "Save translation settings between app launches",
                                systemImage: "checkmark.circle")
                            Label(
                                "App available in English and German",
                                systemImage: "checkmark.circle")
                        }
                        
                        
                        HStack {
                            Spacer()
                            Image("CloudJokeFetcher")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.vertical, 30)
                        
                        Spacer()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                isPresented = false
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                    }
                }
            }
        }
    }
}

struct AboutDeveloperView: View {
    @Binding var isPresented: Bool  // Wird genutzt, um das Sheet zu schließen

    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                
                ZStack {
                    Circle()
                        .fill(Color("AppPrimary").gradient)
                        .frame(width: 150, height: 150)
                    Image("Developer")
                        .resizable()
                        .scaledToFit()
                        .clipShape(.circle)
                        .frame(width: 150)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 100)
//                                .stroke(Color("AppPrimary"), lineWidth: 2)
//                                .shadow(radius: 20)
//                        )
                }
                .padding(.bottom, 40)
                
                Group {
                    Text(
                        "developer_p1"
                    )
                    Text("developer_p2")
                }
                .padding(.vertical)
                .multilineTextAlignment(.center)

                Spacer()

                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                isPresented = false
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    //.foregroundColor(.black.opacity(0.5))
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }
                        }
                    }
            }
            .padding()
            .navigationTitle("About Developer")
            #if iOS
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        #if iOS
        .background(Color(UIColor.systemGroupedBackground)) // Standard Form-Hintergrund
        #endif
        .ignoresSafeArea()
    }
}

#Preview {
    SettingsView()
}
