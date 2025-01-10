//
//  AuthorView.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 05.10.23.
//

import SwiftUI
import Defaults
import ShelfPlayerKit

struct AuthorView: View {
    @Environment(\.library) private var library
    
    @State private var viewModel: AuthorViewModel
    
    init(_ author: Author, series: [Series] = [], audiobooks: [Audiobook] = []) {
        viewModel = .init(author: author, series: series, audiobooks: audiobooks)
    }
    
    var loadingPresentation: some View {
        VStack(spacing: 0) {
            Header()
            LoadingView()
        }
    }
    
    var gridPresentation: some View {
        ScrollView {
            Header()
            
            if !viewModel.audiobooks.isEmpty {
                HStack(spacing: 0) {
                    RowTitle(title: String(localized: "books"), fontDesign: .serif)
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.horizontal, 20)
                
                AudiobookVGrid(sections: viewModel.audiobooks)
                    .padding(.horizontal, 20)
            }
            
            if !viewModel.series.isEmpty {
                HStack(spacing: 0) {
                    RowTitle(title: String(localized: "series"), fontDesign: .serif)
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.horizontal, 20)
                
                SeriesGrid(series: viewModel.series)
                    .padding(.horizontal, 20)
            }
        }
    }
    var listPresentation: some View {
        List {
            Header()
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            if !viewModel.audiobooks.isEmpty {
                RowTitle(title: String(localized: "books"), fontDesign: .serif)
                    .listRowSeparator(.hidden, edges: .top)
                    .listRowInsets(.init(top: 16, leading: 20, bottom: 0, trailing: 20))
                
                AudiobookList(sections: viewModel.audiobooks)
            }
            
            if !viewModel.series.isEmpty {
                RowTitle(title: String(localized: "series"), fontDesign: .serif)
                    .listRowSeparator(.hidden, edges: .top)
                    .listRowInsets(.init(top: 16, leading: 20, bottom: 0, trailing: 20))
                
                SeriesList(series: viewModel.series)
            }
        }
        .listStyle(.plain)
    }
    
    var body: some View {
        Group {
            if viewModel.audiobooks.isEmpty {
                loadingPresentation
            } else {
                switch viewModel.displayMode {
                    case .grid:
                        gridPresentation
                    case .list:
                        listPresentation
                }
            }
        }
        .navigationTitle(viewModel.author.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                AudiobookSortFilter(filter: $viewModel.filter, displayType: $viewModel.displayMode, sortOrder: $viewModel.sortOrder, ascending: $viewModel.ascending)
            }
        }
        // .modifier(NowPlaying.SafeAreaModifier())
        .sensoryFeedback(.error, trigger: viewModel.errorNotify)
        .environment(viewModel)
        .environment(\.displayContext, .author(author: viewModel.author))
        .onAppear {
            viewModel.library = library
        }
        .task {
            // await viewModel.load()
        }
        .refreshable {
            // await viewModel.load()
        }
        .sheet(isPresented: $viewModel.descriptionSheetVisible) {
            NavigationStack {
                ScrollView {
                    HStack(spacing: 0) {
                        if let description = viewModel.author.description {
                            Text(description)
                        } else {
                            Text("description.unavailable")
                        }
                        
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                }
                .navigationTitle(viewModel.author.name)
                .presentationDragIndicator(.visible)
            }
        }
        .userActivity("io.rfk.shelfplayer.author") {
            $0.title = viewModel.author.name
            $0.isEligibleForHandoff = true
            // $0.persistentIdentifier = viewModel.author.id
            // $0.targetContentIdentifier = convertIdentifier(item: viewModel.author)
            $0.userInfo = [:
                // "libraryID": viewModel.author.libraryID,
                // "authorID": viewModel.author.id,
            ]
            // $0.webpageURL = viewModel.author.url
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        AuthorView(.fixture)
    }
}
#endif
