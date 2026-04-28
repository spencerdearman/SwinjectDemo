//
//  Note.swift
//  SwinjectDemo
//
//  Created by Spencer Dearman.
//

import Foundation

struct Note: Identifiable, Equatable {
    let id: UUID
    let text: String
    let timestamp: Date
}
