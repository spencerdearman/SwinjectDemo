//
//  AppTier.swift
//  SwinjectDemo
//
//  Created by Spencer Dearman.
//

import Foundation
import Swinject

enum AppTier: String {
    case whiteboard
    case journal
    
    var title: String {
        switch self {
        case .whiteboard:
            return "Whiteboard"
        case .journal:
            return "Journal"
        }
    }
    
    var modeDescription: String {
        switch self {
        case .whiteboard:
            return "Unsaved Session"
        case .journal:
            return "Saved to Device"
        }
    }
    
    var storageSummary: String {
        switch self {
        case .whiteboard:
            return "Notes live only in memory for this session."
        case .journal:
            return "Notes persist with SwiftData on this device."
        }
    }
}
