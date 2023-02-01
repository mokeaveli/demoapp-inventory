//
//  AppDelegate.swift
//  Inventory
//
//  Created by Ditto on 6/27/18.
//  Copyright © 2018 Ditto. All rights reserved.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController(rootViewController: MainViewController())
        navigationController.navigationBar.prefersLargeTitles = true
        window?.tintColor = Constants.Colors.mainColor
        window!.rootViewController = navigationController
        window!.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        BackgroundSync.shared.start()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        BackgroundSync.shared.stop()
    }
}
