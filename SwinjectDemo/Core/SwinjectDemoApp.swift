//
//  SwinjectDemoApp.swift
//  SwinjectDemo
//
//  Created by Spencer Dearman.
//

import SwiftUI

@main
struct SwinjectDemoApp: App {
    @StateObject private var environment = AppEnvironment()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(environment)
        }
    }
}
