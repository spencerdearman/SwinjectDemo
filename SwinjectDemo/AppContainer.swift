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
            return "Notes persist with Core Data on this device."
        }
    }
}

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
                return CoreDataNoteService()
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
