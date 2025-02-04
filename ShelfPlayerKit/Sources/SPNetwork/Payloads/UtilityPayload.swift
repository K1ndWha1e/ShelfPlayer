//
//  AudiobookshelfClient+Util.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 03.10.23.
//

import Foundation
import SPFoundation

public struct BookmarkPayload: Codable {
    public let libraryItemId: String
    public let title: String
    public let time: Double
    public let createdAt: Double
}

struct HomeRowPayload: Codable {
    let id: String
    let label: String
    let type: String
    let entities: [ItemPayload]
}

// MARK: Responses

struct AuthorizationResponse: Codable {
    let user: User
    
    struct User: Codable {
        let id: String
        let token: String
        let username: String
        
        let bookmarks: [BookmarkPayload]
        let mediaProgress: [ProgressPayload]
    }
}

public struct StatusResponse: Codable, Sendable {
    public let isInit: Bool
    public let authMethods: [String]
    public let serverVersion: String
}

struct MeResponse: Codable {
    let id: String
    let username: String
    let type: String
    
    let isActive: Bool
    let isLocked: Bool
}

struct LibrariesResponse: Codable {
    let libraries: [Library]
    
    struct Library: Codable {
        let id: String
        let name: String
        let mediaType: String
        let displayOrder: Int
    }
}

struct LibraryResponse: Codable {
    let filterdata: Filterdata
}
struct Filterdata: Codable {
    let genres: [String]
}

struct SearchResponse: Codable {
    let book: [SearchLibraryItem]?
    let podcast: [SearchLibraryItem]?
    // let narrators: [AudiobookshelfItem]
    let series: [SearchSeries]?
    let authors: [ItemPayload]?
    
    struct SearchLibraryItem: Codable {
        let libraryItem: ItemPayload
    }
    struct SearchSeries: Codable {
        let series: ItemPayload
        let books: [ItemPayload]
    }
}

struct ResultResponse: Codable {
    let total: Int
    let results: [ItemPayload]
}

struct EpisodesResponse: Codable {
    let episodes: [EpisodePayload]
}

struct AuthorsResponse: Codable {
    let authors: [ItemPayload]
}
