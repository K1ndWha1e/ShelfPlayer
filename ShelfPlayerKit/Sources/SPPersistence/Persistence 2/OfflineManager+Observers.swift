//
//  OfflineManager+Observers.swift
//  ShelfPlayerKit
//
//  Created by Rasmus Krämer on 08.11.24.
//

import Foundation
import SPFoundation
import SPPersistence

public extension OfflineManager {
    func setupFinishedRemoveObserver() {
        NotificationCenter.default.addObserver(forName: PlayableItem.finishedNotification, object: nil, queue: nil) {
            guard let userInfo = $0.userInfo, let itemID = userInfo["itemID"] as? String, userInfo["finished"] as? Bool == true else {
                return
            }
            
            let episodeID = userInfo["episodeID"] as? String
            
            if UserDefaults.standard.bool(forKey: "deleteFinishedDownloads") {
                if let episodeID {
                    OfflineManager.shared.remove(episodeId: episodeID)
                } else {
                    OfflineManager.shared.remove(audiobookId: itemID)
                }
            }
        }
    }
}
