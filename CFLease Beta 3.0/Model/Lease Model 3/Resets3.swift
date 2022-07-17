//
//  Resets3.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/1/21.
//

import Foundation

extension Lease {
    
   // Mark - Date Resets
    func resetForBaseTermCommenceDateChange() {
        firstAnniversaryDate = setFirstAnniversaryDate()
        let bolIsInterimPayment: Bool = groups.items[0].isInterimPaymentGroup(freq: paymentsPerYear, eomRule: endOfMonthRule, refer: firstAnniversaryDate)
        
        if bolIsInterimPayment == true {
            if baseTermCommenceDate == fundingDate {
                groups.items.remove(at: 0)
                resetFirstGroup(isInterim: false)
            } else {
                resetFirstGroup(isInterim: true)
            }
        } else {
            if baseTermCommenceDate == fundingDate {
                resetFirstGroup(isInterim: false)
            } else {
                let newGroup = Group(aAmount: "CALCULATED", aEndDate: baseTermCommenceDate, aLocked: true, aNoOfPayments: 1, aStartDate: fundingDate, aTiming: PaymentTiming.arrears, aType: PaymentType.deNext, aUndeletable: true)
                groups.items.insert(newGroup, at: 0)
                resetFirstGroup(isInterim: true)
            }
        }
        baseTerm = getBaseTermInMons()
    }
    
    func resetForFundingDateChange() {
        baseTermCommenceDate = fundingDate
        firstAnniversaryDate = setFirstAnniversaryDate()
        if groups.items[0].noOfPayments == 1 {
            groups.items.remove(at: 0)
        }
        resetFirstGroup(isInterim: false)
    }
    
    //Mark - Frequency Resets
    func resetForFrequencyChange() {
        var bolInterimExists: Bool = true
        if baseTermCommenceDate == fundingDate {
            bolInterimExists = false
        }
    
        for x in 0..<groups.items.count {
            let currNoOfPayments: Decimal = Decimal(groups.items[x].noOfPayments)
            let groupTermInMons: Decimal = Decimal(monthsBetween(start: groups.items[x].startDate, end: groups.items[x].endDate))
            var newNoOfPayments: Decimal = 1.0
                
            if currNoOfPayments > 1 {
                switch paymentsPerYear {
                    case .monthly:
                        newNoOfPayments = groupTermInMons
                    case .quarterly:
                        newNoOfPayments = groupTermInMons / 3
                    case .semiannual:
                        newNoOfPayments = groupTermInMons / 6
                    case .annual:
                        newNoOfPayments = groupTermInMons / 12
                    }
            }
            groups.items[x].noOfPayments = newNoOfPayments.toInteger()
        }
        firstAnniversaryDate = setFirstAnniversaryDate()
        resetFirstGroup(isInterim: bolInterimExists)
    }

    //Mark - Group Resets
    func resetGroup(aGroup: Group, item: Int) {
        groups.items[item].amount = aGroup.amount
        groups.items[item].endDate = aGroup.endDate
        groups.items[item].locked = aGroup.locked
        groups.items[item].noOfPayments = aGroup.noOfPayments
        groups.items[item].startDate = aGroup.startDate
        groups.items[item].timing = aGroup.timing
        groups.items[item].type = aGroup.type
    }
    
    func resetFirstGroup(isInterim: Bool) {
        if isInterim == true {
            groups.items[0].startDate = fundingDate
            groups.items[0].endDate = baseTermCommenceDate
        } else {
            if groups.items[0].noOfPayments > 1 {
                groups.items[0].startDate = fundingDate
                groups.items[0].endDate = addPeriodsToDate(dateStart: fundingDate, payPerYear: paymentsPerYear, noOfPeriods: groups.items[0].noOfPayments, referDate: fundingDate, bolEOMRule: endOfMonthRule)
            } else {
                groups.items[0].startDate = fundingDate
                groups.items[0].endDate = addOnePeriodToDate(dateStart: fundingDate, payperYear: paymentsPerYear, dateRefer: fundingDate, bolEOMRule: endOfMonthRule)
            }
        }
        if groups.items.count > 1 {
            resetRemainderOfGroups(startGrp: 1)
        } else {
            baseTerm = getBaseTermInMons()
        }
    }
    
    
    func resetRemainderOfGroups(startGrp: Int) {
        var x: Int = startGrp
        
        while x < groups.items.count {
            let lastEndDate: Date = groups.items[x - 1].endDate
            groups.items[x].startDate = lastEndDate
            var dateEnd: Date
            
            switch groups.items[x].type {
            case .balloon:
                dateEnd = lastEndDate
            case .funding:
                dateEnd = lastEndDate
            case .residual:
                dateEnd = lastEndDate
            default:
                dateEnd = addPeriodsToDate(dateStart: groups.items[x].startDate, payPerYear: paymentsPerYear, noOfPeriods: groups.items[x].noOfPayments, referDate: firstAnniversaryDate, bolEOMRule: endOfMonthRule)
            }
            groups.items[x].endDate = dateEnd
            x = x + 1
        }
        baseTerm = getBaseTermInMons()
    }
    
// Mark - Lease Resets
    func resetLeaseToChop(modDate: Date) {
        var tempLease: Lease = self.deepClone()
        tempLease = newLeaseAfterSale(aLease: tempLease, modDate: modDate)
        let strTempLease = writeLeaseAndClasses(aLease: tempLease)
        readLeaseFromString(strFile: strTempLease)
    }
    
    func  resetLeaseToDefault(useSaved: Bool, currSaved: String) {
        if useSaved == true && currSaved != "No_Data" {
            readLeaseFromString(strFile: currSaved)
            fundingDate = today()
            resetForFundingDateChange()
        } else {
            let tempLease: Lease = Lease(aDate: today())
            let strLease:String = writeLeaseAndClasses(aLease: tempLease)
            readLeaseFromString(strFile: strLease)
        }
    }

    func resetLeaseToEBO(aLease: Lease, modDate: Date, amount: String) -> Lease {
        let tempLease:Lease = eboLease(aLease: aLease, modDate: modDate, rentDueIsPaid: aLease.earlyBuyOut!.rentDueIsPaid)
        tempLease.groups.items[tempLease.groups.items.count - 1].amount = amount
        tempLease.solveForRate()
        
        return tempLease
    }
    
    //Mark - Class Resets
    func resetLease() {
        resetEarlyBuyOut()
        resetLesseePaidFee()
        resetLesseeObligations()
        resetPurchaseFee()
        resetTerminations()
        modificationDate = "01/01/1900"
    }
    
    func resetEarlyBuyOut() {
        self.earlyBuyOut = EarlyPurchaseOption(aLease: self)
    }
    
    func resetTerminations() {
        terminations!.discountRate_Rent = interestRate.toDecimal()
        terminations!.discountRate_Residual = interestRate.toDecimal()
        terminations!.additionalResidual = 0.00
    }
    
    func resetLesseePaidFee() {
        lesseePaidFee = "0.00"
    }
    
    func resetPurchaseFee() {
        purchaseFee = "0.00"
    }
    
    func resetLesseeObligations() {
        leaseObligations!.discountRate = interestRate
        leaseObligations?.residualGuarantyAmount = "0.00"
    }
}


