import Foundation

// TODO: move here specific Libre code from Sensor class

typealias SensorUid = Data
typealias PatchInfo = Data

extension SensorType {
    init(patchInfo: PatchInfo) {
        self = switch patchInfo[0] {
        case 0xDF, 0xA2: .libre1
        case 0xE5, 0xE6: .libreUS14day
        case 0x70:       .libreProH
        case 0x9D, 0xC5: .libre2
            
        case 0x76, 0x2B:
            patchInfo[3] == 2 ? .libre2US :
            patchInfo[3] == 4 ? .libre2CA :
            patchInfo[3] == 8 ? .libre2RU :
            patchInfo[2] >> 4 == 7 ? .libreSense :
                .unknown
            
        default:
            if patchInfo.count == 24 {
                .libre3
            } else {
                .unknown
            }
        }
    }
}

// https://github.com/UPetersen/LibreMonitor/blob/Swift4/LibreMonitor/Model/SensorSerialNumber.swift

func serialNumber(uid: SensorUid, family: SensorFamily = .libre1) -> String {
    let lookupTable = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "C", "D", "E", "F", "G", "H", "J", "K", "L", "M", "N", "P", "Q", "R", "T", "U", "V", "W", "X", "Y", "Z"]
    
    guard uid.count == 8 else {
        return ""
    }
    
    let bytes = Array(uid.reversed().suffix(6))
    
    var fiveBitsArray = [UInt8]()
    fiveBitsArray.append(bytes[0] >> 3)
    fiveBitsArray.append(bytes[0] << 2 + bytes[1] >> 6)
    fiveBitsArray.append(bytes[1] >> 1)
    fiveBitsArray.append(bytes[1] << 4 + bytes[2] >> 4)
    fiveBitsArray.append(bytes[2] << 1 + bytes[3] >> 7)
    fiveBitsArray.append(bytes[3] >> 2)
    fiveBitsArray.append(bytes[3] << 3 + bytes[4] >> 5)
    fiveBitsArray.append(bytes[4])
    fiveBitsArray.append(bytes[5] >> 3)
    fiveBitsArray.append(bytes[5] << 2)
    
    return fiveBitsArray.reduce("\(family.rawValue)") {
        $0 + lookupTable[ Int(0x1F & $1) ]
    }
}

// https://github.com/UPetersen/LibreMonitor/blob/Swift4/LibreMonitor/Model/CRC.swift

func crc16(_ data: Data) -> UInt16 {
    let crc16table: [UInt16] = [0, 4489, 8978, 12955, 17956, 22445, 25910, 29887, 35912, 40385, 44890, 48851, 51820, 56293, 59774, 63735, 4225, 264, 13203, 8730, 22181, 18220, 30135, 25662, 40137, 36160, 49115, 44626, 56045, 52068, 63999, 59510, 8450, 12427, 528, 5017, 26406, 30383, 17460, 21949, 44362, 48323, 36440, 40913, 60270, 64231, 51324, 55797, 12675, 8202, 4753, 792, 30631, 26158, 21685, 17724, 48587, 44098, 40665, 36688, 64495, 60006, 55549, 51572, 16900, 21389, 24854, 28831, 1056, 5545, 10034, 14011, 52812, 57285, 60766, 64727, 34920, 39393, 43898, 47859, 21125, 17164, 29079, 24606, 5281, 1320, 14259, 9786, 57037, 53060, 64991, 60502, 39145, 35168, 48123, 43634, 25350, 29327, 16404, 20893, 9506, 13483, 1584, 6073, 61262, 65223, 52316, 56789, 43370, 47331, 35448, 39921, 29575, 25102, 20629, 16668, 13731, 9258, 5809, 1848, 65487, 60998, 56541, 52564, 47595, 43106, 39673, 35696, 33800, 38273, 42778, 46739, 49708, 54181, 57662, 61623, 2112, 6601, 11090, 15067, 20068, 24557, 28022, 31999, 38025, 34048, 47003, 42514, 53933, 49956, 61887, 57398, 6337, 2376, 15315, 10842, 24293, 20332, 32247, 27774, 42250, 46211, 34328, 38801, 58158, 62119, 49212, 53685, 10562, 14539, 2640, 7129, 28518, 32495, 19572, 24061, 46475, 41986, 38553, 34576, 62383, 57894, 53437, 49460, 14787, 10314, 6865, 2904, 32743, 28270, 23797, 19836, 50700, 55173, 58654, 62615, 32808, 37281, 41786, 45747, 19012, 23501, 26966, 30943, 3168, 7657, 12146, 16123, 54925, 50948, 62879, 58390, 37033, 33056, 46011, 41522, 23237, 19276, 31191, 26718, 7393, 3432, 16371, 11898, 59150, 63111, 50204, 54677, 41258, 45219, 33336, 37809, 27462, 31439, 18516, 23005, 11618, 15595, 3696, 8185, 63375, 58886, 54429, 50452, 45483, 40994, 37561, 33584, 31687, 27214, 22741, 18780, 15843, 11370, 7921, 3960]
    
    var crc = data.reduce(UInt16(0xFFFF)) {
        ($0 >> 8) ^ crc16table[Int(($0 ^ UInt16($1)) & 0xFF)]
    }
    
    var reverseCrc = UInt16(0)
    
    for _ in 0..<16 {
        reverseCrc = reverseCrc << 1 | crc & 1
        crc >>= 1
    }
    
    return reverseCrc
}

