//
//  AudiobookView.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 04.10.23.
//

import SwiftUI
import ShelfPlayerKit

internal struct AudiobookView: View {
    @Environment(\.library) private var library
    @Environment(\.defaultMinListRowHeight) private var minimumHeight
    
    @State private var viewModel: AudiobookViewModel
    
    internal init(_ audiobook: Audiobook) {
        _viewModel = .init(initialValue: .init(audiobook: audiobook))
    }
    
    private let divider: some View = Divider()
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Header()
                    .padding(.horizontal, 20)
                
                divider
                
                Description(description: viewModel.audiobook.description)
                    .padding(.horizontal, 20)
                
                divider
                
                if viewModel.chapters.count > 1 {
                    DisclosureGroup("\(viewModel.chapters.count) chapters", isExpanded: $viewModel.chaptersVisible) {
                        List {
                            Chapters(item: viewModel.audiobook, chapters: viewModel.chapters)
                        }
                        .listStyle(.plain)
                        .frame(height: minimumHeight * CGFloat(viewModel.chapters.count))
                    }
                    .disclosureGroupStyle(BetterDisclosureGroupStyle())
                    .padding(.bottom, 16)
                    .padding(.horizontal, 20)
                }
                
                DisclosureGroup("timeline", isExpanded: $viewModel.sessionsVisible) {
                    Timeline(item: viewModel.audiobook, sessions: viewModel.sessions)
                        .padding(.top, 8)
                }
                .disclosureGroupStyle(BetterDisclosureGroupStyle(horizontalLabelPadding: 20))
                
                VStack(spacing: 12) {
                    ForEach(Array(viewModel.sameSeries.keys), id: \.self) { series in
                        AudiobookRow(title: String(localized: "audiobook.similar.series \(series.name)"), small: true, audiobooks: viewModel.sameSeries[series]!)
                    }
                    ForEach(Array(viewModel.sameAuthor.keys), id: \.self) { author in
                        AudiobookRow(title: String(localized: "audiobook.similar.author \(author.name)"), small: true, audiobooks: viewModel.sameAuthor[author]!)
                    }
                    ForEach(Array(viewModel.sameNarrator.keys), id: \.self) { narrator in
                        AudiobookRow(title: String(localized: "audiobook.similar.narrator \(narrator)"), small: true, audiobooks: viewModel.sameNarrator[narrator]!)
                    }
                }
                .padding(.vertical, 16)
                .background(.background.secondary)
                .padding(.top, 12)
                
                Spacer()
            }
        }
        // .modifier(NowPlaying.SafeAreaModifier())
        .modifier(ToolbarModifier())
        .sensoryFeedback(.error, trigger: viewModel.errorNotify)
        .environment(viewModel)
        .onAppear {
            viewModel.library = library
        }
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
        .userActivity("io.rfk.shelfplayer.audiobook") {
            $0.title = viewModel.audiobook.name
            $0.isEligibleForHandoff = true
            // $0.persistentIdentifier = viewModel.audiobook.id
            // $0.targetContentIdentifier = convertIdentifier(item: viewModel.audiobook)
            $0.userInfo = [
                // "libraryID": viewModel.audiobook.libraryID,
                "audiobookID": viewModel.audiobook.id,
            ]
            // $0.webpageURL = viewModel.audiobook.url
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        AudiobookView(.fixture)
    }
}
#endif
