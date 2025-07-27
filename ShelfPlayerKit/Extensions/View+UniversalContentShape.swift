//
//  ContentShapeKinds+Default.swift
//  Multiplatform
//
//  Created by Rasmus Krämer on 04.05.24.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func universalContentShape<S>(_ shape: S) -> some View where S: Shape {
        #if os(macOS)
        self
            .contentShape([.accessibility, .dragPreview, .interaction], shape)
        #else
        self
            .contentShape([.accessibility, .contextMenuPreview, .dragPreview, .hoverEffect, .interaction], shape)
        #endif
    }
}
