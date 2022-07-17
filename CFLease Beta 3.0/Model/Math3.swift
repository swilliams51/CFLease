//
//  Math3.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/1/21.
//

import Foundation

func mxbFactor(factor1: Decimal, value1: Decimal, factor2: Decimal, value2: Decimal) -> Decimal {
    let dbM = slope(y2: value2, y1: value1, x2: factor2, x1: factor1)
    let dbB = yInterecept(mSlope: dbM, x: factor2, y: value2)
    return  (dbB / dbM) * -1.0
}

func slope(y2: Decimal, y1: Decimal, x2: Decimal, x1: Decimal) -> Decimal {
    let dbSlope: Decimal = (y2 - y1) / (x2 - x1)
    return dbSlope
}

func yInterecept(mSlope: Decimal, x: Decimal, y: Decimal) -> Decimal {
    return y - (mSlope * x)
}

func safeDivision (aNumerator: Decimal, aDenominator: Decimal) -> Decimal {
    var quotient: Decimal = 0.0
    
    if aDenominator != 0.0 || aNumerator != 0.0 {
        quotient = aNumerator / aDenominator
    }
    return quotient
}

func amountIsEqualToZero (askAmount: Decimal, aLambda: Decimal) -> Bool {
    var isEqualToZero: Bool = false
    
    let diff = abs(askAmount - aLambda)
    if diff <= aLambda {
        isEqualToZero = true
    }
    return isEqualToZero
}

func amountsAreEqual(aAmt1: Decimal, aAmt2: Decimal, aLamda: Decimal) -> Bool {
    var bolAmtsAreEqual: Bool = false
    
    if abs(aAmt1 - aAmt2) <= aLamda {
        bolAmtsAreEqual = true
    }
    
    return bolAmtsAreEqual
}


func pv (annualRate: Decimal, noOfPaymnents: Int, pmtAmount: Decimal, freq: Frequency, timing: PaymentTiming) -> Decimal {
    let periodicRate: Decimal = annualRate / Decimal(freq.rawValue)
    var runTotalPV: Decimal = 0.0
    var start: Int = 1
    
    if timing == .advance {
        runTotalPV = pmtAmount
        start = 2
    }
    
    for x in start...noOfPaymnents {
        let pv: Decimal = pmtAmount / pow((1 + periodicRate), x)
        runTotalPV = runTotalPV + pv
    }
    
    return runTotalPV
    
}
