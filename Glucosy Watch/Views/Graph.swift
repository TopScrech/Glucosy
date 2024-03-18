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
            GeometryReader { geo in
                Path { path in
                    let width  = geo.size.width - 60
                    let height = geo.size.height
                    let yScale = (height - 20) / yMax()
                    path.addRect(CGRect(x: 1 + 30, y: height - settings.targetHigh * yScale + 1.0, width: width - 2, height: (settings.targetHigh - settings.targetLow) * yScale - 1))
                }
                .fill(.green)
                .opacity(0.15)
            }
            
            // Target glucose low and high labels at the right, timespan on the left
            GeometryReader { geo in
                ZStack {
                    Text("\(settings.targetHigh.units)")
                        .position(x: geo.size.width - 15, y: geo.size.height - (geo.size.height - 20) / yMax() * settings.targetHigh)
                    
                    Text("\(settings.targetLow.units)")
                        .position(x: geo.size.width - 15, y: geo.size.height - (geo.size.height - 20) / yMax() * settings.targetLow)
                    
                    let count = history.rawValues.count
                    
                    if count > 0 {
                        let hours = count / 4
                        let minutes = count % 4 * 15
                        
                        Text((hours > 0 ? "\(hours)h\n" : "") + (minutes != 0 ? "\(minutes)m" : ""))
                            .position(x: 13, y: geo.size.height - geo.size.height / 2)
                    } else { // factory data coming from LLU: TODO
                        let count  = history.factoryValues.count
                        
                        if count > 0 {
                            Text("12h\n\n\(count)/\n144")
                                .position(x: 13, y: geo.size.height - geo.size.height / 2)
                        }
                    }
                }
                .footnote()
                .foregroundColor(.gray)
            }
            
            // Historic raw values
            GeometryReader { geo in
                let count = history.rawValues.count
                
                if count > 0 {
                    Path { path in
                        let width  = geo.size.width - 60
                        let height = geo.size.height
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
            GeometryReader { geo in
                let count = history.factoryValues.count
                
                if count > 0 {
                    Path { path in
                        let width  = geo.size.width - 60
                        let height = geo.size.height
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
            GeometryReader { geo in
                Path { path in
                    let width  = geo.size.width - 60
                    let height = geo.size.height
                    path.addRoundedRect(in: CGRect(x: 0 + 30, y: 0, width: width, height: height), cornerSize: CGSize(width: 8, height: 8))
                    let count = history.values.count
                    
                    if count > 0 {
                        let v = history.values.map(\.value)
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
                }
                .stroke(.blue)
            }
        }
    }
}

#Preview {
    Monitor()
        .glucosyPreview()
}
