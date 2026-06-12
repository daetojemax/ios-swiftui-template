import SwiftUI
import UIKit
import Design
import Client
import Core
import Models
import Navigation

public struct AuthorizationScreen: View {
    @Environment(Auth.self) var auth
    @Environment(NetworkClient.self) var client
    @Environment(AppSimpleRouter.self) var router

    @State private var email = ""
    @State private var password = ""
    @State private var shouldShowValidation = false

    public init() {}

    public var body: some View {
        VStack(spacing: 20) {
            Text("Authorization")
                .font(.sizeTitle1)
                .foregroundStyle(Color.Fill.black)

            Text("Sign in to continue")
                .font(.sizeText)
                .foregroundStyle(Color.Fill.black.opacity(0.55))

            VStack(spacing: 12) {
                formField(
                    title: "Email",
                    text: $email,
                    error: emailValidationMessage,
                    keyboardType: .emailAddress,
                    textContentType: .emailAddress
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

                formField(
                    title: "Password",
                    text: $password,
                    error: passwordValidationMessage,
                    isSecure: true,
                    textContentType: .password
                )
            }
            .padding(.horizontal, 16)

            PrimaryButton(title: "Sign In (Mock)") {
                signIn()
            }
            .padding(.horizontal, 16)

            Button("Don't have an account? Register") {
                router.navigateTo(.registration)
            }
            .font(.sizeBody)
            .foregroundStyle(Color.Fill.purple)

            Spacer()
        }
        .padding(.top, 96)
        .fill(.all)
        .background(Color.Fill.white)
    }
}

// MARK: - Actions

private extension AuthorizationScreen {
    func signIn() {
        shouldShowValidation = true
        guard isFormValid else { return }

        let user = User(
            id: 1,
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            firstName: "Demo",
            lastName: "User"
        )

        auth.setAuthenticated(
            accessToken: "demo-access-token",
            refreshToken: "demo-refresh-token",
            user: user
        )
    }
}

// MARK: - Validation

private extension AuthorizationScreen {
    var isFormValid: Bool {
        emailError == nil && passwordError == nil
    }

    var emailValidationMessage: String? {
        shouldShowValidation ? emailError : nil
    }

    var passwordValidationMessage: String? {
        shouldShowValidation ? passwordError : nil
    }

    var emailError: String? {
        return Email(wrappedValue: email, "Enter a valid email").projectedValue
    }

    var passwordError: String? {
        return Required(wrappedValue: password, "Password is required").projectedValue
    }
}

// MARK: - Form Field

private extension AuthorizationScreen {
    @ViewBuilder
    func formField(
        title: String,
        text: Binding<String>,
        error: String?,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Group {
                if isSecure {
                    SecureField(title, text: text)
                } else {
                    TextField(title, text: text)
                        .keyboardType(keyboardType)
                }
            }
            .textContentType(textContentType)
            .font(.sizeBody)
            .foregroundStyle(Color.Fill.black)
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(Color.Fill.black.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(error == nil ? Color.clear : Color.Fill.purple, lineWidth: 1)
            }

            Text(error ?? " ")
                .font(.sizeCaption)
                .foregroundStyle(Color.Fill.purple)
                .lineLimit(1)
                .opacity(error == nil ? 0 : 1)
                .padding(.horizontal, 4)
        }
    }
}
