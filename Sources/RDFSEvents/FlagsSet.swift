//
//  FlagsSet.swift
//  RDFSEvents
//
//  Created by Roman Dzieciol on 3/31/19.
//

import Foundation

public protocol FlagsSet: OptionSet, Hashable, CustomStringConvertible where RawValue: FixedWidthInteger {
    static var flagNames: [Self: String] { get }
}

extension FlagsSet {

    public var hashValue: Int { return rawValue.hashValue }

    public var description: String {
        var result: [String] = []
        for i in 0..<RawValue.bitWidth {
            let value = RawValue(1) << i
            if (value & rawValue) == value {
                if let name = Self.flagNames[Self.init(rawValue: value)] {
                    result.append("." + name)
                } else {
                    result.append("bit_\(i)")
                }
            }
        }
        return "[" + result.joined(separator: ", ") + "]"
    }

}
