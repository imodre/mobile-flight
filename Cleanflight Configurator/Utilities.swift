//
//  Utilities.swift
//  Cleanflight Configurator
//
//  Created by Raphael Jean-Leconte on 15/12/15.
//  Copyright © 2015 Raphael Jean-Leconte. All rights reserved.
//

import Foundation

func readInt8(array: [UInt8], index: Int) -> Int {
    return Int(Int8(bitPattern: array[index]));
}

func readUInt16(array: [UInt8], index: Int) -> Int {
    return Int(array[index]) + Int(array[index+1]) * 256;
}

func readInt16(array: [UInt8], index: Int) -> Int {
    return Int(array[index]) + Int(Int8(bitPattern: array[index+1])) * 256;
}

func readUInt32(array: [UInt8], index: Int) -> Int {
    var res = Int(array[index+3])
    res = res * 256 + Int(array[index+2])
    res = res * 256 + Int(array[index+1])
    res = res * 256 + Int(array[index])
    return res
}

func readInt32(array: [UInt8], index: Int) -> Int {
    var res = Int(Int8(bitPattern: array[index+3]))
    res = res * 256 + Int(array[index+2])
    res = res * 256 + Int(array[index+1])
    res = res * 256 + Int(array[index])
    return res
}

func writeUInt32(i: Int) -> [UInt8] {
    return [UInt8(i & 0xFF), UInt8((i >> 8) & 0xFF), UInt8((i >> 16) & 0xFF), UInt8((i >> 24) & 0xFF)]
}

func writeInt32(i: Int) -> [UInt8] {
    return writeUInt32(i)
}

func writeUInt16(i: Int) -> [UInt8] {
    return [UInt8(i & 0xFF), UInt8((i >> 8) & 0xFF)]
}

func writeInt16(i: Int) -> [UInt8] {
    return writeUInt16(i)
}

func writeInt8(i: Int) -> UInt8 {
    return UInt8(bitPattern: Int8(i))
}

// Easy formatting of a double value with 1 decimal if < 10, no decimal otherwise. Unit appended to the result.
func formatWithUnit(reading: Double, unit: String) -> String {
    if reading < 10 {
        return String(format: "%.1f%@", locale: NSLocale.currentLocale(), reading, unit)
    } else {
        return String(format: "%.0f%@", locale: NSLocale.currentLocale(), reading, unit)
    }
}

func formatDistance(meters: Double) -> String {
    if useImperialUnits() {
        if meters >= 1852 {
            // Use nautical mile
            return formatWithUnit(meters / 1852, unit: "NM")
        } else {
            // Use feet
            return formatWithUnit(meters * 100 / 2.54 / 12, unit: "ft")
        }
    } else {
        // Meters
        return formatWithUnit(meters, unit: "m")
    }
}

func formatAltitude(meters: Double, appendUnit: Bool = true) -> String {
    if useImperialUnits() {
        // Feet
        return formatWithUnit(meters * 100 / 2.54 / 12, unit: appendUnit ? "ft" : "")
    } else {
        // Meters
        return formatWithUnit(meters, unit: appendUnit ? "m" : "")
    }
}

func formatSpeed(kmh: Double) -> String {
    if useImperialUnits() {
        // Knots
        return formatWithUnit(kmh / 1.852, unit: "kn")
    } else {
        // Meters
        return formatWithUnit(kmh, unit: "km/h")
    }
}

func useImperialUnits() -> Bool {
    switch userDefaultAsString(.UnitSystem) {
    case "imperial":
        return true
    case "metric":
        return false
    default:
        return !(NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem) as? Bool ?? true)
    }
    
}

func constrain(n: Double, min minimum: Double, max maximum: Double) -> Double {
    return min(maximum, max(minimum, n))
}

func applyDeadband(value: Double, width: Double) -> Double {
    if abs(value) < width {
        return 0
    } else if (value > 0) {
        return value - width
    } else {
        return value + width
    }
}

/// Returns the distance in meters between two 2D positions
func getDistance(p1: Position, _ p2: Position) -> Double {
    // Earth radius in meters
    return 6378137.0 * getArcInRadians(p1, p2)
}

private func getArcInRadians(p1: Position, _ p2: Position) -> Double {
    let latitudeArc = (p1.latitude - p2.latitude) * M_PI / 180
    let longitudeArc = (p1.longitude - p2.longitude) * M_PI / 180
    
    var latitudeH = sin(latitudeArc / 2)
    latitudeH *= latitudeH
    var longitudeH = sin(longitudeArc / 2)
    longitudeH *= longitudeH
    
    let tmp = cos(p1.latitude * M_PI / 180) * cos(p2.latitude * M_PI / 180)
    
    return 2 * asin(sqrt(latitudeH + tmp * longitudeH))
}
