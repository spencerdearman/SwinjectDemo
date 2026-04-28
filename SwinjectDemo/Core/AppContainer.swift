//
//  AppContainer.swift
//  SwinjectDemo
//
//  Created by Spencer Dearman.
//

import Foundation
import Swinject

final class AppContainer {
    static let premiumFlagKey = "isPremiumUser"
    
    let container = Container()
    let currentTier: AppTier
    
    init(userDefaults: UserDefaults = .standard) {
        currentTier = userDefaults.bool(forKey: Self.premiumFlagKey) ? .journal : .whiteboard
        registerDependencies()
    }
    
    func resolveNotesViewModel() -> NotesViewModel {
        guard let viewModel = container.resolve(NotesViewModel.self) else {
            fatalError("NotesViewModel could not be resolved.")
        }
        
        return viewModel
    }
    
    private func registerDependencies() {
        container.register(NoteStorageService.self) { _ in
            switch self.currentTier {
            case .whiteboard:
                return InMemoryNoteService()
            case .journal:
                return SwiftDataNoteService()
            }
        }
        .inObjectScope(.container)
        
        container.register(NotesViewModel.self) { resolver in
            guard let storageService = resolver.resolve(NoteStorageService.self) else {
                fatalError("NoteStorageService could not be resolved.")
            }
            
            return NotesViewModel(storageService: storageService)
        }
    }
}
