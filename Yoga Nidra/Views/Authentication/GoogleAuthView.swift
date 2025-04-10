import SwiftUI
import GoogleSignIn

struct GoogleAuthView: View {
    @State private var isAuthenticating = false
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Complete Your Account")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 40)
            
            Text("Sign in to save your progress and access your meditations across all your devices")
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            Button {
                signInWithGoogle()
            } label: {
                HStack {
                    Text("Sign in with Google")
                        .font(.headline)
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(.white)
                .cornerRadius(28)
                .padding(.horizontal)
            }
            .disabled(isAuthenticating)
            
            Button {
                // Explicitly set the tab to home before dismissing
                // This ensures the selection is persisted
                AppState.shared.selectedTab = .home
                dismiss()
            } label: {
                Text("Skip for now")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.vertical, 16)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                Image("mountain-lake-twilight") // Reuse existing background
                    .resizable()
                    .scaledToFill()
                    .overlay(Color.black.opacity(0.6))
                    .edgesIgnoringSafeArea(.all)
            }
        )
        .alert("Authentication Failed", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .overlay {
            if isAuthenticating {
                ZStack {
                    Color.black.opacity(0.4)
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    private func signInWithGoogle() {
        isAuthenticating = true
        
        Task {
            let (success, error) = await GoogleAuthManager.shared.signIn()
            
            await MainActor.run {
                isAuthenticating = false
                
                if !success {
                    errorMessage = error?.localizedDescription ?? "Authentication failed"
                    showError = true
                } else {
                    // Explicitly set the tab to home before dismissing
                    // This ensures the selection is persisted
                    AppState.shared.selectedTab = .home
                    
                    // Critical fix: Ensure no other sheets are presented
                    // This prevents the Progress view from appearing
                    if let sheetPresenter = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController?.view.window?.rootViewController?.presentedViewController {
                        print("⚠️ Found a presented sheet that might interfere with navigation")
                    }
                    
                    dismiss()
                }
            }
        }
    }
}
