//
//  Audiobook+Convert.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 03.10.23.
//

import Foundation
import SPFoundation

internal extension Audiobook {
    convenience init?(item: AudiobookshelfItem) {
        guard let media = item.media else {
            return nil
        }
        
        // This filters out e-books but gives items the benefit of the doubt
        guard media.numAudioFiles ?? media.audioFiles?.count ?? 1 > 0 else {
            return nil
        }
        
        var resolvedSeries = [ReducedSeries]()
        
        if let series = item.media?.metadata.series, !series.isEmpty {
            resolvedSeries += series.map {
                let name = $0.name!
                
                if let seq = $0.sequence, let sequence = Float(seq) {
                    return Audiobook.ReducedSeries(id: $0.id, name: name, sequence: sequence)
                } else {
                    return Audiobook.ReducedSeries(id: $0.id, name: name, sequence: nil)
                }
            }
        }
        
        if let seriesName = item.media?.metadata.seriesName {
            let series = ReducedSeries.parse(seriesName: seriesName)
            
            for series in series {
                if !resolvedSeries.contains(where: { $0.name == series.name }) {
                    resolvedSeries.append(series)
                }
            }
        }
        
        let addedAt = item.addedAt ?? 0
        let duration = media.duration ?? 0
        
        self.init(
            id: .init(itemID: item.id, episodeID: nil, libraryID: item.libraryId, type: .audiobook),
            name: media.metadata.title!,
            authors: media.metadata.authorName?.split(separator: ", ").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } ?? [],
            description: media.metadata.description?.trimmingCharacters(in: .whitespacesAndNewlines),
            cover: Cover(item: item),
            genres: media.metadata.genres,
            addedAt: Date(timeIntervalSince1970: addedAt / 1000),
            released: media.metadata.publishedYear,
            size: item.size!,
            duration: duration,
            narrators: media.metadata.narratorName?
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .components(separatedBy: ", ")
                .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty } ?? [],
            series: resolvedSeries,
            explicit: item.media?.metadata.explicit ?? false,
            abridged: item.media?.metadata.abridged ?? false)
    }
}
