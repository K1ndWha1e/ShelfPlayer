//
//  AudiobookshelfClient+Authors.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 04.10.23.
//

import Foundation
import SPFoundation

public extension AudiobookshelfClient {
    func author(authorId: String) async throws -> Author {
        Author(item: try await request(ClientRequest<ItemPayload>(path: "api/authors/\(authorId)", method: "GET")))
    }
    
    func authors(libraryID: String) async throws -> [Author] {
        try await request(ClientRequest<AuthorsResponse>(path: "api/libraries/\(libraryID)/authors", method: "GET")).authors.map(Author.init)
    }
    
    func authorID(name: String, libraryID: String) async throws -> String {
        let response = try? await request(ClientRequest<SearchResponse>(path: "api/libraries/\(libraryID)/search", method: "GET", query: [
            URLQueryItem(name: "q", value: name),
            URLQueryItem(name: "limit", value: "1"),
        ]))
        
        if let id = response?.authors?.first?.id {
            return id
        }
        
        throw ClientError.missing
    }
    
    func author(authorId: String, libraryID: String) async throws -> (Author, [Audiobook], [Series]) {
        let response = try await request(ClientRequest<ItemPayload>(path: "api/authors/\(authorId)", method: "GET", query: [
            URLQueryItem(name: "library", value: libraryID),
            URLQueryItem(name: "include", value: "items,series"),
        ]))
        
        let author = Author(item: response)
        let audiobooks = (response.libraryItems ?? []).compactMap(Audiobook.init)
        let series = (response.series ?? []).map(Series.init)
        
        return (author, audiobooks, series)
    }
}
