//
//  SwiftDataNoteService.swift
//  SwinjectDemo
//
//  Created by Spencer Dearman.
//

import Foundation
import SwiftData

final class SwiftDataNoteService: NoteStorageService {
    @Model
    final class StoredNoteRecord {
        @Attribute(.unique) var id: UUID
        var text: String
        var timestamp: Date
        
        init(id: UUID, text: String, timestamp: Date) {
            self.id = id
            self.text = text
            self.timestamp = timestamp
        }
    }
    
    private let modelContext: ModelContext
    
    init() {
        do {
            let schema = Schema([StoredNoteRecord.self])
            let configuration = ModelConfiguration("JournalStore", schema: schema, isStoredInMemoryOnly: false)
            let modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            modelContext = ModelContext(modelContainer)
        } catch {
            fatalError("Failed to create SwiftData container: \(error.localizedDescription)")
        }
    }
    
    func saveNote(_ note: Note) {
        let record = StoredNoteRecord(id: note.id, text: note.text, timestamp: note.timestamp)
        modelContext.insert(record)
        saveContext()
    }
    
    func fetchNotes() -> [Note] {
        let descriptor = FetchDescriptor<StoredNoteRecord>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor).map(Self.makeNote)
        } catch {
            assertionFailure("Failed to fetch notes: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteNote(id: UUID) {
        let descriptor = FetchDescriptor<StoredNoteRecord>(
            predicate: #Predicate { record in
                record.id == id
            }
        )
        
        do {
            if let record = try modelContext.fetch(descriptor).first {
                modelContext.delete(record)
                saveContext()
            }
        } catch {
            assertionFailure("Failed to delete note: \(error.localizedDescription)")
        }
    }
    
    private func saveContext() {
        guard modelContext.hasChanges else { return }
        
        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to save SwiftData context: \(error.localizedDescription)")
        }
    }
    
    nonisolated private static func makeNote(from record: StoredNoteRecord) -> Note {
        Note(id: record.id, text: record.text, timestamp: record.timestamp)
    }
}
