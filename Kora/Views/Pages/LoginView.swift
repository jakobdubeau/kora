//
//  LoginView.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-01-22.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("Kora")
                .font(.system(size: 72, weight: .medium))
                .fontDesign(.monospaced)
                .padding(.bottom, 22)
            
            HStack {
                Button {
                    
                } label: {
                    HStack(spacing: 4) {
                        Image("GoogleLogoAsset")
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
            
            SignInWithAppleButton(.continue, onRequest: { _ in }, onCompletion: { _ in })
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
                .background(Color(hex: "#090709"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator).opacity(0.5), lineWidth: 0.5))
        }
        .padding(.horizontal, 22)
    }
}
