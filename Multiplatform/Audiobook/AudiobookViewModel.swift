//
//  AudiobookViewModel.swift
//  iOS
//
//  Created by Rasmus Krämer on 02.02.24.
//

import Foundation
import SwiftUI
import RFVisuals
import ShelfPlayerKit
import SPPlayback

@Observable @MainActor
internal final class AudiobookViewModel: Sendable {
    private(set) var audiobook: Audiobook
    var library: Library!
    
    private(set) var dominantColor: Color?
    
    var toolbarVisible: Bool
    var chaptersVisible: Bool
    var sessionsVisible: Bool
    
    var chapters: [Chapter]
    var supplementaryPDFs: [PlayableItem.SupplementaryPDF]
    
    private(set) var sameAuthor: [Author: [Audiobook]]
    private(set) var sameSeries: [Audiobook.SeriesFragment: [Audiobook]]
    private(set) var sameNarrator: [String: [Audiobook]]
    
    private(set) var progressEntity: ProgressEntity.UpdatingProgressEntity?
    private(set) var downloadTracker: DownloadTracker?
    
    private(set) var sessions: [SessionPayload]
    private(set) var errorNotify: Bool
    
    @MainActor
    init(audiobook: Audiobook) {
        self.audiobook = audiobook
        
        dominantColor = nil
        
        toolbarVisible = false
        chaptersVisible = false
        sessionsVisible = false
        
        chapters = []
        supplementaryPDFs = []
        
        sameAuthor = [:]
        sameSeries = [:]
        sameNarrator = [:]
        
        sessions = []
        errorNotify = false
        
        Task {
            progressEntity = await PersistenceManager.shared.progress[audiobook.id].updating
        }
    }
}

extension AudiobookViewModel {
    nonisolated func load() {
        Task {
            await withTaskGroup(of: Void.self) {
                $0.addTask { await self.loadAudiobook() }
                
                $0.addTask { await self.loadAuthors() }
                $0.addTask { await self.loadSeries() }
                $0.addTask { await self.loadNarrators() }
                
                $0.addTask { await self.loadSessions() }
                $0.addTask { await self.extractColor() }
                
                await $0.waitForAll()
            }
        }
    }
    
    func play() {
        Task { [audiobook] in
            do {
                try await AudioPlayer.shared.play(audiobook)
            } catch {
                await MainActor.run {
                    errorNotify.toggle()
                }
            }
        }
    }
    
    func resetProgress() {
        Task {
            do {
                // try await audiobook.resetProgress()
            } catch {
                await MainActor.run {
                    errorNotify.toggle()
                }
            }
        }
    }
}

private extension AudiobookViewModel {
    func loadAudiobook() async {
        guard let (item, _, chapters, supplementaryPDFs) = try? await ABSClient[audiobook.id.connectionID].playableItem(itemID: audiobook.id) else {
            return
        }
        
        await MainActor.withAnimation {
            self.audiobook = item as! Audiobook
            self.chapters = chapters
            self.supplementaryPDFs = supplementaryPDFs
        }
    }
    
    func loadAuthors() async {
        var resolved = [Author: [Audiobook]]()
        
        for author in await audiobook.authors {
            do {
                // let authorID = try await AudiobookshelfClient.shared.authorID(name: author, libraryID: audiobook.libraryID)
                // let (author, audiobooks, _) = try await AudiobookshelfClient.shared.author(authorId: authorID, libraryID: audiobook.libraryID)
                
                // resolved[author] = audiobooks
            } catch {
                
            }
        }
        
        await MainActor.withAnimation {
            self.sameAuthor = resolved
        }
    }
    
    func loadSeries() async {
        var resolved = [Audiobook.SeriesFragment: [Audiobook]]()
        
        for series in await audiobook.series {
            do {
                let seriesID: String
                
                if let id = series.id {
                    seriesID = id
                } else {
                    // seriesID = try await AudiobookshelfClient.shared.seriesID(name: series.name, libraryID: audiobook.libraryID)
                }
                
                // let audiobooks = try await AudiobookshelfClient.shared.audiobooks(seriesID: seriesID, libraryID: self.audiobook.libraryID).0
                // resolved[series] = audiobooks
            } catch {
                continue
            }
        }
        
        await MainActor.withAnimation {
            self.sameSeries = resolved
        }
    }
    
    func loadNarrators() async {
        var resolved = [String: [Audiobook]]()
        
        for narrator in await audiobook.narrators {
            do {
                // resolved[narrator] = try await AudiobookshelfClient.shared.audiobooks(narratorName: narrator, libraryID: self.audiobook.libraryID)
            } catch {
                continue
            }
        }
        
        await MainActor.withAnimation {
            self.sameNarrator = resolved
        }
    }
    
    func extractColor() async {
        /*
        guard let image = await audiobook.cover?.platformImage else {
            return
        }
         */
        
        /*
        guard let colors = try? await RFKVisuals.extractDominantColors(4, image: image) else {
            return
        }
        
        let filtered = RFKVisuals.brightnessExtremeFilter(colors.map { $0.color }, threshold: 0.1)
        
        guard let result = RFKVisuals.determineMostSaturated(filtered) else {
            return
        }
        
        await MainActor.withAnimation {
            self.dominantColor = result
        }
         */
    }
    
    func loadSessions() async {
        /*
        guard let sessions = try? await AudiobookshelfClient.shared.listeningSessions(for: audiobook.id, episodeID: nil) else {
            return
        }
        
        await MainActor.withAnimation {
            self.sessions = sessions
        }
         */
    }
}
