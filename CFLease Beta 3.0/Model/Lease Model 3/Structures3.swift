//
//  Structures3.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/1/21.
//

import Foundation

extension Groups {
    func firstAndLast(freq: Frequency, baseCommence: Date, EOMRule: Bool) {
      
        //Insert Two Duplicate Groups
        let newGroup: Group = items[0].clone()
        items.insert(newGroup, at: 0)
        let newGroup2: Group = items[1].clone()
        items.insert(newGroup2, at: 1)
        
        //Get Properties of Group to Change
        let currAmount:Decimal = items[0].amount.toDecimal()
        let currNoOfPayments: Int = items[0].noOfPayments
        var currStartDate: Date = items[0].startDate
        var currEndDate: Date = addOnePeriodToDate(dateStart: currStartDate, payperYear: freq, dateRefer: baseCommence, bolEOMRule: EOMRule)
       
        //Modify 1st Group
        items[0].amount = (currAmount * 2).toString()
        items[0].endDate = currEndDate
        items[0].locked = false
        items[0].noOfPayments = 1
        items[0].undeletable = false
        
        //Modify 2nd Group
        currStartDate = currEndDate
        currEndDate = addPeriodsToDate(dateStart: currStartDate, payPerYear: freq, noOfPeriods: currNoOfPayments - 2, referDate: baseCommence, bolEOMRule: EOMRule)
        items[1].amount = currAmount.toString()
        items[1].endDate = currEndDate
        items[1].locked = false
        items[1].noOfPayments = currNoOfPayments - 2
        items[1].startDate = currStartDate
        items[1].undeletable = true
        
        //Modify 3rd Group
        currStartDate = currEndDate
        currEndDate = addOnePeriodToDate(dateStart: currStartDate, payperYear: freq, dateRefer: baseCommence, bolEOMRule: EOMRule)
        items[2].amount = "0.0"
        items[2].endDate = currEndDate
        items[2].locked = false
        items[2].noOfPayments = 1
        items[2].startDate = currStartDate
        items[2].undeletable = false
    }
    
    func firstAndLastTwo(freq: Frequency, baseCommence: Date, EOMRule: Bool) {
        //Insert Two Duplicate Groups
        let newGroup: Group = items[0].clone()
        items.insert(newGroup, at: 0)
        let newGroup2: Group = items[1].clone()
        items.insert(newGroup2, at: 1)
        
        //Get Properties of Group to Change
        let currAmount:Decimal = items[0].amount.toDecimal()
        let currNoOfPayments: Int = items[0].noOfPayments
        var currStartDate: Date = items[0].startDate
        var currEndDate: Date = addOnePeriodToDate(dateStart: currStartDate, payperYear: freq, dateRefer: baseCommence, bolEOMRule: EOMRule)
       
        //Modify 1st Group
        items[0].amount = (currAmount * 3).toString()
        items[0].endDate = currEndDate
        items[0].locked = false
        items[0].noOfPayments = 1
        
        //Modify 2nd Group
        currStartDate = currEndDate
        currEndDate = addPeriodsToDate(dateStart: currStartDate, payPerYear: freq, noOfPeriods: currNoOfPayments - 3, referDate: baseCommence, bolEOMRule: EOMRule)
        items[1].amount = currAmount.toString()
        items[1].endDate = currEndDate
        items[1].locked = false
        items[1].noOfPayments = currNoOfPayments - 3
        items[1].startDate = currStartDate
        items[1].undeletable = false
        
        //Modify 3rd Group
        currStartDate = currEndDate
        currEndDate = addOnePeriodToDate(dateStart: currStartDate, payperYear: freq, dateRefer: baseCommence, bolEOMRule: EOMRule)
        items[2].amount = "0.0"
        items[2].endDate = currEndDate
        items[2].locked = false
        items[2].noOfPayments = 2
        items[2].startDate = currStartDate
        items[2].undeletable = false
        
    }
    
