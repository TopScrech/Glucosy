#!/bin/zsh
set -eu
project_dir="$(cd "$(dirname "$0")/.." && pwd)"
test_dir="$(mktemp -d /tmp/GlucosyRecordTests.XXXXXX)"
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/Sources/Records" "$test_dir/Tests/RecordsTests"
cp "$project_dir/iOS/Records/HealthKit/Models/HealthRecord.swift" "$project_dir/iOS/Records/HealthKit/Models/HealthRecordDay.swift" "$test_dir/Sources/Records/"
cp "$project_dir/Tests/HealthRecordDayTests.swift" "$test_dir/Tests/RecordsTests/"
cp "$project_dir/Tests/HealthSyncTests.swift" "$test_dir/Tests/RecordsTests/"
for source in HealthRecordCache HealthSyncSnapshot HealthSampleSyncState HealthEnergySyncState HealthRefreshState HealthRecordMerge HealthStartupRecords; do
    cp "$project_dir/iOS/Records/HealthKit/Cache/$source.swift" "$test_dir/Sources/Records/"
done
cp "$project_dir/iOS/Records/Energy/EnergyDay.swift" "$test_dir/Sources/Records/"
cat > "$test_dir/Package.swift" <<'PACKAGE'
// swift-tools-version: 6.0
import PackageDescription
let package = Package(
    name: "Records",
    platforms: [.macOS(.v15)],
    targets: [
        .target(name: "Records"),
        .testTarget(name: "RecordsTests", dependencies: ["Records"])
    ]
)
PACKAGE
swift test --package-path "$test_dir"
