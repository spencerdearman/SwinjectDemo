import Foundation

protocol NoteStorageService {
    func saveNote(_ note: Note)
    func fetchNotes() -> [Note]
    func deleteNote(id: UUID)
}
