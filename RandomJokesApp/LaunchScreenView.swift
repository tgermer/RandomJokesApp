import SwiftUI

struct LaunchScreenView: View {
    @State private var jokeColor: Color = Color("AppPrimary")
    var body: some View {
        ZStack {
            Rectangle().fill(jokeColor.gradient)
                .rotationEffect(.degrees(180))
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                Image("CloudLol")
                    .resizable()
                    .scaledToFit()
                    .frame(width:300)
                    .foregroundColor(.white.opacity(0.5))
                Text("Jokes")
                    .fontDesign(.rounded)
                    .textCase(.uppercase)
                    .font(.system(size:60 , weight: .black))
                    .foregroundColor(.white)
                    .padding()
                Spacer()
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}
