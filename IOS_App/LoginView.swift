import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email: String = ""
    @State private var showingSuccess: Bool = false
    @FocusState private var isEmailFocused: Bool
    @AppStorage("newsletterOptIn") private var newsletterOptIn: Bool = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Logo/Icon
                VStack(spacing: 16) {
                    Image(systemName: "newspaper.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue)
                        .shadow(color: .blue.opacity(0.3), radius: 10)
                    
                    Text("EtherWorld")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Stay updated with Ethereum news")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Login Options
                VStack(spacing: 20) {
                    // Apple Sign In
                    SignInWithAppleButton(
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authorization):
                                authManager.signInWithApple(authorization: authorization)
                                showSuccess()
                            case .failure(let error):
                                authManager.errorMessage = error.localizedDescription
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .cornerRadius(12)
                    
                    // Google Sign In (Placeholder)
                    Button {
                        Task {
                            await authManager.signInWithGoogle()
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "g.circle.fill")
                                .font(.system(size: 20))
                            Text("Continue with Google")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                        Text("or")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.vertical, 8)
                    
                    // Email Sign In
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sign in with email")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter your email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .focused($isEmailFocused)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        Text("We'll send you a magic link to sign in")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Toggle(isOn: $newsletterOptIn) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Weekly newsletter (optional)")
                                    .fontWeight(.semibold)
                                Text("Get a concise recap of the week delivered to your inbox.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .padding(.top, 4)
                    }
                    
                    Button {
                        isEmailFocused = false
                        Task {
                            await authManager.sendMagicLink(email: email)
                            if authManager.isAuthenticated {
                                showSuccess()
                            }
                        }
                    } label: {
                        HStack {
                            if authManager.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Continue")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(email.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(email.isEmpty || authManager.isLoading)
                    
                    if let error = authManager.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Footer
                VStack(spacing: 8) {
                    Text("By continuing, you agree to our")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Link("Terms of Service & Privacy Policy", destination: URL(string: "https://etherworld.co/privacy")!)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 32)
            }
        }
        .overlay {
            if showingSuccess {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Welcome!")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(40)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(radius: 20)
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: showingSuccess)
    }
    
    private func showSuccess() {
        showingSuccess = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showingSuccess = false
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
}
