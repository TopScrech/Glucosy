import ScrechKit

struct SourceName: View {
    private let source: String
    
    init(_ source: String) {
        self.source = source
    }
    
    var body: some View {
        Text(source)
            .footnote()
            .secondary()
    }
}

#Preview {
    SourceName("Source")
        .darkSchemePreferred()
}
