//
//  AuthorView+Header.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 06.10.23.
//

import SwiftUI
import SPFoundation

internal extension AuthorView {
    struct Header: View {
        @Environment(AuthorViewModel.self) private var viewModel
        
        var body: some View {
            VStack(spacing: 0) {
                ItemImage(item: viewModel.author, cornerRadius: .infinity)
                    .frame(width: 100, height: 100)
                
                Text(viewModel.author.name)
                    .modifier(SerifModifier())
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    .padding(.horizontal, 20)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text(verbatim: "")
                        }
                    }
                
                if let description = viewModel.author.description {
                    Button {
                        viewModel.descriptionSheetVisible.toggle()
                    } label: {
                        Text(description)
                            .lineLimit(3)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}
