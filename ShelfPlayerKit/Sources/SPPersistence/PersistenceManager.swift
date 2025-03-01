//
//  PersistenceManager.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 02.10.23.
//

import Foundation
import SwiftData
import SPFoundation

public final class PersistenceManager: Sendable {
    public let keyValue: KeyValueSubsystem
    public let authorization: AuthorizationSubsystem
    
    public let progress: ProgressSubsystem
    public let session: SessionSubsystem
    
    public let download: DownloadSubsystem
    public let item: ItemSubsystem
    public let podcasts: PodcastSubsystem
    
    private init() {
        let schema = Schema(versionedSchema: SchemaV2.self)
        
        let modelConfiguration = ModelConfiguration("ShelfPlayerUpdated",
                           schema: schema,
                           isStoredInMemoryOnly: false,
                           allowsSave: true,
                           groupContainer: ShelfPlayerKit.enableCentralized ? .identifier(ShelfPlayerKit.groupContainer) : .none,
                           cloudKitDatabase: .none)
        
        #if DEBUG
        // try! FileManager.default.removeItem(at: modelConfiguration.url)
        #endif
        
        let container = try! ModelContainer(for: schema, migrationPlan: nil, configurations: [
            modelConfiguration,
        ])
        
        keyValue = .init(modelContainer: container)
        authorization = .init(modelContainer: container)
        
        progress = .init(modelContainer: container)
        session = .init(modelContainer: container)
        
        download = .init(modelContainer: container)
        item = .init()
        podcasts = .init()
    }
}

enum PersistenceError: Error {
    case missing
    case existing
    
    case busy
    
    case unsupportedDownloadCodec
    case unsupportedDownloadItemType
    
    case serverNotFound
    case keychainInsertFailed
    case keychainRetrieveFailed
}

// MARK: Singleton

public extension PersistenceManager {
    static let shared = PersistenceManager()
}
