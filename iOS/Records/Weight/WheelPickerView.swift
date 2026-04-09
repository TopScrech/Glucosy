import ScrechKit

@available(iOS 18, *)
struct WheelPickerView<Label: View>: View {
    var range: ClosedRange<Int>
    @Binding var selectedValue: Int
    var config = WheelPickerConfig()
    @ViewBuilder var label: (Int) -> Label
    
    @State private var activePosition: Int?
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            /// Removing line-Width from the width
            let width = size.width - (config.strokeStyle.lineWidth)
            let dia = min(max(width, size.height), width)
            let radius = dia / 2
            
            WheelPath(size, radius: radius)
                .stroke(config.strokeColor, style: config.strokeStyle)
                .overlay {
                    wheelPickerScrollView(size: size, radius: radius)
                }
                .compositingGroup()
            /// Removing line-width from the height (Using Offset)
                .offset(y: -config.strokeStyle.lineWidth / 2)
        }
        .frame(height: config.height)
        /// Setting up initial data and publishing data changes to the selectedValue property
        .task {
            try? await Task.sleep(for: .seconds(0))
            
            guard activePosition == nil else {
                return
            }
            
            activePosition = selectedValue
        }
        .onChange(of: activePosition) { _, newValue in
            if let newValue, selectedValue != newValue {
                selectedValue = newValue
            }
        }
        .onChange(of: selectedValue) { _, newValue in
            if activePosition != newValue {
                activePosition = newValue
            }
        }
        .onScrollPhaseChange { _, newPhase in
            if newPhase == .idle {
                Task {
                    activePosition = nil
                    try? await Task.sleep(for: .seconds(0))
                    
                    /// Option 1
                    withAnimation(.easeInOut(duration: 0.1)) {
                        activePosition = selectedValue
                    }
                    
                    /// Option 2
                    // activePosition = selectedValue
                }
            }
        }
    }
    
    @ViewBuilder
    func wheelPickerScrollView(size: CGSize, radius: CGFloat) -> some View {
        /// Clipping and limiting interaction only within it's shape
        /// While limiting interaction is optional
        let wheelShape = WheelPath(size, radius: radius)
            .strokedPath(config.strokeStyle)
        
        ScrollView(.horizontal) {
            LazyHStack(spacing: config.gapBetweenTicks) {
                ForEach(ticks, id: \.self) {
                    TickView($0, size: size, radius: radius)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled(true)
        /// Starting and ending at the center
        .safeAreaPadding(.horizontal, (size.width - 8) / 2)
        .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
        .scrollPosition(id: $activePosition, anchor: .center)
        .clipShape(wheelShape)
        /// Optional
        .contentShape(wheelShape)
        /// Center Mark and Label Preview
        .overlay(alignment: .bottom) {
            let strokeWidth = config.strokeStyle.lineWidth
            let halfStrokeWidth = strokeWidth / 2
            
            VStack(spacing: -5) {
                Capsule()
                    .fill(config.activeTint)
                    .frame(width: 5, height: strokeWidth)
                
                Circle()
                    .fill(config.activeTint)
                    .frame(10)
            }
            .offset(y: -radius + halfStrokeWidth + 5)
        }
        .overlay(alignment: .bottom) {
            if radius > 0 {
                label(activePosition ?? selectedValue)
                    .frame(
                        maxWidth: radius,
                        maxHeight: radius - (config.strokeStyle.lineWidth / 2)
                    )
            }
        }
    }
    
    @ViewBuilder
    func TickView(_ value: Int, size: CGSize, radius: CGFloat) -> some View {
        let strokeWidth = config.strokeStyle.lineWidth
        let halfStrokeWidth = strokeWidth / 2
        
        /// Larger tick for the given frequency
        let isLargeTick = ((ticks.firstIndex(of: value) ?? 0)) % config.largeTickFrequency == 0
        
        GeometryReader { proxy in
            /// Rotating the tick to match the Stroke border shape!
            let minX = proxy.frame(in: .scrollView(axis: .horizontal)).minX
            let midX = proxy.frame(in: .scrollView(axis: .horizontal)).midX
            let halfWidth = size.width / 2
            
            /// Left-Right
            let progress = max(min(midX / halfWidth, 1), -1)
            /// -180...180
            let rotation = Angle(degrees: progress * 180)
            
            Capsule()
                .fill(config.inactiveTint)
                .offset(y: -radius + halfStrokeWidth)
                .rotationEffect(rotation, anchor: .bottom)
                .offset(x: -minX)
        }
        .frame(width: 3, height: strokeWidth * (isLargeTick ? config.largeTickRatio : config.smallTickRatio))
        .frame(width: 8, alignment: .leading)
    }
    
    private func WheelPath(_ size: CGSize, radius: CGFloat) -> Path {
        Path { path in
            path.addArc(
                /// Bottom Center
                center: .init(x: size.width / 2, y: size.height),
                radius: radius,
                startAngle: .degrees(180),
                endAngle: .degrees(0),
                clockwise: false
            )
        }
    }
    
    /// Converting Range into Array of Int
    private var ticks: [Int] {
        stride(from: range.lowerBound, through: range.upperBound, by: 1)
            .compactMap {
                $0
            }
    }
    
    /// Config
    struct WheelPickerConfig {
        var activeTint: Color = .primary
        var inactiveTint: Color = .gray.opacity(0.8)
        var largeTickFrequency = 10
        
        var strokeStyle = StrokeStyle(
            lineWidth: 50,
            lineCap: .round,
            lineJoin: .round
        )
        
        var strokeColor: Color = .black.opacity(0.08)
        var largeTickRatio = 0.65
        var smallTickRatio = 0.4
        
        /// if you want to reduce the gap between the ticks use negative spacing value!
        var gapBetweenTicks = -2.0
        var height = 200.0
        
        /// Add more properties if needed
    }
}

#Preview {
    NavigationStack {
        LogWeightSheet()
    }
    .darkSchemePreferred()
}
