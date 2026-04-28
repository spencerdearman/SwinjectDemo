# Daily Scratchpad Demo Notes

## What this app proves

`NotesViewModel` depends only on `NoteStorageService`.

That means the presentation logic never needs to know whether notes are stored:

- in memory for a disposable free-tier session
- in Core Data for persistent premium storage

Swinject chooses the implementation at runtime, so the view model stays clean and reusable.

## Architecture map

- `Note.swift`: simple domain model
- `NoteStorageService.swift`: shared storage contract
- `InMemoryNoteService.swift`: Whiteboard tier storage
- `CoreDataNoteService.swift`: Journal tier storage
- `NotesViewModel.swift`: MVVM presentation logic
- `AppContainer.swift`: Swinject registrations and runtime selection
- `AppBootstrapper.swift`: app-level state and container rebuild when the tier changes
- `ContentView.swift`: polished demo UI

## Talking points during code walkthrough

### 1. Start with the protocol

Show `NoteStorageService`.

Explain that the rest of the app programs to this abstraction instead of concrete storage details.

### 2. Show the view model constructor

Show `NotesViewModel.init(storageService:)`.

Key message:

`NotesViewModel` never imports Core Data and never knows whether it received an array-backed or database-backed service.

### 3. Show runtime registration

In `AppContainer`, point out:

- `UserDefaults` decides whether the user is premium
- the container registers `InMemoryNoteService` for free users
- the container registers `CoreDataNoteService` for premium users
- `NotesViewModel` resolves the protocol, not a concrete type

### 4. Show the UI indicator

Use the top card in the app to explain:

- `Whiteboard` = `Unsaved Session`
- `Journal` = `Saved to Device`

This helps the audience connect the dependency graph to visible behavior.

## Live demo flow

### Whiteboard mode

1. Launch with Premium off.
2. Add `Note 1`.
3. Add `Note 2`.
4. Force quit the app.
5. Relaunch.
6. Show that the list is empty.

Narration:

"Same screen, same view model, same add-note action. Only the injected storage implementation changed."

### Journal mode

1. Turn Premium on.
2. Add `Note 3`.
3. Add `Note 4`.
4. Force quit the app.
5. Relaunch.
6. Show that `Note 3` and `Note 4` are still there.

Narration:

"Nothing in the view model changed. Swinject resolved a different implementation at runtime."

## Conclusion line

"Without dependency injection, this logic usually ends up scattered across view controllers or view models with conditionals and tighter coupling. With Swinject, the decision lives in one place, and the feature code stays simple."
