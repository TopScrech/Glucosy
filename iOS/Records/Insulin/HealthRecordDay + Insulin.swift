extension HealthRecordDay where Record == Insulin {
    func total(for type: InsulinType) -> Double {
        records.reduce(0) { total, record in
            total + (record.type == type ? record.value : 0)
        }
    }
}
