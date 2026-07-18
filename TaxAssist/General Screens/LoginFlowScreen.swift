import SwiftUI
import AuthenticationServices
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

#if canImport(UIKit)
import UIKit
#endif

struct LoginFlowScreen: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPasswordStep: Bool = false
    
    @State private var showTermsOfService: Bool = false
    @State private var showPrivacyPolicy: Bool = false
    
    @State private var isSecure: Bool = true
    @State private var rememberMe: Bool = false
    
    @State private var errorMessage: String = ""
    
    @AppStorage("customBackgroundPreset") private var customBackgroundPreset: String = "white"
    @AppStorage("customTextHue") private var customTextHue: Double = 0.58
    @AppStorage("accessibilityLargerText") private var accessibilityLargerText: Bool = false
    @AppStorage("accessibilityBoldText") private var accessibilityBoldText: Bool = false
    @AppStorage("accessibilityReduceMotion") private var accessibilityReduceMotion: Bool = false
    @AppStorage("accessibilityNumericKeypad") private var accessibilityNumericKeypad: Bool = true
    
    private var customBackgroundColor: Color {
        switch customBackgroundPreset {
        case "blue": return Color.blue.opacity(0.15)
        case "black": return Color.black.opacity(0.9)
        case "sky": return Color(red: 0.75, green: 0.88, blue: 1.0)
        default: return .white
        }
    }
    private var contrastingForegroundColor: Color {
        #if canImport(UIKit)
        let ui = UIColor(customBackgroundColor)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if ui.getRed(&r, green: &g, blue: &b, alpha: &a) {
            let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
            return luminance < 0.5 ? .white : .black
        } else {
            var white: CGFloat = 0
            ui.getWhite(&white, alpha: nil)
            return white < 0.5 ? .white : .black
        }
        #else
        return .primary
        #endif
    }
    private var customTextColor: Color {
        #if canImport(UIKit)
        let base = Color(hue: customTextHue, saturation: 0.85, brightness: 0.9)
        let fg = UIColor(contrastingForegroundColor)
        let bs = UIColor(base)
        var fr: CGFloat = 0, fgG: CGFloat = 0, fb: CGFloat = 0, fa: CGFloat = 0
        var br: CGFloat = 0, bg: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 0
        bs.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
        fg.getRed(&fr, green: &fgG, blue: &fb, alpha: &fa)
        let mix: (CGFloat, CGFloat) -> CGFloat = { (u, c) in min(max(u * 0.75 + c * 0.25, 0), 1) }
        let rr = mix(br, fr), gg = mix(bg, fgG), bb2 = mix(bb, fb)
        return Color(red: rr, green: gg, blue: bb2)
        #else
        return Color(hue: customTextHue, saturation: 0.85, brightness: 0.9)
        #endif
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.blue, lineWidth: 5)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.blue)
                }
                
                HStack(spacing: 0) {
                    Text("Tax").foregroundColor(.black)
                    Text("Assist").foregroundColor(.blue)
                }
                .font(.system(size: 44, weight: .bold))
            }
            .padding(.bottom, 24)
            
            if !showPasswordStep {
                emailEntryView
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading),
                        removal: .move(edge: .leading))
                    )
            } else {
                passwordEntryView
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .trailing))
                    )
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .background(customBackgroundColor.ignoresSafeArea())
        .animation(accessibilityReduceMotion ? nil : .easeInOut(duration: 0.3), value: showPasswordStep)
        .sheet(isPresented: $showTermsOfService) {
            TermsOfServiceScreen()
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyScreen()
        }
    }
    
    private var emailEntryView: some View {
        VStack(spacing: 20) {
            VStack(spacing: 6) {
                Text("Create an account")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Enter your email to sign up for this app")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 4)
            
            TextField("email@domain.com", text: $email)
                .padding(.horizontal)
                .frame(height: 50)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(UIColor.systemGray4), lineWidth: 1))
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            Button(action: {
                if !email.isEmpty { showPasswordStep = true }
            }) {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(customTextColor)
                    .cornerRadius(10)
            }
            .opacity(email.isEmpty ? 0.6 : 1.0)
            .disabled(email.isEmpty)
            
            HStack {
                VStack { Divider() }
                Text("or")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                VStack { Divider() }
            }
            .padding(.vertical, 4)
            
            VStack(spacing: 12) {
                Button(action: {
                    errorMessage = ""
                    
                    guard let clientID = FirebaseApp.app()?.options.clientID else {
                        errorMessage = "Firebase configuration error."
                        return
                    }
                    
                    let config = GIDConfiguration(clientID: clientID)
                    GIDSignIn.sharedInstance.configuration = config
                    
                    guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                          let window = windowScene.windows.first(where: { $0.isKeyWindow }),
                          let rootViewController = window.rootViewController else {
                        errorMessage = "Could not find active window."
                        return
                    }
                    
                    GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
                        if let error = error {
                            errorMessage = error.localizedDescription
                            return
                        }
                        
                        guard let user = signInResult?.user,
                              let idToken = user.idToken?.tokenString else {
                            errorMessage = "Could not retrieve Google token."
                            return
                        }
                        
                        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
                        
                        Auth.auth().signIn(with: credential) { result, error in
                            if let error = error {
                                errorMessage = error.localizedDescription
                            } else {
                                print("Successfully logged in with Google!")
                            }
                        }
                    }
                }) {
                    HStack(spacing: 12) {
                        Image("GoogleLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .scaleEffect(1.3)
                        
                        Text("Continue with Google")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                            .frame(width: 170, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                }
                
                Button(action: { print("Apple Login tapped") }) {
                    HStack(spacing: 12) {
                        Image(systemName: "applelogo")
                            .font(.system(size: 22))
                            .foregroundColor(.black)
                            .offset(y: -1)
                        
                        Text("Continue with Apple")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                            .frame(width: 170, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                }
            }
            
            Spacer()
                .frame(minHeight: 20, maxHeight: 60)
            
            VStack(spacing: 4) {
                HStack(spacing: 0) {
                    Text("By clicking continue, you agree to our ")
                        .foregroundColor(.gray)
                    
                    Button(action: { showTermsOfService = true }) {
                        Text("Terms of Service")
                            .foregroundColor(customTextColor)
                            .underline()
                    }
                }
                
                HStack(spacing: 0) {
                    Text("and ")
                        .foregroundColor(.gray)
                    
                    Button(action: { showPrivacyPolicy = true }) {
                        Text("Privacy Policy")
                            .foregroundColor(customTextColor)
                            .underline()
                    }
                }
            }
            .font(.footnote)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
        }
        .multilineTextAlignment(.center)
    }
    
    private var passwordEntryView: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: {
                    showPasswordStep = false
                    errorMessage = ""
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(customTextColor)
                        .font(.system(size: 18, weight: .semibold))
                }
                Spacer()
            }
            
            VStack(spacing: 6) {
                Text("Enter your password")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Signing in as **\(email)**")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 4)
            
            HStack(spacing: 0) {
                Group {
                    if isSecure {
                        SecureField("Password", text: $password)
                    } else {
                        TextField("Password", text: $password)
                    }
                }
                .textContentType(.password)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(.horizontal)
                
                Button(action: { isSecure.toggle() }) {
                    Image(systemName: isSecure ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 16)
                }
            }
            .frame(height: 50)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(UIColor.systemGray4), lineWidth: 1))
            
            Toggle(isOn: $rememberMe) {
                Text("Remember me")
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
            .tint(.blue)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: {
                errorMessage = ""
                
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        let errCode = (error as NSError).code
                        if errCode == AuthErrorCode.emailAlreadyInUse.rawValue {
                            Auth.auth().signIn(withEmail: email, password: password) { signResult, signError in
                                if let signError = signError {
                                    errorMessage = signError.localizedDescription
                                } else {
                                    print("Successfully logged in existing user: \(email)")
                                }
                            }
                        } else {
                            errorMessage = error.localizedDescription
                        }
                    } else {
                        print("Successfully created NEW user: \(email)")
                    }
                }
            }) {
                Text("Sign In")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(customTextColor)
                    .cornerRadius(10)
            }
            .opacity(password.isEmpty ? 0.6 : 1.0)
            .disabled(password.isEmpty)
            
            Button("Forgot password?") {
                errorMessage = ""
                
                guard !email.isEmpty else {
                    errorMessage = "Please enter your email to reset your password."
                    return
                }
                
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                    } else {
                        errorMessage = "✅ Password reset email sent! Check your inbox."
                    }
                }
            }
            .font(.subheadline)
            .foregroundColor(customTextColor)
            .padding(.top, 4)
        }
    }
}

#Preview {
    LoginFlowScreen()
}
