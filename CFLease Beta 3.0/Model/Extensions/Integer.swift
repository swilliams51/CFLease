//
//  Integer.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 2/4/22.
//

import Foundation


extension Int {
    func toString () -> String {
        return String(self)
    }
}

extension Int {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}


extension Int {
    func toDouble() -> Double {
        return Double(self)
    }
}
