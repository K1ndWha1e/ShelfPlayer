//
//  Author+Convert.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 04.10.23.
//

import Foundation
import SPFoundation

internal extension Author {
    convenience init(item: AudiobookshelfItem) {
        let addedAt = item.addedAt ?? 0
        
        self.init(
            id: .init(itemID: item.id, episodeID: nil, libraryID: item.libraryId, type: .author),
            name: item.name!,
            description: item.description,
            cover: Cover(item: item),
            addedAt: Date(timeIntervalSince1970: addedAt / 1000),
            bookCount: item.numBooks ?? 0)
    }
}
