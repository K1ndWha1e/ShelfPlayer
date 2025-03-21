//
//  QueuePlayButton.swift
//  Multiplatform
//
//  Created by Rasmus Krämer on 29.01.25.
//

import SwiftUI
import ShelfPlayerKit

struct QueuePlayButton: View {
    @Environment(Satellite.self) private var satellite
    
    let item: PlayableItem
    
    var body: some View {
        Button("queue.play", systemImage: "play.fill") {
            satellite.start(item.id)
        }
        .disabled(satellite.isLoading(observing: item.id))
    }
}
