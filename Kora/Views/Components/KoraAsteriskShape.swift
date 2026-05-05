//
//  KoraAsteriskShape.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-04-14.
//

import SwiftUI

struct KoraAsteriskShape: Shape {
    private static let viewBox: CGFloat = 1024

    func path(in rect: CGRect) -> Path {
        let scale = min(rect.width, rect.height) / Self.viewBox
        let cx = rect.midX
        let cy = rect.midY
        let outerR = 307.0 * scale
        let innerR = 75.0 * scale
        let halfAng: CGFloat = 23.2 * .pi / 180

        var path = Path()
        for i in 0..<5 {
            let armAngle = CGFloat(i) * 2 * .pi / 5 + .pi / 2
            let p0 = CGPoint(x: cx + outerR * cos(armAngle - halfAng),
                             y: cy + outerR * sin(armAngle - halfAng))
            let p1 = CGPoint(x: cx + innerR * cos(armAngle),
                             y: cy + innerR * sin(armAngle))
            let p2 = CGPoint(x: cx + outerR * cos(armAngle + halfAng),
                             y: cy + outerR * sin(armAngle + halfAng))

            if i == 0 { path.move(to: p0) } else { path.addLine(to: p0) }
            path.addLine(to: p1)
            path.addLine(to: p2)
        }
        path.closeSubpath()
        return path
    }
}

struct AnimatedKoraAsterisk: View {
    let color: Color
    let size: CGFloat

    @State private var rotation: CGFloat = 0
    @State private var breathScale: CGFloat = 1

    var body: some View {
        KoraAsteriskShape()
            .fill(color)
            .frame(width: size, height: size)
            .scaleEffect(breathScale)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 7).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
                withAnimation(.easeInOut(duration: 1.7).repeatForever(autoreverses: true)) {
                    breathScale = 1.05
                }
            }
    }
}

#Preview {
    AnimatedKoraAsterisk(color: .red, size: 72)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
}
