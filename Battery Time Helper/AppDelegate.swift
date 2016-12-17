//
//  AppDelegate.swift
//  Battery Time Helper
//
//  Created by Venj Chu on 16/12/17.
//  Copyright © 2016 Venj. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        var pathComponents = Bundle.main.bundleURL.pathComponents
        pathComponents.removeSubrange((pathComponents.count - 4)..<pathComponents.count)
        let path = NSString.path(withComponents: pathComponents)
        if !isMainAppRunning() {
            NSWorkspace.shared().launchApplication(path)
        }
        NSApp.terminate(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    // MARK: - Private Helper
    private func isMainAppRunning() -> Bool {
        guard let mainIdentifier = mainBundleIdentifier() else { return false }
        return (NSWorkspace.shared().runningApplications.filter { $0.bundleIdentifier == mainIdentifier }).count > 0
    }

    private func mainBundleIdentifier() -> String? {
        let mainBundleInfoPlistURL = Bundle.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("Info.plist")
        guard let data = try? Data(contentsOf:mainBundleInfoPlistURL) else { return nil }
        if let dict = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] {
            return dict?["CFBundleIdentifier"] as? String
        }
        else {
            return nil
        }
    }
}

