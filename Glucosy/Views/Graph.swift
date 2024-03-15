import SwiftUI

struct Graph: View {
    @Environment(History.self) private var history: History
    @Environment(Settings.self) private var settings: Settings

    func yMax() -> Double {
        let maxValues = [
            history.rawValues.map(\.value).max() ?? 0,
            history.factoryValues.map(\.value).max() ?? 0,
            history.values.map(\.value).max() ?? 0,
            Int(settings.targetHigh + 20)
        ]
        
        return Double(maxValues.max()!)
    }

    var body: some View {
        ZStack {
            // Glucose range rect in the background
            GeometryReader { geometry in
                Path { path in
                    let width  = geometry.size.width - 60
                    let height = geometry.size.height
                    let yScale = (height - 20) / yMax()
                    path.addRect(CGRect(x: 1 + 30, y: height - settings.targetHigh * yScale + 1.0, width: width - 2, height: (settings.targetHigh - settings.targetLow) * yScale - 1))
                }
                .fill(.green)
                .opacity(0.15)
            }

            // Target glucose low and high labels at the right, timespan on the left
            GeometryReader { geometry in
                ZStack {
                    Text("\(settings.targetHigh.units)")
                        .position(x: geometry.size.width - 15, y: geometry.size.height - (geometry.size.height - 20) / yMax() * settings.targetHigh)
                    
                    Text("\(settings.targetLow.units)")
                        .position(x: geometry.size.width - 15, y: geometry.size.height - (geometry.size.height - 20) / yMax() * settings.targetLow)
                    
                    let count = history.rawValues.count
                    
                    if count > 0 {
                        let hours = count / 4
                        let minutes = count % 4 * 15
                        Text((hours > 0 ? "\(hours) h\n" : "") + (minutes != 0 ? "\(minutes) min" : ""))
                            .position(x: 5, y: geometry.size.height - geometry.size.height / 2)
                    } else {
                        // TODO: factory data coming from LLU
                        let count = history.factoryValues.count
                        
                        if count > 0 {
                            Text("12 h\n\n\(count) /\n144")
                                .position(x: 5, y: geometry.size.height - geometry.size.height / 2 - 8)
                        }
                    }
                }
                .footnote()
                    .foregroundColor(.gray)
            }

            // Historic raw values
            GeometryReader { geometry in
                let count = history.rawValues.count
                
                if count > 0 {
                    Path { path in
                        let width  = geometry.size.width - 60
                        let height = geometry.size.height
                        let v = history.rawValues.map(\.value)
                        let yScale = (height - 20) / yMax()
                        let xScale = width / Double(count - 1)
                        var startingVoid = v[count - 1] < 1 ? true : false
                        
                        if !startingVoid {
                            path.move(to: .init(x: 0 + 30, y: height - Double(v[count - 1]) * yScale))
                        }
                        
                        for i in 1 ..< count {
                            if v[count - i - 1] > 0 {
                                let point = CGPoint(x: Double(i) * xScale + 30.0, y: height - Double(v[count - i - 1]) * yScale)
                                
                                if !startingVoid {
                                    path.addLine(to: point)
                                } else {
                                    startingVoid = false
                                    path.move(to: point)
                                }
                            }
                        }
                    }
                    .stroke(.yellow)
                    .opacity(0.6)
                }
            }

            // Historic factory values
            GeometryReader { geometry in
                let count = history.factoryValues.count
                
                if count > 0 {
                    Path { path in
                        let width  = geometry.size.width - 60
                        let height = geometry.size.height
                        let v = history.factoryValues.map(\.value)
                        let yScale = (height - 20) / yMax()
                        let xScale = width / Double(count - 1)
                        var startingVoid = v[count - 1] < 1 ? true : false
                        
                        if !startingVoid {
                            path.move(to: .init(x: 0 + 30, y: height - Double(v[count - 1]) * yScale))
                        }
                        
                        for i in 1 ..< count {
                            if v[count - i - 1] > 0 {
                                let point = CGPoint(x: Double(i) * xScale + 30.0, y: height - Double(v[count - i - 1]) * yScale)
                                
                                if !startingVoid  {
                                    path.addLine(to: point)
                                } else {
                                    startingVoid = false
                                    path.move(to: point)
                                }
                            }
                        }
                    }
                    .stroke(.orange)
                    .opacity(0.75)
                }
            }

            // Frame and historic OOP values
            GeometryReader { geometry in
                Path { path in
                    let width  = geometry.size.width - 60
                    let height = geometry.size.height
                    path.addRoundedRect(in: CGRect(x: 0 + 30, y: 0, width: width, height: height), cornerSize: CGSize(width: 8, height: 8))
                    let count = history.values.count
                    
                    if count > 0 {
                        let v = history.values.map(\.value)
                        let yScale = (height - 20) / yMax()
                        let xScale = width / Double(count - 1)
                        var startingVoid = v[count - 1] < 1 ? true : false
                        if !startingVoid { path.move(to: .init(x: 0 + 30, y: height - Double(v[count - 1]) * yScale)) }
                        
                        for i in 1 ..< count {
                            if v[count - i - 1] > 0 {
                                let point = CGPoint(x: Double(i) * xScale + 30.0, y: height - Double(v[count - i - 1]) * yScale)
                                
                                if !startingVoid {
                                    path.addLine(to: point)
                                } else {
                                    startingVoid = false
                                    path.move(to: point)
                                }
                            }
                        }
                    }
                }
                .stroke(.blue)
            }
        }
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
        .environment(AppState.test(tab: .monitor))
        .environment(Log())
        .environment(History.test)
        .environment(Settings())
}
