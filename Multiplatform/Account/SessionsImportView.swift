//
//  SessionsImportView.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 02.10.23.
//

import SwiftUI
import OSLog
import SPFoundation
import SPPersistence

internal struct SessionsImportView: View {
    let logger = Logger(subsystem: "io.rfk.shelfplayer", category: "SessionImport")
    
    var callback: (_ success: Bool) -> ()
    @State var task: Task<(), Error>?
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            ProgressIndicator()
            
            Text("sessions.importing")
                .padding(.top, 8)
                .foregroundStyle(.secondary)
            
            Spacer()
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                task?.cancel()
                callback(false)
            } label: {
                Label("offline.enable", systemImage: "network.slash")
                    .labelStyle(.titleOnly)
                    .contentShape(.rect)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 60)
            }
            .background(Color.accentColor, in: .rect(cornerRadius: 12))
            .foregroundStyle(.background)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .onAppear {
            task = Task.detached {
                let success = await OfflineManager.shared.authorizeAndSync()
                try Task.checkCancellation()
                await callback(success)
            }
        }
    }
}

#Preview {
    SessionsImportView() { _ in }
}
