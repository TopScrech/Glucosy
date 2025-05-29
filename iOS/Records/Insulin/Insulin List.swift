import ScrechKit

struct InsulinList: View {
    @Environment(HealthKit.self) private var vm
    
    @State private var sheetNewRecord = false
    
    var body: some View {
        let dayChunks = vm.insulinRecords.chunked { lhs, rhs in
            Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
        }
        
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(dayChunks.indices, id: \.self) { index in
                    let chunk = dayChunks[index]
                    
                    if let first = chunk.first {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(Utils.formattedDate(first.date))
                                .title3(.semibold, design: .rounded)
                                .padding(.horizontal)
                            
                            LazyVGrid(
                                columns: [
                                    GridItem(
                                        .adaptive(minimum: 60),
                                        spacing: 0
                                    )
                                ],
                                spacing: 12
                            ) {
                                ForEach(chunk.reversed()) { record in
                                    InsulinCard(record)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .navigationTitle("Insulin Delivery")
        .sheet($sheetNewRecord) {
            NewRecordSheet(.insulin)
        }
        .toolbar {
            SFButton("note.text.badge.plus") {
                sheetNewRecord = true
            }
        }
    }
}

#Preview {
    InsulinList()
}
