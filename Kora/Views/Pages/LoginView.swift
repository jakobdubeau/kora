//
//  LoginView.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

import SwiftUI
import AuthenticationServices

private struct StarField: View {
    private struct Star: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
    }

    private let stars: [Star] = [
        Star(x: 0.10, y: 0.12, size: 28),
        Star(x: 0.12, y: 0.31, size: 30),
        Star(x: 0.24, y: 0.20, size: 22),
        Star(x: 0.37, y: 0.14, size: 26),
        Star(x: 0.46, y: 0.26, size: 20),
        Star(x: 0.62, y: 0.17, size: 32),
        Star(x: 0.76, y: 0.24, size: 28),
        Star(x: 0.78, y: 0.11, size: 20),
        Star(x: 0.88, y: 0.30, size: 24),
        Star(x: 0.91, y: 0.16, size: 26),

        Star(x: 0.12, y: 0.76, size: 24),
        Star(x: 0.16, y: 0.90, size: 22),
        Star(x: 0.33, y: 0.85, size: 28),
        Star(x: 0.51, y: 0.79, size: 24),
        Star(x: 0.60, y: 0.93, size: 22),
        Star(x: 0.70, y: 0.84, size: 20),
        Star(x: 0.84, y: 0.91, size: 23),
        Star(x: 0.88, y: 0.77, size: 30),
    ]
    
    private let blank: [Star] = [
        
    ]

    var body: some View {
        GeometryReader { geo in
            ForEach(blank) { star in
                KoraAsteriskShape()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: star.size, height: star.size)
                    .position(x: star.x * geo.size.width, y: star.y * geo.size.height)
            }
        }
        .ignoresSafeArea()
    }
}


struct LoginView: View {
    
    @Environment(AppCoordinator.self) private var coordinator
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var authViewModel = AuthViewModel()
    @State private var isResolving = false
    private let profileService = SupabaseProfileService()
    
    var body: some View {
        ZStack {
            StarField()
            VStack(alignment: .center, spacing: 16) {
                Text("Kora")
                    .font(.system(size: 72, weight: .medium))
                    .fontDesign(.monospaced)
                    .padding(.bottom, 22)
                
                HStack {
                    Button {
                        Task {
                            isResolving = true
                            defer { isResolving = false }

                            if let session = await authViewModel.signInWithGoogle() {
                                coordinator.session = session

                                if let userId = coordinator.userId {
                                    do {
                                        coordinator.profile = try await profileService.fetchProfile(userId: userId)
                                        coordinator.state = coordinator.profile == nil ? .onboarding : .main
                                    } catch {
                                        coordinator.state = .main
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image("GoogleLogoTAsset")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                            Text("Continue with Google")
                                .font(.system(size: 18, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.15), lineWidth: 0.5))
                    }
                    .buttonStyle(.plain)
                }
                
                SignInWithAppleButton(.continue) { request in
                    authViewModel.prepareAppleRequest(request)
                } onCompletion: { result in
                    Task {
                        isResolving = true
                        defer { isResolving = false }
                        
                        if let session = await authViewModel.handleAppleCompletion(result) {
                            coordinator.session = session

                            if let userId = coordinator.userId {
                                do {
                                    coordinator.profile = try await profileService.fetchProfile(userId: userId)
                                    coordinator.state = coordinator.profile == nil ? .onboarding : .main
                                } catch {
                                    coordinator.state = .main
                                }
                            }
                        }
                    }
                }
                    .frame(height: 46)
                    .signInWithAppleButtonStyle(.white)
                    .cornerRadius(14)
                
                HStack(alignment: .center) {
                    Rectangle()
                        .foregroundStyle(Color(.separator).opacity(0.5))
                        .frame(height: 1)
                        .padding(.horizontal, 8)
                    Text("OR")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.secondary)
                    Rectangle()
                        .foregroundStyle(Color(.separator).opacity(0.5))
                        .frame(height: 1)
                        .padding(.horizontal, 8)
                }
                
                TextField("Your Email", text: $email)
                    .font(.system(size: 18, weight: .regular))
                    .multilineTextAlignment(TextAlignment.center)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(Color(hex: "#090909"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator).opacity(0.5), lineWidth: 0.5))
                
                Button {
                    coordinator.continueAsGuest()
                } label: {
                    HStack(spacing: 4) {
                        Text("Skip for now")
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(.separator))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .disabled(authViewModel.isLoading || isResolving)
            .padding(.horizontal, 22)
        }
    }
}

#Preview {
    LoginView()
        .environment(AppCoordinator())
}
