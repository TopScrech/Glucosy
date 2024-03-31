FIXME
-----

* Libre 3:
  - Gen2 `.getSessionInfo` outpassed by new certificate data and ECDH ephemeral keys (whiteCryption's Secure Key Box)

* iOS 16:
  - *"This method should not be called on the main thread as it may lead to UI unresponsiveness"* warning for `App.swift`

TODO
----

* Apple Watch app:
  - workout and extended runtime background sessions, complications
  - ["Get timely alerts from Bluetooth devices in watchOS" - WWDC 2022](https://developer.apple.com/wwdc22/10135/)

* switch from `DispatchQueue.main.async` to `Task { @MainActor }`

* TimelineViews

* scrollable graph, offline trend arrow, landscape mode

* smooth the historic values and project the trend ones (see [LibreTransmitter](https://github.com/dabear/LibreTransmitter/commit/49b50d7995955b76861440e5e34a0accd064d18f))

* log: limit to a number of readings, prepend time, Share menu, record to a file

* Widgets, LiveActivity and App Intents (see [Glucose Direct](https://github.com/creepymonster/GlucoseDirect))

* SwiftData and/or TabularData as persistence layers (see [Glupreview](https://github.com/solanovisitor/glupreview) for CoreML use)
