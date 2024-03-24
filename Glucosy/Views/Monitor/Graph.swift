import SwiftUI
import Charts

struct Graph: View {
    @Environment(History.self) private var history: History
    @Environment(Settings.self) private var settings: Settings
    
    //    func yMax() -> Double {
    //        let maxValues = [
    //            history.rawValues.map(\.value).max() ?? 0,
    //            history.factoryValues.map(\.value).max() ?? 0,
    //            history.values.map(\.value).max() ?? 0,
    //            Int(settings.targetHigh + 20)
    //        ]
    //
    //        return Double(maxValues.max()!)
    //    }
    
    var body: some View {
        VStack {
            //            ZStack {
            //                // Glucose range rect in the background
            //                GeometryReader { geo in
            //                    Path { path in
            //                        let width  = geo.size.width - 60
            //                        let height = geo.size.height
            //                        let yScale = (height - 20) / yMax()
            //
            //                        path.addRect(CGRect(x: 31, y: height - settings.targetHigh * yScale + 1.0, width: width - 2, height: (settings.targetHigh - settings.targetLow) * yScale - 1))
            //                    }
            //                    .fill(.green)
            //                    .opacity(0.15)
            //                }
            //
            //                // Target glucose low and high labels at the right, timespan on the left
            //                GeometryReader { geo in
            //                    ZStack {
            //                        Text("\(settings.targetHigh.units)")
            //                            .position(x: geo.size.width - 15, y: geo.size.height - (geo.size.height - 20) / yMax() * settings.targetHigh)
            //
            //                        Text("\(settings.targetLow.units)")
            //                            .position(x: geo.size.width - 15, y: geo.size.height - (geo.size.height - 20) / yMax() * settings.targetLow)
            //
            //                        let count = history.rawValues.count
            //
            //                        if count > 0 {
            //                            let hours = count / 4
            //                            let minutes = count % 4 * 15
            //
            //                            Text((hours > 0 ? "\(hours)h\n" : "") + (minutes != 0 ? "\(minutes)min" : ""))
            //                                .position(x: 5, y: geo.size.height - geo.size.height / 2)
            //                        } else {
            //                            // TODO: factory data coming from LLU
            //                            let count = history.factoryValues.count
            //
            //                            if count > 0 {
            //                                Text("12 h\n\n\(count) /\n144")
            //                                    .position(x: 5, y: geo.size.height - geo.size.height / 2 - 8)
            //                            }
            //                        }
            //                    }
            //                    .footnote()
            //                    .foregroundColor(.gray)
            //                }
            //
            //                // Historic raw values
            //                GeometryReader { geo in
            //                    let count = history.rawValues.count
            //
            //                    if count > 0 {
            //                        Path { path in
            //                            let width  = geo.size.width - 60
            //                            let height = geo.size.height
            //
            //                            let v = history.rawValues.map(\.value)
            //
            //                            let yScale = (height - 20) / yMax()
            //                            let xScale = width / Double(count - 1)
            //                            var startingVoid = v[count - 1] < 1 ? true : false
            //
            //                            if !startingVoid {
            //                                path.move(to: .init(x: 30, y: height - Double(v[count - 1]) * yScale))
            //                            }
            //
            //                            for i in 1 ..< count {
            //                                if v[count - i - 1] > 0 {
            //                                    let point = CGPoint(x: Double(i) * xScale + 30, y: height - Double(v[count - i - 1]) * yScale)
            //
            //                                    if !startingVoid {
            //                                        path.addLine(to: point)
            //                                    } else {
            //                                        startingVoid = false
            //                                        path.move(to: point)
            //                                    }
            //                                }
            //                            }
            //                        }
            //                        .stroke(.yellow)
            //                    }
            //                }
            //
            //                // Historic factory values
            //                GeometryReader { geo in
            //                    let count = history.factoryValues.count
            //
            //                    if count > 0 {
            //                        Path { path in
            //                            let width  = geo.size.width - 60
            //                            let height = geo.size.height
            //
            //                            let v = history.factoryValues.map(\.value)
            //
            //                            let yScale = (height - 20) / yMax()
            //                            let xScale = width / Double(count - 1)
            //                            var startingVoid = v[count - 1] < 1 ? true : false
            //
            //                            if !startingVoid {
            //                                path.move(to: .init(x: 30, y: height - Double(v[count - 1]) * yScale))
            //                            }
            //
            //                            for i in 1 ..< count {
            //                                if v[count - i - 1] > 0 {
            //                                    let point = CGPoint(x: Double(i) * xScale + 30, y: height - Double(v[count - i - 1]) * yScale)
            //
            //                                    if !startingVoid  {
            //                                        path.addLine(to: point)
            //                                    } else {
            //                                        startingVoid = false
            //                                        path.move(to: point)
            //                                    }
            //                                }
            //                            }
            //                        }
            //                        .stroke(.orange)
            //                    }
            //                }
            //
            //                // Frame and historic OOP values
            //                GeometryReader { geo in
            //                    Path { path in
            //                        let width  = geo.size.width - 60
            //                        let height = geo.size.height
            //
            //                        path.addRoundedRect(
            //                            in: .init(x: 30, y: 0, width: width, height: height),
            //                            cornerSize: .init(width: 8, height: 8)
            //                        )
            //
            //                        let count = history.values.count
            //
            //                        if count > 0 {
            //                            let v = history.values.map(\.value)
            //                            let yScale = (height - 20) / yMax()
            //                            let xScale = width / Double(count - 1)
            //                            var startingVoid = v[count - 1] < 1 ? true : false
            //
            //                            if !startingVoid {
            //                                path.move(to: .init(x: 30, y: height - Double(v[count - 1]) * yScale))
            //                            }
            //
            //                            for i in 1 ..< count {
            //                                if v[count - i - 1] > 0 {
            //                                    let point = CGPoint(x: Double(i) * xScale + 30, y: height - Double(v[count - i - 1]) * yScale)
            //
            //                                    if !startingVoid {
            //                                        path.addLine(to: point)
            //                                    } else {
            //                                        startingVoid = false
            //                                        path.move(to: point)
            //                                    }
            //                                }
            //                            }
            //                        }
            //                    }
            //                    .stroke(.blue)
            //                }
            //
            //    //            GeometryReader { geo in
            //    //                let width = geo.size.width - 60
            //    //                let height = geo.size.height
            //    //
            //    //                let count = history.factoryValues.count
            //    //
            //    //                // Calculate the position for the line 2 hours before the current date
            //    //                // Assuming that the graph is a timeline starting from `history.startDate` and ending at `Date()`
            //    //                let graphStartTime = history.rawValues.first?.date // Start time for your graph
            //    //                let graphEndTime = Date() // End time for your graph is now
            //    //                let totalGraphDuration = graphEndTime.timeIntervalSince(graphStartTime!)
            //    //                let twoHoursAgoTime = graphEndTime.addingTimeInterval(-7200)
            //    //                let twoHoursAgoPosition = width * CGFloat(twoHoursAgoTime.timeIntervalSince(graphStartTime!) / totalGraphDuration)
            //    //
            //    //                Path { path in
            //    //                    path.move(to: CGPoint(x: twoHoursAgoPosition, y: 0))
            //    //                    path.addLine(to: CGPoint(x: twoHoursAgoPosition, y: height))
            //    //                }
            //    //                .stroke(.green, lineWidth: 2)
            //    //            }
            //            }
            
            Chart {
                ForEach(history.factoryValues, id: \.self) { value in
                    LineMark(
                        x: .value("Time", value.date),
                        y: .value("Glucose", value.value)
                    )
                    .foregroundStyle(.yellow)
                }
                
                ForEach(history.rawValues, id: \.self) { value in
                    LineMark(
                        x: .value("Time", value.date),
                        y: .value("Glucose", value.value)
                    )
                    .foregroundStyle(.orange)
                }
                
                ForEach(history.glucose, id: \.self) { value in
                    LineMark(
                        x: .value("Time", value.date),
                        y: .value("Glucose", value.value)
                    )
                    .foregroundStyle(.red)
                }
                    
                //                        path.addRect(CGRect(x: 31, y: height - settings.targetHigh * yScale + 1.0, width: width - 2, height: (settings.targetHigh - settings.targetLow) * yScale - 1))
                
                if let last = history.glucose.last?.date,
                   let first = history.glucose.first?.date,
                   let targetLow = Int(settings.targetLow.units),
                   let targetHigh = Int(settings.targetHigh.units) {
                    RectangleMark(
                        xStart: .value("Start", first),
                        xEnd: .value("End", last),
                        yStart: .value("Low", targetLow),
                        yEnd: .value("High", targetHigh)
//                        yEnd: .value("High", 15 * 18.0182)
                    )
                    .foregroundStyle(.green.opacity(0.15))
                }
                
//                RectangleMark(
//                    x: .value("", 0),
//                    y: .value("", 3.9 * 18.0182),
//                    width: .automatic,
//                    height: .fixed((15 - 3.9) * 18.0182)
//                )
//                .foregroundStyle(.green.opacity(0.15))
                
                //                AreaMark(
                //                    x: .value("", settings.targetHigh),
//                    y: .value("", 0)
//                )
            }
        }
    }
}

#Preview {
    HomeView()
        .glucosyPreview(.monitor)
}
