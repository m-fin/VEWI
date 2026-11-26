//
//  AppDelegate.swift
//  VEWI
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let nav = window?.rootViewController as? UINavigationController, let game = nav.viewControllers.first {
            let launch = LaunchViewController()
            launch.gameViewController = game
            nav.setViewControllers([launch], animated: false)
        }
        if let url = launchOptions?[.url] as? URL {
            open(url)
        }
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        guard url.scheme?.lowercased() == "vewi" else { return false }
        open(url)
        return true
    }

    /// vewi://play opens the horn. vewi://chart opens the fingering chart.
    /// The home-screen widget uses vewi://play.
    private func open(_ url: URL) {
        guard let nav = window?.rootViewController as? UINavigationController else { return }
        let host = url.host?.lowercased() ?? "play"
        if host == "chart" {
            if nav.topViewController is FingeringChartViewController { return }
            nav.popToRootViewController(animated: false)
            nav.pushViewController(FingeringChartViewController(style: .insetGrouped), animated: false)
            return
        }
        if nav.topViewController is GameViewController { return }
        nav.popToRootViewController(animated: false)
        if let launch = nav.viewControllers.first as? LaunchViewController, let game = launch.gameViewController {
            nav.pushViewController(game, animated: false)
        }
    }
}
