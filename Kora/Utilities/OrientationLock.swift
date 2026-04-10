//
//  OrientationLock.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-04-10.
//

import UIKit

enum OrientationLock {
    static func set(_ orientation: UIInterfaceOrientationMask) {
        KoraAppDelegate.allowedOrientations = orientation
        
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else { return }
        
        scene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        
        scene.requestGeometryUpdate(.iOS(interfaceOrientations: orientation)) { _ in }
    }
}
