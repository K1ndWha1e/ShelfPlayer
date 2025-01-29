//
//  ContentView.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 16.09.23.
//

import SwiftUI
import Intents
import CoreSpotlight
import SwiftData
import Defaults
import RFNotifications
import ShelfPlayerKit

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @Default(.tintColor) private var tintColor
    
    @State private var satellite = Satellite()
    
    @State private var connectionStore = ConnectionStore()
    
    // try? await OfflineManager.shared.attemptListeningTimeSync()
    // try? await UserContext.run()
    // try? await BackgroundTaskHandler.updateDownloads()
    
    var body: some View {
        Group {
            if !connectionStore.didLoad {
                LoadingView()
            } else if connectionStore.flat.isEmpty {
                WelcomeView()
            } else if satellite.isOffline {
                NavigationStack {
                    List {
                        ConnectionManager()
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    Button("offline.disable") {
                        satellite.isOffline = false
                    }
                }
            } else {
                TabRouter(selection: $satellite.lastTabValue)
            }
        }
        .tint(tintColor.color)
        .sensoryFeedback(.error, trigger: satellite.notifyError)
        .sensoryFeedback(.success, trigger: satellite.notifySuccess)
        .environment(satellite)
        .onContinueUserActivity(CSSearchableItemActionType) {
            guard let identifier = $0.userInfo?[CSSearchableItemActivityIdentifier] as? String else {
                return
            }
            
            ""
        }
        .onContinueUserActivity("io.rfk.shelfPlayer.item") { activity in
            guard let identifier = activity.persistentIdentifier else {
                return
            }
            
            ""
        }
        .environment(connectionStore)
    }
}

#Preview {
    ContentView()
}
