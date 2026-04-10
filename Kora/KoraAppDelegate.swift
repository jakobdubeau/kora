//
//  KoraAppDelegate.swift
//  Kora
//
//  Created by Jakob Dubeau on 2026-04-10.
//

import UIKit

final class KoraAppDelegate: NSObject, UIApplicationDelegate {
      static var allowedOrientations: UIInterfaceOrientationMask = .portrait
    
      func application(
          _ application: UIApplication,
          supportedInterfaceOrientationsFor window: UIWindow?
      ) -> UIInterfaceOrientationMask {
          KoraAppDelegate.allowedOrientations
      }
  }