    func unevenPayments(lowHigh: Bool, freq: Frequency, baseCommence: Date, EOMRule: Bool) {
        //Set Payment Adjustment Factors
        var decFactor1: Decimal = 0.9
        var decFactor2: Decimal = 1.1
        if lowHigh == false {
            decFactor1 = 1.1
            decFactor2 = 0.9
        }
        
        //Get Properties of Current Group
        let currNoOfPayments:Int = items[0].noOfPayments
        var oddNoOfPayments: Bool = false
        let intRemainder: Int = currNoOfPayments % 2
        if intRemainder > 0 {
            oddNoOfPayments = true
        }
        let noOfLevelOne: Int = (currNoOfPayments - intRemainder) / 2
        
        //Insert One Duplicate Group if even Two if Odd
        let newGroup: Group = items[0].clone()
        items.insert(newGroup, at: 0)
        if oddNoOfPayments == true {
            let newGroup2 = items[1].clone()
            items.insert(newGroup2, at: 1)
        }
        
        //Get Starting Properties and Edit First Group
        let currAmount:Decimal = items[0].amount.toDecimal()
        var currStartDate: Date = items[0].startDate
        var currEndDate: Date = addPeriodsToDate(dateStart: currStartDate, payPerYear: freq, noOfPeriods: noOfLevelOne, referDate: baseCommence, bolEOMRule: EOMRule)
        items[0].amount = (currAmount * decFactor1).toString()
        items[0].endDate = currEndDate
        items[0].locked = false
        items[0].noOfPayments = noOfLevelOne
        items[0].startDate = currStartDate
        items[0].undeletable = true
        
        if oddNoOfPayments == true {
            currStartDate = items[0].endDate
            currEndDate = addOnePeriodToDate(dateStart: currStartDate, payperYear: freq, dateRefer: baseCommence, bolEOMRule: EOMRule)
            items[1].amount = currAmount.toString()
            items[1].endDate = currEndDate
            items[1].locked = false
            items[1].noOfPayments = 1
            items[1].startDate = currStartDate
            items[1].undeletable = false
            
            currStartDate = items[0].endDate
            currEndDate = addPeriodsToDate(dateStart: currStartDate, payPerYear: freq, noOfPeriods: noOfLevelOne, referDate: baseCommence, bolEOMRule: EOMRule)
            items[2].amount = (currAmount * decFactor2).toString()
            items[2].endDate = currEndDate
            items[2].locked = false
            items[2].noOfPayments = noOfLevelOne
            items[2].startDate = currStartDate
            items[2].undeletable = false
        } else {
            currStartDate = items[0].endDate
            currEndDate = addPeriodsToDate(dateStart: currStartDate, payPerYear: freq, noOfPeriods: noOfLevelOne, referDate: baseCommence, bolEOMRule: EOMRule)
            items[1].amount = (currAmount * decFactor2).toString()
            items[1].endDate = currEndDate
            items[1].locked = false
            items[1].noOfPayments = noOfLevelOne
            items[1].startDate = currStartDate
            items[1].undeletable = false
        }
    }
    
    func termAmortization(aLease: Lease, amortTerm: Int) {
        let myLease = aLease.deepClone()
        let intPrevNoOfPayments = myLease.groups.items[0].noOfPayments
        let intCurrNoOfPayments = amortTerm * 12 / myLease.paymentsPerYear.rawValue
       
        myLease.groups.items[0].noOfPayments = intCurrNoOfPayments
        myLease.groups.items[0].locked = false
        myLease.solveForUnlockedPayments()
        myLease.groups.items[0].noOfPayments = intPrevNoOfPayments
        myLease.groups.items[0].locked = true
        myLease.groups.items[0].undeletable = true
        
        //Now add balloon
        let strAmount = myLease.groups.items[0].amount
        let dateStart:Date = myLease.groups.items[0].endDate
        let dateEnd: Date = myLease.groups.items[0].endDate
        let myBalloon:Group = Group (
            aAmount: strAmount,
            aEndDate: dateEnd,
            aLocked: true,
            aNoOfPayments: 1,
            aStartDate: dateStart,
            aTiming: .equals,
            aType: .balloon,
            aUndeletable: false)
        myLease.groups.items.append(myBalloon)
        myLease.solveForUnlockedPayments()
        items[0].amount = strAmount
        items.append(myLease.groups.items[1])
    }
    
    func escalate(aLease: Lease, inflationRate: Decimal) {
        let myLease = aLease.deepClone()
        let outerLoops: Int = myLease.getBaseTermInMons() / 12
        let innerLoops: Int = myLease.paymentsPerYear.rawValue
        
        let decAmount: Decimal = myLease.groups.items[0].amount.toDecimal()
        
        var dateStart: Date = myLease.groups.items[0].startDate
        let aTiming: PaymentTiming = myLease.groups.items[0].timing
        myLease.groups.items.removeAll()
        
        var prevAmount = decAmount
        var undeletable: Bool = false
        for x in 0..<outerLoops{
            var escalator: Decimal = 1.0 + (inflationRate / 1000.0)
            if x == 0 {
                escalator = 1
                undeletable = true
            }
            let currAmount = prevAmount * escalator
            let dateEnd = addPeriodsToDate(dateStart: dateStart, payPerYear: myLease.paymentsPerYear, noOfPeriods: innerLoops, referDate: myLease.firstAnniversaryDate, bolEOMRule: myLease.endOfMonthRule)
            let myGroup:Group = Group(
                aAmount: currAmount.toString(),
                aEndDate: dateEnd,
                aLocked: false,
                aNoOfPayments: innerLoops,
                aStartDate: dateStart,
                aTiming: aTiming,
                aType: .payment,
                aUndeletable: undeletable)
            myLease.groups.items.append(myGroup)
            dateStart = dateEnd
            prevAmount = currAmount
            }
        //myLease.solveForUnlockedPayments()
        items.removeAll()
        for x in 0..<myLease.groups.items.count {
            items.append(myLease.groups.items[x])
        }
    }
    
    
    func structureCanBeApplied(freq: Frequency) -> Bool {
        //must be only one group
        guard items.count == 1 else {
            return false
        }
        
        //Check Term is greater than 2 years
        let divisor = Double(freq.rawValue)
        let numerator = Double(items[0].noOfPayments)
        let term: Double = numerator / divisor
        guard term >= 2.0 else {
            return false
        }
        
        //Check Payment Type of Group is Payments
        guard items[0].type == PaymentType.payment else {
            return false
        }
        
        return true
    }
    
}
