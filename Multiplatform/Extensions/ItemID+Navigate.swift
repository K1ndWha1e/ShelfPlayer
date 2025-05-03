//
//  ItemID+Navigate.swift
//  Multiplatform
//
//  Created by Rasmus Krämer on 04.03.25.
//

import Foundation
import ShelfPlayerKit

extension ItemIdentifier {
    @MainActor
    func navigateIsolated() {
        RFNotification[.navigateNotification].send(payload: self)
    }
    func navigate() {
        Task {
            await navigateIsolated()
        }
    }
    func navigate() async {
        await navigateIsolated()
    }
}
