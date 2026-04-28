import Combine
import Foundation

@MainActor
final class AppBootstrapper: ObservableObject {
    @Published private(set) var notesViewModel: NotesViewModel
    @Published private(set) var currentTier: AppTier

    private let userDefaults: UserDefaults
    private var appContainer: AppContainer

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        let container = AppContainer(userDefaults: userDefaults)
        appContainer = container
        currentTier = container.currentTier
        notesViewModel = container.resolveNotesViewModel()
    }

    var isPremiumEnabled: Bool {
        currentTier == .journal
    }

    func setPremiumEnabled(_ isEnabled: Bool) {
        userDefaults.set(isEnabled, forKey: AppContainer.premiumFlagKey)
        rebuildContainer()
    }

    private func rebuildContainer() {
        let container = AppContainer(userDefaults: userDefaults)
        appContainer = container
        currentTier = container.currentTier
        notesViewModel = container.resolveNotesViewModel()
    }
}
