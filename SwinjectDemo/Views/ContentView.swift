//
//  ContentView.swift
//  SwinjectDemo
//
//  Created by Spencer Dearman.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var environment: AppEnvironment
    
    var body: some View {
        ScratchpadScreen(
            viewModel: environment.notesViewModel,
            currentTier: environment.currentTier,
            isPremiumEnabled: Binding(
                get: { environment.isPremiumEnabled },
                set: { environment.setPremiumEnabled($0) }
            )
        )
    }
}
