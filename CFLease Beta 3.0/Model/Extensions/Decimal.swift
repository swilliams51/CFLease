//
//  Decimal.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 2/4/22.
//

import Foundation

extension Decimal {
    func toString (decPlaces: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.minimumFractionDigits = decPlaces
        formatter.maximumFractionDigits = decPlaces
        return formatter.string(from: self as NSDecimalNumber) ?? "0.0"
    }
}

extension Decimal {
    func toCurrency(_ wSymbol: Bool) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        if wSymbol == false {
            formatter.currencySymbol = ""
        }
        return formatter.string(from: self as NSDecimalNumber) ?? "0.0"
    }
}

extension Decimal {
    func toPercent(_ places: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.percent
        formatter.minimumFractionDigits = places
        formatter.maximumFractionDigits = places
        return formatter.string(from: self as NSDecimalNumber) ?? "0.0"
    }
}

extension Decimal {
    func toInteger() -> Int {
        let dblOf = self.toDouble()
        return dblOf.toInteger()
    }
}

extension Decimal {
    func toDouble() -> Double {
        return Double(self.description)!
    }
}
