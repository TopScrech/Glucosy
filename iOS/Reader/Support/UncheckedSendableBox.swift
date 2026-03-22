struct UncheckedSendableBox<Value>: @unchecked Sendable {
    nonisolated(unsafe) let value: Value

    nonisolated init(value: Value) {
        self.value = value
    }
}
