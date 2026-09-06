import SwiftUI

struct EnergyHistoryView: View {
    @Environment(HealthKit.self) private var healthKit
    @State private var showsNewRecord = false
    let kind: EnergyKind

    var body: some View {
        List {
            Section {
                EnergyChartView(kind: kind, days: healthKit.energyRecords[kind] ?? [])
                    .listRowInsets(.init())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            if let error = healthKit.energyErrors[kind] {
                Section {
                    Text(error)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Daily Totals") {
                ForEach(healthKit.energyRecords[kind] ?? []) {
                    EnergyDayRowView(day: $0, kind: kind)
                }
            }
        }
        .navigationTitle(kind.title)
        .toolbar {
            if kind == .dietary {
                Button("Add Dietary Energy", systemImage: "plus") {
                    showsNewRecord = true
                }
            }
        }
        .sheet(isPresented: $showsNewRecord) {
            NewRecordSheet(.dietaryEnergy)
                .environment(healthKit)
        }
        .refreshable { await healthKit.refreshEnergy(for: kind) }
        .task { await healthKit.refreshEnergy(for: kind) }
    }
}
