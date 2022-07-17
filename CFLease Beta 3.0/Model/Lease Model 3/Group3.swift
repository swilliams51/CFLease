//
//  Group3.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/1/21.
//

import Foundation

struct Group: Identifiable {
    var id = UUID()
    var amount: String
    var endDate: Date
    var locked: Bool
    var noOfPayments: Int
    var startDate: Date
    var timing: PaymentTiming
    var type: PaymentType
    var undeletable: Bool
    var payments = Payments()
    
    init(aAmount: String, aEndDate: Date, aLocked: Bool, aNoOfPayments: Int, aStartDate: Date, aTiming: PaymentTiming, aType: PaymentType, aUndeletable: Bool) {
        amount = aAmount
        endDate = aEndDate
        locked = aLocked
        noOfPayments = aNoOfPayments
        startDate = aStartDate
        timing = aTiming
        type = aType
        undeletable = aUndeletable
    }
    
    mutating func noOfMonthsInGroup() -> Int {
        var months: Int = 0
        
        if noOfPayments > 1 {
            months = monthsBetween(start: startDate, end: endDate)
        }
        
        return months
    }
    

    mutating func clone() -> Group {
        let stringGroup = writeGroup(aGroup: self)
        let clone: Group = readGroup(strGroup: stringGroup)
        return clone
    }
    
    mutating func isCalculatedPaymentType() -> Bool {
        var bolIsCalcPayment: Bool = false
        
        if type == .deAll || type == .deNext || type == .interest {
            bolIsCalcPayment = true
        }
        return bolIsCalcPayment
    }
    
    mutating func isDefaultPaymentType() -> Bool {
        var bolIsDefaultPaymentType: Bool = false
        
        if type == .interest || type == .payment || type == .principal {
            bolIsDefaultPaymentType = true
        }
        return bolIsDefaultPaymentType
    }
    
    mutating func isInterimPaymentGroup(freq: Frequency, eomRule: Bool, refer: Date) -> Bool {
        let isPaymentPeriodic: Bool = isDatePeriodic(compareDate: startDate, askDate: endDate, aFreq: freq, endOfMonthRule: eomRule, referDate: refer)
        if isPaymentPeriodic == false && noOfPayments == 1 {
            return true
        } else {
            return false
        }
    }
    
    mutating func isResidualPaymentType() -> Bool {
        var bolIsResidualPaymentType: Bool = false
        
        if type == .balloon || type == .residual {
            bolIsResidualPaymentType = true
        }
        return bolIsResidualPaymentType
    }
    
}
