import SwiftUI
import RealmSwift
import TabularData

// TODO: rename to Copilot when smarter

struct ShellView: View {
    @Environment(AppState.self) private var app: AppState
    @Environment(Log.self) private var log: Log
    @Environment(Settings.self) private var settings: Settings
    
    @State private var showingStack = false
    
    @State private var showingFileImporter = false
    @State private var libreviewCSV = ""
    
    @State private var showingFolderImporter = false
    @State private var tridentContainer = ""
    
    @State private var showingRealmKeyPrompt = false
    
    @AppStorage("tridentRealmKey") var tridentRealmKey = "" // 128-char hex
    
    var body: some View {
        VStack(spacing: 0) {
            if showingStack {
                VStack(spacing: 0) {
                    HStack {
                        TextField("LibreView CSV", text: $libreviewCSV)
                            .textFieldStyle(.roundedBorder)
                            .truncationMode(.head)
                        
                        Button {
                            showingFileImporter = true
                        } label: {
                            Image(systemName: "doc.circle")
                                .fontSize(32)
                        }
                        .fileImporter(
                            isPresented: $showingFileImporter,
                            allowedContentTypes: [.commaSeparatedText]
                        ) { result in
                            switch result {
                            case .success(let file):
                                if !file.startAccessingSecurityScopedResource() { 
                                    return
                                }
                                
                                libreviewCSV = file.path
                                let fileManager = FileManager.default
                                
                                if var csvData = fileManager.contents(atPath: libreviewCSV) {
                                    app.main.log("cat \(libreviewCSV)\n\(csvData.prefix(800).string)\n[...]\n\(csvData.suffix(800).string)")
                                    csvData = csvData[(csvData.firstIndex(of: 10)! + 1)...]  //trim first line
                                    
                                    do {
                                        var options = CSVReadingOptions()
                                        options.addDateParseStrategy(Date.ParseStrategy(format: "\(day: .twoDigits)-\(month: .twoDigits)-\(year: .defaultDigits) \(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits)", timeZone: .current))
                                        
                                        let dataFrame = try DataFrame(csvData: csvData, options: options)
                                        // ["Device", "Serial Number", "Device Timestamp", "Record Type", "Historic Glucose mg/dL", "Scan Glucose mg/dL", "Non-numeric Rapid-Acting Insulin", "Rapid-Acting Insulin (units)", "Non-numeric Food", "Carbohydrates (grams)", "Carbohydrates (servings)", "Non-numeric Long-Acting Insulin", "Long-Acting Insulin (units)", "Notes", "Strip Glucose mg/dL", "Ketone mmol/L", "Meal Insulin (units)", "Correction Insulin (units)", "User Change Insulin (units)"]
                                        app.main.log("TabularData: column names: \(dataFrame.columns.map(\.name))")
                                        app.main.log("TabularData:\n\(dataFrame)")
                                        let lastRow = dataFrame.rows.last!
                                        let lastDeviceSerial = lastRow["Serial Number"] as! String
                                        app.main.log("TabularData: last device serial: \(lastDeviceSerial)")
                                        
                                        var history = try DataFrame(
                                            csvData: csvData,
                                            columns: ["Serial Number", "Device Timestamp", "Record Type", "Historic Glucose mg/dL"],
                                            types: ["Serial Number": .string, "Device Timestamp": .date, "Record Type": .integer, "Historic Glucose mg/dL": .integer],
                                            options: options
                                        )
                                            .sorted(on: "Device Timestamp", order: .descending)
                                        history.renameColumn("Device Timestamp", to: "Date")
                                        history.renameColumn("Record Type", to: "Type")
                                        history.renameColumn("Historic Glucose mg/dL", to: "Glucose")
                                        
                                        var formattingOptions = FormattingOptions(maximumLineWidth: 80, includesColumnTypes: false)
                                        
                                        formattingOptions.includesRowIndices = false
                                        
                                        app.main.log("TabularData: history:\n\(history.description(options: formattingOptions))")
                                        
                                        let filteredHistory = history
                                            .filter(on: "Serial Number", String.self) { $0! == lastDeviceSerial }
                                            .filter(on: "Glucose", Int.self) { $0 != nil }
                                            .selecting(columnNames: ["Date", "Glucose"])
                                        
                                        formattingOptions.maximumLineWidth = 32
                                        
                                        app.main.log("TabularData: filtered history:\n\(filteredHistory.description(options: formattingOptions))")
                                        
                                    } catch {
                                        app.main.log("TabularData: error: \(error.localizedDescription)")
                                    }
                                }
                                
                                file.stopAccessingSecurityScopedResource()
                                
                            case .failure(let error):
                                app.main.log("\(error.localizedDescription)")
                            }
                        }
                    }
                    .padding(4)
                    
                    HStack {
                        TextField("Trident Container", text: $tridentContainer)
                            .textFieldStyle(.roundedBorder)
                            .truncationMode(.head)
                        
                        Button {
                            showingFolderImporter = true
                        } label: {
                            Image(systemName: "folder.circle")
                                .fontSize(32)
                        }
                        .fileImporter(
                            isPresented: $showingFolderImporter,
                            allowedContentTypes: [.folder] // .directory doesn't work
                        ) { result in
                            switch result {
                            case .success(let directory):
                                if !directory.startAccessingSecurityScopedResource() { return }
                                tridentContainer = directory.path
                                
                                let fileManager = FileManager.default
                                let containerDirs = try! fileManager.contentsOfDirectory(atPath: tridentContainer)
                                app.main.log("ls \(tridentContainer)\n\(containerDirs)")
                                
                                for dir in containerDirs {
                                    if dir == "Library" {
                                        let libraryDirs = try! fileManager.contentsOfDirectory(atPath: "\(tridentContainer)/Library")
                                        
                                        app.main.log("ls Library\n\(libraryDirs)")
                                        
                                        for dir in libraryDirs {
                                            if dir == "Preferences" {
                                                let preferencesContents = try! fileManager.contentsOfDirectory(atPath: "\(tridentContainer)/Library/Preferences")
                                                
                                                app.main.log("ls Preferences\n\(preferencesContents)")
                                                
                                                for plist in preferencesContents {
                                                    if plist.hasPrefix("com.abbott.libre3") {
                                                        if let plistData = fileManager.contents(atPath: "\(tridentContainer)/Library/Preferences/\(plist)") {
                                                            if let libre3Plist = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any] {
                                                                app.main.log("cat \(plist)\n\(libre3Plist)")
                                                                
                                                                let realmEncryptionKey = libre3Plist["RealmEncryptionKey"] as! [UInt8]
                                                                
                                                                let realmEncryptionKeyInt8 = realmEncryptionKey.map {
                                                                    Int8(bitPattern: $0)
                                                                }
                                                                app.main.log("realmEncryptionKey:\n\(realmEncryptionKey)\nas Int8 array:\n\(realmEncryptionKeyInt8)")
                                                                
                                                                // https://frdmtoplay.com/freeing-glucose-data-from-the-freestyle-libre-3/
                                                                //
                                                                // Assuming that `python3` is available after installing the Xcode Command Line Tools
                                                                // and `Library/Android/sdk/platform-tools/` is in your $PATH after installing Android Studio:
                                                                //
                                                                // $ pip3 install frida-tools
                                                                // $ adb root
                                                                // $ adb push ~/Downloads/frida-server-16.1.4-android-arm64 /data/local/tmp/frida-server
                                                                // $ adb shell  # sudo waydroid shell
                                                                // $ su
                                                                // # chmod 755 /data/local/tmp/frida-server
                                                                // # /data/local/tmp/frida-server &
                                                                //
                                                                // $ frida -U "Libre 3"
                                                                // Frida-> Java.perform(function(){}) // Seems necessary to use Java.use
                                                                // Frida-> var crypto_lib_def = Java.use("com.adc.trident.app.frameworks.mobileservices.libre3.security.Libre3SKBCryptoLib")
                                                                // Frida-> var crypto_lib = crypto_lib_def.$new()
                                                                // Frida-> unwrapped = crypto_lib.unWrapDBEncryptionKey([<realmEncryptionKeyInt8>])
                                                                //
                                                                // swift repl
                                                                // import Foundation
                                                                // let unwrappedInt8: [Int8] = [<unwrapped>]
                                                                // let unwrappedUInt8: [UInt8] = unwrappedInt8.map {
                                                                //      UInt8(bitPattern: $0)
                                                                //  }
                                                                // print(Data(unwrappedUInt8).reduce("", { $0 + String(format: "%02x", $1)}))
                                                                
                                                                // TODO: parse rest of libre3Plist
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    if dir == "Documents" {
                                        let documentsFiles = try! fileManager.contentsOfDirectory(atPath: "\(tridentContainer)/Documents")
                                        app.main.log("ls Documents\n\(documentsFiles)")
                                        
                                        for file in documentsFiles {
                                            if file.hasSuffix(".realm") && !file.contains("backup") {
                                                var realm: Realm
                                                
                                                var config = Realm.Configuration.defaultConfiguration
                                                config.schemaVersion = 8  // as for RealmStudio 14
                                                config.fileURL = URL(filePath: "\(tridentContainer)/Documents/\(file)")
                                                
                                                do {
                                                    if !file.contains("decrypted") {
                                                        config.encryptionKey = tridentRealmKey.count == 128 ? tridentRealmKey.bytes : Data(count: 64)
                                                    } else {
                                                        config.encryptionKey = nil
                                                    }
                                                    
                                                    realm = try Realm(configuration: config)
                                                    
                                                    if !file.contains("decrypted") {
                                                        app.main.debugLog("Realm: opened encrypted \(tridentContainer)/Documents/\(file) by using the key \(tridentRealmKey)")
                                                    } else {
                                                        app.main.debugLog("Realm: opened already decrypted \(tridentContainer)/Documents/\(file)")
                                                    }
                                                    
                                                    let sensors = realm.objects(SensorEntity.self)
                                                    app.main.log("Realm: sensors: \(sensors)")
                                                    let appConfig = realm.objects(AppConfigEntity.self)
                                                    // overcome limit of max 100 objects in a result description
                                                    
                                                    app.main.log(appConfig.reduce("Realm: app config:", {
                                                        $0 + "\n" + $1.description
                                                    }))
                                                    
                                                    let libre3WrappedKAuth = realm.object(ofType: AppConfigEntity.self, forPrimaryKey: "Libre3WrappedKAuth")!["_configValue"]!
                                                    
                                                    app.main.log("Realm: libre3WrappedKAuth: \(libre3WrappedKAuth)")
                                                    // TODO
                                                    
                                                } catch {
                                                    app.main.log("Realm: error: \(error.localizedDescription)")
                                                    
                                                    if file == "trident.realm" {
                                                        showingRealmKeyPrompt = true
                                                    }
                                                }
                                            }
                                            
                                            if file == "trident.json" {
                                                if let tridentJson = fileManager.contents(atPath: "\(tridentContainer)/Documents/\(file)") {
                                                    (app.sensor as? Libre3 ?? Libre3(main: app.main)).parseRealmFlattedJson(data: tridentJson)
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                directory.stopAccessingSecurityScopedResource()
                                
                            case .failure(let error):
                                app.main.log("\(error.localizedDescription)")
                            }
                        }
                    }
                    .padding(4)
                }
                
                CrcCalculator()
                    .padding(4)
            }
        }
        .background(.thinMaterial, ignoresSafeAreaEdges: [])
        .sheet(isPresented: $showingRealmKeyPrompt) {
            VStack(spacing: 20) {
                Text("The Realm might be encrypted")
                    .bold()
                
                Text("Either this is not a Realm file or it's encrypted.")
                
                TextField("128-character hex-encoded encryption key", text: $tridentRealmKey, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                HStack {
                    Spacer()
                    
                    Button {
                        showingRealmKeyPrompt = false
                    } label: {
                        Text("Cancel")
                    }
                    
                    Button {
                        showingRealmKeyPrompt = false
                        showingFolderImporter = true
                    } label: {
                        Label {
                            Text("Try again")
                                .bold()
                        } icon: {
                            Image(systemName: "folder.circle")
                                .fontSize(20)
                        }
                    }
                }
                .buttonStyle(.bordered)
                .padding()
            }
        }
        .toolbar {
            Button {
                withAnimation {
                    showingStack.toggle()
                }
            } label: {
                VStack(spacing: 0) {
                    Image(systemName: showingStack ? "fossil.shell.fill" : "fossil.shell")
                    
                    Text("Shell")
                        .footnote()
                }
            }
        }
    }
}

#Preview {
    ShellView()
        .glucosyPreview(.console)
}
