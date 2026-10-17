import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: WorkoutStore
    @State private var reps = 0
    @State private var showSaved = false

    var body: some View {
        TabView {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 28) {
                        VStack(spacing: 8) {
                            Text("A little stronger, every day.")
                                .font(.headline).foregroundStyle(.secondary)
                            Text("\(store.total()) / \(store.goal)")
                                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                                .accessibilityLabel("\(store.total()) of \(store.goal) push-ups today")
                            ProgressView(value: Double(min(store.total(), store.goal)), total: Double(store.goal))
                                .tint(.orange)
                            Text("TODAY’S GOAL").font(.caption.weight(.semibold))
                        }
                        .padding().background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 24))

                        VStack(spacing: 16) {
                            Text("Current set").font(.title2.bold())
                            Text(reps.formatted())
                                .font(.system(size: 80, weight: .bold, design: .rounded))
                                .contentTransition(.numericText())
                                .accessibilityLabel("\(reps) repetitions in current set")
                            Button {
                                if reps < 10000 { reps += 1 }
                                showSaved = false
                            } label: {
                                Label("Count a push-up", systemImage: "plus")
                                    .font(.title3.bold()).frame(maxWidth: .infinity).padding()
                            }
                            .buttonStyle(.borderedProminent).tint(.orange)
                            .disabled(reps >= 10000)
                            HStack {
                                Button("Undo", systemImage: "arrow.uturn.backward") { reps -= 1 }
                                    .disabled(reps == 0)
                                Spacer()
                                Button("Save set", systemImage: "checkmark") {
                                    if store.add(reps: reps) {
                                        reps = 0
                                        showSaved = true
                                    }
                                }.disabled(reps == 0)
                            }.buttonStyle(.bordered)
                            if showSaved {
                                Label("Set saved", systemImage: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                            Text("Tap to count, or use the stepper to log a completed set. Save before closing the app.")
                                .font(.footnote).foregroundStyle(.secondary)
                            Stepper("Repetitions: \(reps)", value: $reps, in: 0...10000)
                        }
                    }.padding()
                }.navigationTitle("Pushup")
            }.tabItem { Label("Today", systemImage: "figure.strengthtraining.functional") }

            NavigationStack {
                List {
                    if store.sets.isEmpty {
                        ContentUnavailableView("Your first set starts here", systemImage: "clock",
                            description: Text("Save a set from Today to build your history."))
                    } else {
                        Section("Saved sets · swipe to delete") {
                            ForEach(store.sets) { set in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(set.date, style: .date)
                                        Text(set.date, style: .time).font(.caption).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text("\(set.reps) reps").font(.headline)
                                }
                            }.onDelete { offsets in
                                store.delete(ids: Set(offsets.map { store.sets[$0].id }))
                            }
                        }
                    }
                }.navigationTitle("History")
            }.tabItem { Label("History", systemImage: "clock") }

            NavigationStack {
                Form {
                    Section("Daily goal") {
                        Stepper("\(store.goal) push-ups", value: Binding(
                            get: { store.goal }, set: { store.setGoal($0) }), in: 1...1000)
                    }
                    Section("Your data") {
                        Text("Saved sets stay on this device in the app’s local storage. No account, analytics, or cloud sync. Deleting the app removes its local data; device backups may include it.")
                    }
                }.navigationTitle("Settings")
            }.tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .alert("Storage issue", isPresented: Binding(
            get: { store.errorMessage != nil },
            set: { if !$0 { store.errorMessage = nil } })) {
                Button("OK") { store.errorMessage = nil }
            } message: { Text(store.errorMessage ?? "") }
    }
}
