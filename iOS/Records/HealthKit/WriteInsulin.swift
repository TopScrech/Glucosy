//import HealthKit
//
//extension HealthKit {
//    func writeInsulinDelivery(_ data: HealthRecord...) {
//        guard let insulinType else {
//            return
//        }
//        
//        let samples = data.map {
//            HKQuantitySample(
//                type: insulinType,
//                quantity: .init(
//                    unit: .internationalUnit(),
//                    doubleValue: $0.value
//                ),
//                start: $0.date,
//                end: $0.date
////                metadata: [
////                    "HKInsulinDeliveryReason": $0.type == .basal ? 1 : 2
////                ]
//            )
//#warning("uncomment")
//        }
//        
//        store?.save(samples) { _, error in
//            if let error {
//                print("HealthKit: error while saving insulin delivery:", error)
//            }
//        }
//    }
//}
