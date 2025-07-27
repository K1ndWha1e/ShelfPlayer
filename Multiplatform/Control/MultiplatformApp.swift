//
//  AudiobooksApp.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 16.09.23.
//

import SwiftUI
import AppIntents
import ShelfPlayback

@main
struct MultiplatformApp: App {
    #if canImport(UIKit)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    init() {
        #if !ENABLE_CENTRALIZED
        ShelfPlayerKit.enableCentralized = false
        #endif
        
        ShelfPlayer.launchHook()
        
        if ProcessInfo.processInfo.environment["RUN_CONVENIENCE_DOWNLOAD"] == "YES" {
            Task {
                await PersistenceManager.shared.convenienceDownload.scheduleAll()
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ShelfPlayerPackage: AppIntentsPackage {
    nonisolated(unsafe) static let includedPackages: [any AppIntentsPackage.Type] = [
        ShelfPlayerKitPackage.self,
    ]
}
