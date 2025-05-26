//
//  Environment+Keys.swift
//  Multiplatform
//
//  Created by Rasmus Krämer on 26.08.24.
//

import Foundation
import SwiftUI
import Defaults
import ShelfPlayerKit

extension EnvironmentValues {
    @Entry var library: Library? = nil    
    @Entry var displayContext: DisplayContext = .unknown
    
    @Entry var connectionID: ItemIdentifier.ConnectionID? = nil
    
    @Entry var playbackBottomOffset: CGFloat = 0
}

enum DisplayContext {
    case unknown
    case person(person: Person)
    case series(series: Series)
}

extension RFNotification.IsolatedNotification {
    static var focusSearchField: IsolatedNotification<RFNotificationEmptyPayload> { .init("io.rfk.shelfPlayer.focusSearchField") }
    
    static var navigate: IsolatedNotification<ItemIdentifier> { .init("io.rfk.shelfPlayer.navigate.one") }
    static var navigateConditionMet: IsolatedNotification<RFNotificationEmptyPayload> { .init("io.rfk.shelfPlayer.navigate.notify") }
    static var _navigate: IsolatedNotification<ItemIdentifier> { .init("io.rfk.shelfPlayer.navigate.two") }
    
    static var changeLibrary: IsolatedNotification<Library> { .init("io.rfk.shelfPlayer.changeLibrary") }
    static var changeOfflineMode: IsolatedNotification<Bool> { .init("io.rfk.shelfPlayer.changeOfflineMode") }
    
    static var reloadImages: IsolatedNotification<ItemIdentifier?> { .init("io.rfk.shelfPlayer.reloadImages") }
    static var performBackgroundSessionSync: IsolatedNotification<ItemIdentifier.ConnectionID?> { .init("io.rfk.shelfPlayer.performBackgroundSessionSync") }
}
