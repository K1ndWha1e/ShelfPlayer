//
//  PlayButtonStyle.swift
//  Multiplatform
//
//  Created by Rasmus Krämer on 29.01.25.
//

import SwiftUI
import ShelfPlayback

protocol PlayButtonStyle: Sendable {
    associatedtype MenuBody: View
    associatedtype LabelBody: View
    
    typealias Configuration = PlayButtonConfiguration
    
    @ViewBuilder
    func makeMenu(configuration: Self.Configuration) -> Self.MenuBody
    @ViewBuilder
    func makeLabel(configuration: Self.Configuration) -> Self.LabelBody
    
    var cornerRadius: CGFloat { get }
    
    var tint: Bool { get }
    var hideRemainingWhenUnplayed: Bool { get }
}
extension PlayButtonStyle where Self == LargePlayButtonStyle {
    static var large: LargePlayButtonStyle { .init() }
}
extension PlayButtonStyle where Self == MediumPlayButtonStyle {
    static var medium: MediumPlayButtonStyle { .init() }
}

struct AnyPlayButtonStyle: PlayButtonStyle {
    private var _makeMenu: @Sendable (Configuration) -> AnyView
    private var _makeLabel: @Sendable (Configuration) -> AnyView
    
    private var _cornerRadius: CGFloat
    
    private var _tint: Bool
    private var _hideRemainingWhenUnplayed: Bool
    
    init<S: PlayButtonStyle>(style: S) {
        _makeMenu = { configuration in
            AnyView(style.makeMenu(configuration: configuration))
        }
        _makeLabel = { configuration in
            AnyView(style.makeLabel(configuration: configuration))
        }
        
        _tint = style.tint
        _cornerRadius = style.cornerRadius
        _hideRemainingWhenUnplayed = style.hideRemainingWhenUnplayed
    }
    
    func makeMenu(configuration: Configuration) -> some View {
        _makeMenu(configuration)
    }
    func makeLabel(configuration: Configuration) -> some View {
        _makeLabel(configuration)
    }
    
    var cornerRadius: CGFloat {
        _cornerRadius
    }
    
    var tint: Bool {
        _tint
    }
    var hideRemainingWhenUnplayed: Bool {
        _hideRemainingWhenUnplayed
    }
}

extension EnvironmentValues {
    @Entry var playButtonStyle: AnyPlayButtonStyle = .init(style: LargePlayButtonStyle())
}

struct PlayButtonConfiguration {
    let progress: Percentage?
    let background: Color
    
    struct Content: View {
        init<Content: View>(content: Content) {
            body = AnyView(content)
        }
        
        var body: AnyView
    }
    
    let content: PlayButtonConfiguration.Content
}
