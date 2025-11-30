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

                Image("esprit_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140)

                Text("Connectez-vous à votre espace")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)

                VStack(spacing: 16) {

                    // EMAIL
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Email")
                            .font(.caption)
                            .foregroundColor(Color(#colorLiteral(red: 0.85, green: 0.16, blue: 0.12, alpha: 1)))

                        TextField("email@esprit.tn", text: $vm.email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(12)
                            .background(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color(#colorLiteral(red: 0.85, green: 0.16, blue: 0.12, alpha: 1)), lineWidth: 1)
                            )
                    }

                    // PASSWORD
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Mot de passe")
                            .font(.caption)
                            .foregroundColor(.gray)

                        HStack {
                            if showPassword {
                                TextField("••••••", text: $vm.password)
                            } else {
                                SecureField("••••••", text: $vm.password)
                            }

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

                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

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
        .environmentObject(AppState.shared)
}
