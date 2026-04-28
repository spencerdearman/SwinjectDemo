//
//  SwinjectDemoApp.swift
//  SwinjectDemo
//
//  Created by Spencer Dearman on 4/27/26.
//

import SwiftUI

@main
struct SwinjectDemoApp: App {
    @StateObject private var bootstrapper = AppBootstrapper()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bootstrapper)
        }
    }
}