// https://github.com/dabear/LibreTransmitter/blob/main/LibreSensor/SensorContents/SensorData.swift

func readBits(_ buffer: Data, _ byteOffset: Int, _ bitOffset: Int, _ bitCount: Int) -> Int {
    guard bitCount != 0 else {
        return 0
    }
    
    var res = 0
    
    for i in 0..<bitCount {
        let totalBitOffset = byteOffset * 8 + bitOffset + i
        let byte = Int(floor(Float(totalBitOffset) / 8))
        let bit = totalBitOffset % 8
        
        if totalBitOffset >= 0 && ((buffer[byte] >> bit) & 0x1) == 1 {
            res |= 1 << i
        }
    }
    
    return res
}

func writeBits(_ buffer: Data, _ byteOffset: Int, _ bitOffset: Int, _ bitCount: Int, _ value: Int) -> Data {
    var res = buffer
    
    for i in 0..<bitCount {
        let totalBitOffset = byteOffset * 8 + bitOffset + i
        let byte = Int(floor(Double(totalBitOffset) / 8))
        let bit = totalBitOffset % 8
        let bitValue = (value >> i) & 0x1
        
        res[byte] = (res[byte] & ~(1 << bit) | (UInt8(bitValue) << bit))
    }
    
    return res
}

@Observable
class Libre: Sensor {
    
}

func encodeStatusCode(_ status: UInt64) -> String {
    let alphabet = ["0123456789ACDEFGHJKLMNPQRTUVWXYZ"]
    var code = ""
    
    for i in 0...9 {
        code.append(alphabet[Int(status >> (i * 5)) & 0x1F])
    }
    
    return code
}

func decodeStatusCode(_ code: String) -> UInt64 {
    let alphabet = ["0123456789ACDEFGHJKLMNPQRTUVWXYZ"]
    let chars = [code]
    var status: UInt64 = 0
    
    for i in 0...9 {
        status += UInt64(alphabet.firstIndex(of: chars[i])!) << (i * 5)
    }
    
    return status
}

func checksummedFRAM(_ data: Data) -> Data {
    var fram = data
    
    let headerCRC = crc16(fram[         2 ..<  24]) /// 3 * 8
    let bodyCRC   = crc16(fram[ 3 * 8 + 2 ..< 320]) /// 40 * 8
    let footerCRC = crc16(fram[40 * 8 + 2 ..< 344]) /// 43 * 8
    
    fram[0...1]     = headerCRC.data
    fram[24...25]   = bodyCRC.data /// 3 * 8...3 * 8 + 1
    fram[320...321] = footerCRC.data /// 40 * 8...40 * 8 + 1
    
    if fram.count > 344 { /// 43 * 8
        let commandsCRC = crc16(fram[43 * 8 + 2 ..< (244 - 6) * 8]) // Libre 1 DF: 429e, A2: f9ae
        fram[43 * 8...43 * 8 + 1] = commandsCRC.data
    }
    
    return fram
}

struct LibreMemoryRegion {
    let numberOfBytes: Int
    let startAddress:  Int
}

// TODO
func decodeFailure(error: UInt8) -> String {
    switch error {
    case 0x01: "ADC IRQ overflow"
    case 0x05: "MMI interrupt"
    case 0x09: "error in patch table"
    case 0x0A: "low voltage occurred"
    case 0x0B: "low voltage occurred"
    case 0x0C: "FRAM header section CRC error"
    case 0x0D: "FRAM body section CRC error"
    case 0x0E: "FRAM footer section CRC error"
    case 0x0F: "FRAM code section CRC error"
    case 0x10: "FRAM Lock Table error"
    case 0x13: "brownout"
    case 0x28: "battery low indication"
    case 0x34: "from custom E1 and E2 command"
    default:   "no specific info"
    }
}
