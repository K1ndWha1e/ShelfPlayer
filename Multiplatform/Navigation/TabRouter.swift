//
//  TabRouter.swift
//  ShelfPlayer
//
//  Created by Rasmus Krämer on 23.09.24.
//

import Foundation
import SwiftUI
import Defaults
import ShelfPlayerKit

@available(iOS 18, *)
internal struct TabRouter: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @Default(.lastTabValue) private var selection
    @State private var current: Library? {
        didSet {
            let appearance = UINavigationBarAppearance()
            
            if current?.type == .audiobooks && Defaults[.useSerifFont] {
                appearance.titleTextAttributes = [.font: UIFont(descriptor: UIFont.systemFont(ofSize: 17, weight: .bold).fontDescriptor.withDesign(.serif)!, size: 0)]
                appearance.largeTitleTextAttributes = [.font: UIFont(descriptor: UIFont.systemFont(ofSize: 34, weight: .bold).fontDescriptor.withDesign(.serif)!, size: 0)]
            }
            
            appearance.configureWithTransparentBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            
            appearance.configureWithDefaultBackground()
            UINavigationBar.appearance().compactAppearance = appearance
        }
    }
    
    @State private var libraries: [Library] = []
    @State private var libraryPath = NavigationPath()
    
    @State private var accountSheetPresented = false
    
    private func library(for id: String) -> Library? {
        libraries.first(where: { $0.id == id })
    }
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        if !libraries.isEmpty {
            TabView(selection: .init(get: { selection }, set: {
                if $0 == selection, case .search = $0 {
                    NotificationCenter.default.post(name: SearchView.focusNotification, object: nil)
                }
                
                selection = $0
            })) {
                if let current {
                    ForEach(TabValue.tabs(for: current)) { tab in
                        Tab(tab.label, systemImage: tab.image, value: tab) {
                            tab.content(libraryPath: $libraryPath)
                        }
                        .hidden(!isCompact)
                    }
                }
                
                ForEach(libraries) { library in
                    TabSection(library.name) {
                        ForEach(TabValue.tabs(for: library)) { tab in
                            Tab(tab.label, systemImage: tab.image, value: tab) {
                                tab.content(libraryPath: $libraryPath)
                            }
                        }
                    }
                    .hidden(isCompact)
                }
            }
            .tabViewStyle(.sidebarAdaptable)
            .tabViewSidebarBottomBar {
                ZStack {
                    Rectangle()
                        .fill(.bar)
                        .mask {
                            VStack(spacing: 0) {
                                LinearGradient(colors: [.black.opacity(0), .black], startPoint: .top, endPoint: .bottom)
                                    .frame(height: 16)
                                Rectangle()
                                    .fill(.black)
                            }
                        }
                        .ignoresSafeArea(edges: .bottom)
                    
                    HStack(spacing: 16) {
                        Group {
                            Button {
                                accountSheetPresented.toggle()
                            } label: {
                                Label("account", systemImage: "person.crop.circle")
                                    .labelStyle(.iconOnly)
                            }
                            
                            Button {
                                NotificationCenter.default.post(name: SelectLibraryModifier.changeLibraryNotification, object: nil, userInfo: [
                                    "offline": true,
                                ])
                            } label: {
                                Label("offline.enable", systemImage: "network.slash")
                            }
                        }
                        .labelStyle(.iconOnly)
                        .font(.title3)
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                }
            }
            .id(current)
            .modifier(NowPlaying.CompactModifier())
            .modifier(Navigation.NotificationModifier() { libraryID, audiobookID, authorName, authorID, seriesName, seriesID, podcastID, episodeID in
                guard let library = library(for: libraryID) else {
                    return
                }
                
                let previousLibrary = selection?.library
                
                if isCompact {
                    current = library
                }
                
                if library.type == .audiobooks {
                    selection = .audiobookLibrary(library)
                } else if library.type == .podcasts {
                    selection = .podcastLibrary(library)
                }
                
                Task {
                    if previousLibrary != library {
                        try await Task.sleep(nanoseconds: NSEC_PER_SEC / 2)
                    }
                    
                    if let audiobookID {
                        libraryPath.append(Navigation.AudiobookLoadDestination(audiobookId: audiobookID))
                    }
                    if let authorName {
                        libraryPath.append(Navigation.AuthorLoadDestination(authorName: authorName))
                    }
                    if let authorID {
                        libraryPath.append(Navigation.AuthorLoadDestination(authorId: authorID))
                    }
                    if let seriesName {
                        libraryPath.append(Navigation.SeriesLoadDestination(seriesName: seriesName))
                    }
                    if let seriesID {
                        libraryPath.append(Navigation.SeriesLoadDestination(seriesId: seriesID))
                    }
                    
                    if let podcastID {
                        if let episodeID {
                            libraryPath.append(Navigation.EpisodeLoadDestination(episodeId: episodeID, podcastId: podcastID))
                        } else {
                            libraryPath.append(Navigation.PodcastLoadDestination(podcastId: podcastID))
                        }
                    }
                }
            })
            .environment(\.libraries, libraries)
            .environment(\.library, selection?.library ?? .init(id: "", name: "", type: .offline, displayOrder: -1))
            .sheet(isPresented: $accountSheetPresented) {
                AccountSheet()
            }
            .onChange(of: isCompact) {
                if isCompact {
                    current = selection?.library
                } else {
                    current = nil
                }
            }
            .onChange(of: selection?.library) {
                while !libraryPath.isEmpty {
                    libraryPath.removeLast()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: SelectLibraryModifier.changeLibraryNotification)) {
                guard let userInfo = $0.userInfo as? [String: String], let libraryID = userInfo["libraryID"] else {
                    return
                }
                
                guard let library = libraries.first(where: { $0.id == libraryID }) else {
                    return
                }
                
                if isCompact {
                    current = library
                }
                if library.type == .audiobooks {
                    selection = .audiobookHome(library)
                } else if library.type == .podcasts {
                    selection = .podcastHome(library)
                }
            }
            .onReceive(Search.shared.searchPublisher) { (library, search) in
                guard let library else {
                    return
                }
                
                if current == library {
                    return
                }
                
                if isCompact {
                    current = library
                }
                if library.type == .audiobooks {
                    selection = .search(library)
                } else if library.type == .podcasts {
                    selection = .podcastLibrary(library)
                }
                
                Task {
                    try await Task.sleep(for: .milliseconds(500))
                    Search.shared.emit(library: library, search: search)
                }
            }
        } else {
            LoadingView()
                .task {
                    await fetchLibraries()
                }
                .refreshable {
                    await fetchLibraries()
                }
        }
    }
    
    private nonisolated func fetchLibraries() async {
        guard let libraries = try? await AudiobookshelfClient.shared.libraries() else {
            return
        }
        
        await MainActor.withAnimation {
            self.libraries = libraries
            
            if isCompact {
                current = selection?.library ?? libraries.first
            }
        }
    }
}

@available(iOS 18, *)
#Preview {
    TabRouter()
        .environment(NowPlaying.ViewModel())
}
