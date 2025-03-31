//
//  CarPlayControlelr.swift
//  Multiplatform
//
//  Created by Rasmus Krämer on 19.10.24.
//

import Foundation
@preconcurrency import CarPlay
import ShelfPlayerKit

class CarPlayController {
    private let interfaceController: CPInterfaceController
    
    private let tabBar: CarPlayTabBar
    private let nowPlayingController: CarPlayNowPlayingController
    
    init(interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        
        tabBar = .init(interfaceController: interfaceController)
        nowPlayingController = .init(interfaceController: interfaceController)
        
        Task {
            // try await interfaceController.setRootTemplate(tabBar.template, animated: false)
        }
    }
}
