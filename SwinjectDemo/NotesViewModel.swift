import Combine
import Foundation

@MainActor
final class NotesViewModel: ObservableObject {
    @Published private(set) var notes: [Note] = []

    private let storageService: NoteStorageService

    init(storageService: NoteStorageService) {
        self.storageService = storageService
        loadNotes()
    }

    func loadNotes() {
        notes = storageService.fetchNotes()
    }

    func addNote(text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedText.isEmpty == false else { return }

        let note = Note(id: UUID(), text: trimmedText, timestamp: Date())
        storageService.saveNote(note)
        loadNotes()
    }

    func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            storageService.deleteNote(id: notes[index].id)
        }

        loadNotes()
    }
}
