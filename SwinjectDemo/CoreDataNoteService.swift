import CoreData
import Foundation

final class CoreDataNoteService: NoteStorageService {
    private let persistentContainer: NSPersistentContainer
    private let entityName = "StoredNote"

    init() {
        let model = Self.makeManagedObjectModel()
        persistentContainer = NSPersistentContainer(name: "JournalStore", managedObjectModel: model)

        persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load persistent store: \(error.localizedDescription)")
            }
        }

        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }

    func saveNote(_ note: Note) {
        let context = persistentContainer.viewContext
        let object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
        object.setValue(note.id, forKey: "id")
        object.setValue(note.text, forKey: "text")
        object.setValue(note.timestamp, forKey: "timestamp")
        saveContext(context)
    }

    func fetchNotes() -> [Note] {
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

        do {
            return try persistentContainer.viewContext.fetch(request).compactMap(Self.makeNote)
        } catch {
            assertionFailure("Failed to fetch notes: \(error.localizedDescription)")
            return []
        }
    }

    func deleteNote(id: UUID) {
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            if let object = try context.fetch(request).first {
                context.delete(object)
                saveContext(context)
            }
        } catch {
            assertionFailure("Failed to delete note: \(error.localizedDescription)")
        }
    }

    private func saveContext(_ context: NSManagedObjectContext) {
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            assertionFailure("Failed to save context: \(error.localizedDescription)")
        }
    }

    private static func makeManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let entity = NSEntityDescription()
        entity.name = "StoredNote"
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)

        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        idAttribute.isOptional = false

        let textAttribute = NSAttributeDescription()
        textAttribute.name = "text"
        textAttribute.attributeType = .stringAttributeType
        textAttribute.isOptional = false

        let timestampAttribute = NSAttributeDescription()
        timestampAttribute.name = "timestamp"
        timestampAttribute.attributeType = .dateAttributeType
        timestampAttribute.isOptional = false

        entity.properties = [idAttribute, textAttribute, timestampAttribute]
        model.entities = [entity]

        return model
    }

    nonisolated private static func makeNote(from object: NSManagedObject) -> Note? {
        guard
            let id = object.value(forKey: "id") as? UUID,
            let text = object.value(forKey: "text") as? String,
            let timestamp = object.value(forKey: "timestamp") as? Date
        else {
            return nil
        }

        return Note(id: id, text: text, timestamp: timestamp)
    }
}
