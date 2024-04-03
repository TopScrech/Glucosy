import SwiftUI

struct Row {
    let group: String
    let level: String
    let color: Color
    
    init(_ group: String, level: String, color: Color) {
        self.group = group
        self.level = level
        self.color = color
    }
}

struct GlycatedHaemoglobinTable: View {
    private let table: [Row] = [
        Row(
            "Healthy (non-diabetic)",
            level: "< 5.7",
            color: .green
        ),
        Row(
            "Prediabetic",
            level: "5.7 - 6.4",
            color: .yellow
        ),
        Row(
            "Diabetic",
            level: "> 6.5",
            color: .red
        )
    ]
    
    var body: some View {
        List(table, id: \.group) { row in
            HStack {
                Text(row.group)
                
                Spacer()
                
                Text(row.level)
                    .title3(.bold)
                    .foregroundStyle(row.color)
            }
        }
        
        //        Table(of: Row.self) {
        //            TableColumn("Group", value: \.group)
        //
        //            TableColumn("Level", value: \.level)
        //        } rows: {
        //            TableRow(ListRow("1", level: "11"))
        //            TableRow(ListRow("2", level: "22"))
        //            TableRow(ListRow("3", level: "33"))
        //        }
    }
}

#Preview {
    GlycatedHaemoglobinTable()
}
