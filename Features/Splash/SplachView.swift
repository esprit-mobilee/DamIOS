import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()

            VStack(spacing: 16) {
                Image("esprit_logo") // ajoute l’image dans Assets avec ce nom
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180)

                Text("Se former autrement")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    SplashView()
}
