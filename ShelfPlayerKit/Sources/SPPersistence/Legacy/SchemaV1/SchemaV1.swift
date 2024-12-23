//
//  SchemaV1.swift
//  ShelfPlayerKit
//
//  Created by Rasmus Krämer on 26.11.24.
//

import Foundation
import SwiftData

@available(*, deprecated, renamed: "SchemaV2", message: "Outdated schema")
public enum SchemaV1: VersionedSchema {
    public static var versionIdentifier: Schema.Version {
        .init(1, 2, 0)
    }
    public static var models: [any PersistentModel.Type] {[
        OfflineTrack.self,
        OfflineChapter.self,
        
        Bookmark.self,
        OfflineProgress.self,
        
        OfflineAudiobook.self,
        
        OfflinePodcast.self,
        OfflineEpisode.self,
        
        PlaybackSpeedOverride.self,
        PodcastFetchConfiguration.self,
        OfflineListeningTimeTracker.self,
    ]}
}
