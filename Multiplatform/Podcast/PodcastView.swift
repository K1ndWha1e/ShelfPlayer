//
//  PodcastView.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 08.10.23.
//

import SwiftUI
import Defaults
import ShelfPlayerKit

struct PodcastView: View {
    @Environment(\.library) private var library
    @Environment(\.namespace) private var namespace
    
    let zoom: Bool
    
    @State private var viewModel: PodcastViewModel
    
    init(_ podcast: Podcast, episodes: [Episode] = [], zoom: Bool) {
        self.zoom = zoom
        _viewModel = .init(initialValue: .init(podcast: podcast, episodes: episodes))
    }
    
    var body: some View {
        List {
            Header()
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            if viewModel.episodes.isEmpty {
                ProgressIndicator()
            } else {
                HStack {
                    Text("episodes")
                        .bold()
                    
                    NavigationLink {
                        PodcastEpisodesView()
                            .environment(viewModel)
                    } label: {
                        HStack {
                            Spacer()
                            Text("episodes.all")
                        }
                    }
                }
                .padding(.horizontal, 20)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                EpisodeSingleList(episodes: viewModel.visible)
            }
        }
        .listStyle(.plain)
        .ignoresSafeArea(edges: .top)
        .modify {
            if zoom {
                $0
                    .navigationTransition(.zoom(sourceID: "item_\(viewModel.podcast.id)", in: namespace!))
            } else {
                $0
            }
        }
        .modifier(ToolbarModifier())
        // .modifier(NowPlaying.SafeAreaModifier())
        .environment(viewModel)
        .task {
            viewModel.load()
        }
        .refreshable {
            viewModel.load()
        }
        .sheet(isPresented: $viewModel.descriptionSheetPresented) {
            NavigationStack {
                ScrollView {
                    HStack(spacing: 0) {
                        if let description = viewModel.podcast.description {
                            Text(description)
                        } else {
                            Text("description.unavailable")
                        }
                        
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                }
                .navigationTitle(viewModel.podcast.name)
                .presentationDragIndicator(.visible)
            }
        }
        .sheet(isPresented: $viewModel.settingsSheetPresented) {
            PodcastSettingsSheet(podcastID: viewModel.podcast.id)
        }
        .userActivity("io.rfk.shelfPlayer.item") { activity in
            activity.title = viewModel.podcast.name
            activity.isEligibleForHandoff = true
            activity.persistentIdentifier = viewModel.podcast.id.description
            
            Task {
                try await activity.webpageURL = viewModel.podcast.id.url
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        PodcastView(Podcast.fixture, episodes: .init(repeating: .fixture, count: 7), zoom: true)
    }
    .previewEnvironment()
}
#endif
