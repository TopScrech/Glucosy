import Foundation

extension GlucoseCard {
    var sourceName: String? {
        glucose.sample?.sourceRevision.source.name
    }
    
    var sourceBundleId: String? {
        glucose.sample?.sourceRevision.source.bundleIdentifier
    }
    
    var date: String {
        glucose.date.shortDateTime
    }
}

extension InsulinCard {
    var sourceName: String? {
        insulin.sample?.sourceRevision.source.name
    }
    
    var sourceBundleId: String? {
        insulin.sample?.sourceRevision.source.bundleIdentifier
    }
}

extension CarbohydratesCard {
    var sourceName: String? {
        carbs.sample?.sourceRevision.source.name
    }
    
    var sourceBundleId: String? {
        carbs.sample?.sourceRevision.source.bundleIdentifier
    }
}
