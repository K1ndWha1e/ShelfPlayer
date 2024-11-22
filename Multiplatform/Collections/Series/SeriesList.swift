//
//  SeriesList.swift
//  iOS
//
//  Created by Rasmus Krämer on 03.02.24.
//

import SwiftUI
import SPFoundation

internal struct SeriesList: View {
    let series: [Series]
    var onAppear: ((_ audiobook: Series) -> Void)? = nil
    
    var body: some View {
        ForEach(series) { item in
            NavigationLink(destination: SeriesView(item)) {
                ListItem(series: item)
            }
            .listRowInsets(.init(top: 8, leading: 20, bottom: 8, trailing: 20))
            .onAppear {
                onAppear?(item)
            }
        }
    }
}

internal extension SeriesList {
    struct ListItem: View {
        let name: String
        let covers: [Cover]
        let itemCount: Int
        
        init(series: Series) {
            self.name = series.name
            self.covers = series.covers
            
            itemCount = covers.count
        }
        
        init(name: String, covers: [Cover], itemCount: Int) {
            self.name = name
            self.covers = covers
            self.itemCount = itemCount
        }
        
        private var coverCount: Int {
            min(covers.count, 4)
        }
        private var leadingPadding: CGFloat {
            if coverCount > 3 {
                return 54
            } else if coverCount > 2 {
                return 42
            } else if coverCount > 1 {
                return 28
            } else if coverCount > 0 {
                return 12
            }
            
            return 0
        }
        
        var body: some View {
            HStack(spacing: 0) {
                ZStack {
                    ForEach(0..<coverCount, id: \.hashValue) {
                        let index = (coverCount - 1) - $0
                        let factor: CGFloat = index == 0 ? 1 : index == 1 ? 0.9 : index == 2 ? 0.8 : index == 3 ? 0.7 : 0
                        let offset: CGFloat = index == 0 ? 0 : index == 1 ? 16  : index == 2 ? 30  : index == 3 ? 42  : 0
                        let radius: CGFloat = index == 0 ? 8 : index == 1 ? 7   : index == 2 ? 6    : index == 3 ? 5     : 0
                        
                        ItemImage(cover: covers[$0], cornerRadius: radius)
                            .frame(height: 60)
                            .scaleEffect(factor)
                            .offset(x: offset)
                    }
                }
                .frame(height: 60)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .modifier(SerifModifier())
                    
                    Text("series.count \(itemCount)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.leading, leadingPadding)
            }
        }
    }
}
    
#if DEBUG
#Preview {
    NavigationStack {
        List {
            SeriesList(series: .init(repeating: [.fixture], count: 7))
        }
        .listStyle(.plain)
    }
}
#endif
