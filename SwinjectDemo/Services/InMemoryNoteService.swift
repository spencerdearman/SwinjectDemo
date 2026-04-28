//
//  InMemoryNoteService.swift
//  SwinjectDemo
//
//  Created by Spencer Dearman.
//

import Foundation

final class InMemoryNoteService: NoteStorageService {
    private var notes: [Note] = []
    
    func saveNote(_ note: Note) {
        notes.insert(note, at: 0)
    }
    
    func fetchNotes() -> [Note] {
        notes.sorted { $0.timestamp > $1.timestamp }
    }
    
    func deleteNote(id: UUID) {
        notes.removeAll { $0.id == id }
    }
}
