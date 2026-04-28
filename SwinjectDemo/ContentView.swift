import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var bootstrapper: AppBootstrapper

    var body: some View {
        ScratchpadScreen(
            viewModel: bootstrapper.notesViewModel,
            currentTier: bootstrapper.currentTier,
            isPremiumEnabled: Binding(
                get: { bootstrapper.isPremiumEnabled },
                set: { bootstrapper.setPremiumEnabled($0) }
            )
        )
    }
}

private struct ScratchpadScreen: View {
    @ObservedObject var viewModel: NotesViewModel
    let currentTier: AppTier
    let isPremiumEnabled: Binding<Bool>
    @State private var draftNote = ""

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 18) {
                    tierHeader
                    composer
                    notesList
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
            }
            .navigationTitle("Daily Notes")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var tierHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(currentTier.title)
                        .font(.system(.title2, design: .rounded, weight: .bold))

                    Text(currentTier.modeDescription)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text("Premium")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Toggle("Premium", isOn: isPremiumEnabled)
                    .labelsHidden()
                    .tint(Color(red: 0.12, green: 0.46, blue: 0.88))
                }
            }

            Text(currentTier.storageSummary)
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text("This screen only talks to NotesViewModel, and the view model only talks to NoteStorageService.")
                .font(.footnote.weight(.medium))
                .foregroundStyle(Color(red: 0.16, green: 0.27, blue: 0.44))
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.45), lineWidth: 1)
        )
    }

    private var composer: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("New Note")
                .font(.headline)

            HStack(spacing: 12) {
                TextField("Begin typing here...", text: $draftNote, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...3)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        viewModel.addNote(text: draftNote)
                        draftNote = ""
                    }
                } label: {
                    Label("Submit", systemImage: "arrow.up")
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.white)
                        .padding(10)
                }
                .glassEffect(.regular.tint(.blue).interactive(), in: .circle)
                .disabled(draftNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(20)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.35), lineWidth: 1)
        )
    }

    private var notesList: some View {
        List {
            if viewModel.notes.isEmpty {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(currentTier == .whiteboard ? "Fresh whiteboard." : "Journal is ready.")
                            .font(.headline)
                        Text(currentTier == .whiteboard ? "Add a few notes, relaunch the app, and they'll be gone." : "Add notes, relaunch the app, and they'll still be here.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 10)
                    .listRowBackground(Color.white.opacity(0.18))
                }
            } else {
                Section {
                    ForEach(viewModel.notes) { note in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(note.text)
                                .font(.body)
                                .foregroundStyle(.primary)

                            Text(note.timestamp.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 6)
                        .listRowBackground(Color.white.opacity(0.18))
                    }
                    .onDelete { offsets in
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                            viewModel.deleteNotes(at: offsets)
                        }
                    }
                } header: {
                    Text("Today's Notes")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.insetGrouped)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.28), lineWidth: 1)
        )
    }
}

#Preview {
    ContentView()
        .environmentObject(AppBootstrapper())
}
