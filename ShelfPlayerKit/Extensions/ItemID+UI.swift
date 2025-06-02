//
//  ItemID+UI.swift
//  ShelfPlayer
//
//  Created by Rasmus Krämer on 02.06.25.
//

import Foundation
import SwiftUI

public extension ItemIdentifier.ItemType {
    var label: String {
        switch self {
            case .audiobook:
                String(localized: "item.audiobook")
            case .author:
                String(localized: "item.author")
            case .narrator:
                String(localized: "item.narrator")
            case .series:
                String(localized: "item.series")
            case .podcast:
                String(localized: "item.podcast")
            case .episode:
                String(localized: "item.episode")
        }
    }
    var icon: String {
        switch self {
            case .audiobook:
                "book"
            case .author:
                "person"
            case .narrator:
                "microphone.fill"
            case .series:
                "rectangle.grid.2x2"
            case .podcast:
                "square.stack"
            case .episode:
                "play.square"
        }
    }
}
