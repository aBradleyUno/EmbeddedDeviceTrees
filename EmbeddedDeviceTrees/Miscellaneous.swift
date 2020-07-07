//
//  Miscellaneous.swift
//  dtc
//
//  Created by Alexander Bradley on 8/24/18.
//  Copyright © 2018 UAZ. All rights reserved.
//

import Foundation

extension String {
    var hexaBytes: [UInt8] {
      let hexa = Array(self)
      return stride(from: 0, to: count, by: 2).compactMap { UInt8(String(hexa[$0...$0.advanced(by: 1)]), radix: 16) }
    }
    var hexaData: Data { return hexaBytes.data }
}

extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}

extension Collection where Iterator.Element == UInt8 {
    var data: Data {
        return Data(self)
    }
    var hexa: String {
        return map{ String(format: "%02X", $0) }.joined()
    }
}

func extendArray(array: [UInt8], newSize: Int) -> [UInt8] {
    var newarray: [UInt8] = [UInt8]()
    var i = 0
    let oldSize = array.count
    while i < newSize {
        if i < oldSize {
            newarray.append(array[i])
        } else {
            newarray.append(0)
        }
        i += 1
    }
    return newarray
}

func read32(bytes: [UInt8], offset: Int) -> UInt32 {
    let array = bytes[offset...(offset+3)]
    let data = Data(array)
    return UInt32(littleEndian: data.withUnsafeBytes { $0.pointee })
}

func read64(bytes: [UInt8], offset: Int) -> UInt64 {
    let array = bytes[offset...(offset+7)]
    let data = Data(array)
    return UInt64(littleEndian: data.withUnsafeBytes { $0.pointee })
}

func readkPropName(bytes: [UInt8], offset: Int) -> [UInt8] {
    let arrayOffset = offset + kPropNameLength - 1
    let name = Array(bytes[(offset...arrayOffset)])
    return name
}

func split32(bytes: UInt32) -> [UInt8] {
    var bigEndian = bytes.littleEndian
    let count = MemoryLayout<UInt32>.size
    let bytePtr = withUnsafePointer(to: &bigEndian) {
        $0.withMemoryRebound(to: UInt8.self, capacity: count) {
            UnsafeBufferPointer(start: $0, count: count)
        }
    }
    return Array(bytePtr)
}
