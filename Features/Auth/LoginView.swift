import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = LoginViewModel()
    @State private var showPassword = false

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()

            VStack(spacing: 24) {

                Spacer(minLength: 20)

                // logo
                Image("esprit_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140)

                Text("Connectez-vous à votre espace")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)

                // champs
                VStack(spacing: 16) {
                    // identifiant
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Identifiant")
                            .font(.caption)
                            .foregroundColor(Color(#colorLiteral(red: 0.85, green: 0.16, blue: 0.12, alpha: 1)))
                        TextField("", text: $vm.identifier)
                            .padding(12)
                            .background(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color(#colorLiteral(red: 0.85, green: 0.16, blue: 0.12, alpha: 1)), lineWidth: 1)
                            )
                    }

                    // mot de passe
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Mot de passe")
                            .font(.caption)
                            .foregroundColor(.gray)
                        HStack {
                            Group {
                                if showPassword {
                                    TextField("", text: $vm.password)
                                } else {
                                    SecureField("", text: $vm.password)
                                }
                            }
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            Button {
                                showPassword.toggle()
                            } label: {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(12)
                        .background(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 24)

                // erreur
                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                // bouton
                Button {
                    Task {
                        await vm.login(appState: appState)
                    }
                } label: {
                    Text(vm.isLoading ? "Connexion..." : "Se connecter")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(#colorLiteral(red: 0.85, green: 0.16, blue: 0.12, alpha: 1)))
                        .cornerRadius(999)
                }
                .padding(.horizontal, 24)
                .disabled(vm.isLoading)

                Spacer()
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
}
