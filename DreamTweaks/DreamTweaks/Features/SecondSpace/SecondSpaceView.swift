import SwiftUI

struct SecondSpaceView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            SpaceDetailView(engine: appState.secondSpaceEngine)
                .navigationTitle("Second Space")
        }
    }
}

struct SpaceDetailView: View {
    @ObservedObject var engine: DefaultSecondSpaceEngine
    @State private var showingCreateSheet = false

    var body: some View {
        ZStack {
            SpaceCanvas(space: engine.activeSpace)
                .opacity(engine.isTransitioning ? 0 : 1)
                .blur(radius: engine.isTransitioning ? 20 : 0)
                .scaleEffect(engine.isTransitioning ? 1.15 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: engine.isTransitioning)

            VStack {
                SpacePicker(spaces: engine.spaces, activeID: engine.activeSpaceID) { id in
                    engine.switchToSpace(id: id)
                }
                Spacer()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingCreateSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showingCreateSheet) {
            CreateSpaceSheet { name in
                engine.createSpace(named: name)
            }
        }
    }
}

struct SpacePicker: View {
    let spaces: [DreamSpace]
    let activeID: UUID
    let onSelect: (UUID) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(spaces) { space in
                    Button {
                        onSelect(space.id)
                    } label: {
                        Text(space.name)
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(space.id == activeID ? Color.accentColor : Color(.secondarySystemBackground),
                                        in: Capsule())
                            .foregroundStyle(space.id == activeID ? .white : .primary)
                    }
                }
            }
            .padding(16)
        }
    }
}

struct SpaceCanvas: View {
    let space: DreamSpace

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(hex: space.wallpaperColorHex))
                    .frame(height: 160)
                    .overlay(
                        Text(space.name)
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                    )

                Text("Apps").font(.headline)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 18) {
                    ForEach(space.apps) { app in
                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(.tertiarySystemBackground))
                                .frame(width: 56, height: 56)
                                .overlay(Image(systemName: app.systemImage))
                            Text(app.name).font(.caption2)
                        }
                    }
                }

                Text("Notes").font(.headline)
                ForEach(space.notes) { note in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.title).font(.subheadline.weight(.semibold))
                        Text(note.body).font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(16)
            .padding(.top, 60)
        }
    }
}

struct CreateSpaceSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    let onCreate: (String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Space name", text: $name)
            }
            .navigationTitle("New Space")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        onCreate(name.isEmpty ? "New Space" : name)
                        dismiss()
                    }
                }
            }
        }
    }
}

extension Color {
    init(hex: String) {
        var hexValue = UInt64()
        Scanner(string: hex).scanHexInt64(&hexValue)
        let r = Double((hexValue >> 16) & 0xFF) / 255
        let g = Double((hexValue >> 8) & 0xFF) / 255
        let b = Double(hexValue & 0xFF) / 255
        self = Color(red: r, green: g, blue: b)
    }
}
