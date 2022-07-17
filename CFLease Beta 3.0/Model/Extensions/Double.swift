//
//  Double.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 2/4/22.
//

import Foundation


extension Double {
    func toString () -> String {
        let decValue = Decimal(self)
        return decValue.toString()
    }
}

extension Double {
    func toInteger() -> Int {
        return Int(self)
    }
}
