//
//  EpisodePlayButton.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 08.10.23.
//

import SwiftUI
import ShelfPlayerKit

struct EpisodePlayButton: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(Satellite.self) private var satellite
    
    let episode: Episode
    let highlighted: Bool
    
    @State private var progress: ProgressTracker
    
    init(episode: Episode, highlighted: Bool = false) {
        self.episode = episode
        self.highlighted = highlighted
        
        _progress = .init(initialValue: .init(itemID: episode.id))
    }
    
    private var isPlaying: Bool {
        satellite.currentItem == episode
    }
    private var isLoading: Bool {
        satellite.isLoading(observing: episode.id)
    }
    
    private var label: String {
        func formatDuration() -> String {
            episode.duration.formatted(.duration(unitsStyle: .brief, allowedUnits: [.hour, .minute], maximumUnitCount: 1))
        }
        
        if let isFinished = progress.isFinished, isFinished {
            return String(localized: "listen.again")
        } else if let progress = progress.progress, progress <= 0 {
            return formatDuration()
        } else if isPlaying, satellite.duration > 0 {
            return (satellite.duration - satellite.currentTime).formatted(.duration(unitsStyle: .brief, allowedUnits: [.hour, .minute, .second], maximumUnitCount: 1))
        } else if let currentTime = progress.currentTime, let progress = progress.progress, progress > 0 {
            return ((self.progress.duration ?? episode.duration) - currentTime).formatted(.duration(unitsStyle: .brief, allowedUnits: [.hour, .minute, .second], maximumUnitCount: 1))
        } else {
            return formatDuration()
        }
    }
    private var icon: String {
        if isPlaying && satellite.isPlaying {
            return "pause.fill"
        }
        
        return "play.fill"
    }
    
    private var progressVisible: Bool {
        if isPlaying {
            return true
        }
        
        if let progress = progress.progress {
            return progress > 0 && progress < 1
        }
        
        return false
    }
    
    @ViewBuilder
    private func text() -> some View {
        HStack(spacing: 0) {
            ZStack {
                Image(systemName: "play.fill")
                    .hidden()
                
                Image(systemName: icon)
                    .contentTransition(.symbolEffect(.replace.downUp.byLayer))
                    .opacity(isLoading ? 0 : 1)
            }
            .overlay {
                if isLoading {
                    ProgressIndicator()
                }
            }
            .controlSize(.small)
            .padding(.trailing, 4)
            
            Rectangle()
                .fill(.gray.opacity(0.25))
                .overlay(alignment: .leading) {
                    if let progress = progress.progress {
                        Rectangle()
                            .frame(width: progressVisible ? max(40 * progress, 5) : 0)
                    }
                }
                .frame(width: progressVisible ? 40 : 0, height: 5)
                .clipShape(.rect(cornerRadius: .infinity))
                .padding(.leading, progressVisible ? 4 : 0)
                .padding(.trailing, progressVisible ? 8 : 0)
            
            Text(label)
                .lineLimit(1)
                .contentTransition(.numericText(countsDown: true))
        }
        .font(.caption2)
    }
    
    var body: some View {
        Button {
            satellite.start(episode)
        } label: {
            text()
                .opacity(highlighted ? 0 : 1)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(highlighted ? .white : .secondary.opacity(0.25))
                .foregroundStyle(highlighted ? .black : .primary)
                .modify {
                    if highlighted {
                        $0
                            .reverseMask {
                                if highlighted {
                                    text()
                                }
                            }
                    } else {
                        $0
                    }
                }
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .clipShape(.rect(cornerRadius: .infinity))
        .modifier(ButtonHoverEffectModifier(cornerRadius: .infinity, hoverEffect: .lift))
    }
}

#if DEBUG
#Preview {
    EpisodePlayButton(episode: Episode.fixture)
        .previewEnvironment()
}

#Preview {
    ZStack {
        Rectangle()
            .fill(.black)
        
        EpisodePlayButton(episode: Episode.fixture, highlighted: true)
    }
    .previewEnvironment()
}
#endif
