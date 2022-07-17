//
//  Targeting3.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/1/21.
//

import Foundation

extension Lease {
    func solveForPrincipal() {
        let myLease = self.clone()
        var x = 0
        var myCFs: Cashflows
        
        var decNPV: Decimal = amount.toDecimal()
        
        while x < maxIterations {
            myCFs = getLeaseCashflow(aLease: myLease)
            decNPV = myCFs.XNPV(aDiscountRate: myLease.interestRate.toDecimal(), aDayCountMethod: myLease.interestCalcMethod)
            myLease.amount = decNPV.toString(decPlaces: 6)
            let decBalance = myLease.getEndingBalance()
            if abs(decBalance) < toleranceAmounts {
                break
            }
            x += 1
        }
        amount = decNPV.toString(decPlaces: 5)
    }
    
    func getLeaseCashflow(aLease: Lease) -> Cashflows {
        let tempLease: Lease = aLease.clone()
        let newCFs: Cashflows = Cashflows(aLease: tempLease, returnType: .funding, aFactor: 1.0)
        
        return newCFs
    }
    
    func getBalanceAfterNewAmount(aLease: Lease, aAmount: Decimal) -> Decimal {
        aLease.amount = aAmount.toString()
        return aLease.getEndingBalance()
    }
}

extension Lease {
    func solveForUnlockedPayments() {
        let myLease = self.clone()
        let tempGroups = myLease.groups
        var x1: Decimal = 1.0
        var x2: Decimal = 0.8
        
        let startEndingBalance: Decimal = getEndingBalance()
        
        if abs(startEndingBalance) > myLease.amount.toDecimal() * 0.10  {
            x1 = firstAdjustmentFactor(aGroups: tempGroups, aAmount: myLease.amount.toDecimal())
        }
        if getBalanceAfterNewFactor(aLease: myLease, aFactor: x1) < 0.0 {
            x2 = 0.8 * x1
        } else {
            x2 = 1.2 * x1
        }
        
        var y1: Decimal = getBalanceAfterNewFactor(aLease: myLease, aFactor: x1)
        var y2: Decimal = getBalanceAfterNewFactor(aLease: myLease, aFactor: x2)
     
        var iCounter = 0
        var myFactor: Decimal = 1.0
        while iCounter < maxIterations {
            myFactor = mxbFactor(factor1: x1, value1: y1, factor2: x2, value2: y2)
            let myBalance = getBalanceAfterNewFactor(aLease: myLease, aFactor: myFactor)
            if abs(myBalance) < toleranceAmounts {
                break
            }
            x1 = myFactor
            y1 = myBalance
            x2 = myFactor + (1 / Decimal(iCounter))
            y2 = getBalanceAfterNewFactor(aLease: myLease, aFactor: x2)
            iCounter = iCounter + 1
        }
        
        if iCounter == maxIterations {
            myFactor = 1
        }
        
        for x in 0..<groups.items.count{
            if groups.items[x].locked == false {
                if groups.items[x].isCalculatedPaymentType() == false {
                    let adjustedAmount: Decimal = groups.items[x].amount.toDecimal() * myFactor
                    groups.items[x].amount = adjustedAmount.toString(decPlaces: 6)
                }
            }
        }
        
    }
    
    func getBalanceAfterNewFactor (aLease: Lease, aFactor: Decimal) -> Decimal {
        let tempLease: Lease = aLease.clone()
        
        for x in 0..<tempLease.groups.items.count {
            if tempLease.groups.items[x].locked == false {
                if tempLease.groups.items[x].isCalculatedPaymentType() == false {
                    let adjustedAmount: Decimal = tempLease.groups.items[x].amount.toDecimal() * aFactor
                    tempLease.groups.items[x].amount = adjustedAmount.toString(decPlaces: 8)
                }
            }
        }
        
        
        let decBalance = tempLease.getEndingBalance()
       
        return decBalance
    }
    
    func firstAdjustmentFactor (aGroups: Groups, aAmount: Decimal) -> Decimal {
        let myGroups = aGroups
        var amountLocked: Decimal = 0.0
        var amountUnlocked: Decimal = 0.0
        var noOfPaymentsUnlocked: Int = 0
        var runTotalNoOfPayments: Int = 0
        var runTotalLocked: Decimal = 0.0
        var runTotalUnlocked: Decimal = 0.0
        
        for x in 0..<myGroups.items.count {
            if myGroups.items[x].locked == true {
                if myGroups.items[x].isCalculatedPaymentType() == true {
                    amountLocked = 0.0
                } else {
                    amountLocked = Decimal(myGroups.items[x].noOfPayments) * (myGroups.items[x].amount.toDecimal())
                }
                runTotalLocked = runTotalLocked + amountLocked
            } else {
                if myGroups.items[x].amount.toDecimal() == 0.0 {
                    amountUnlocked = 0.0
                } else {
                    noOfPaymentsUnlocked = myGroups.items[x].noOfPayments
                    amountUnlocked = Decimal(myGroups.items[x].noOfPayments) * (myGroups.items[x].amount.toDecimal())
                }
                runTotalNoOfPayments = runTotalNoOfPayments + noOfPaymentsUnlocked
                runTotalUnlocked = runTotalUnlocked + amountUnlocked
            }
        }
        
        let avgPayment = runTotalUnlocked / Decimal(runTotalNoOfPayments)
        let requiredPayment = (aAmount - runTotalLocked) / Decimal(runTotalNoOfPayments)
        return  requiredPayment / avgPayment
    }
}

extension Lease {
    func solveForRate() {
        let myLease = self.clone()
        let avgLife = getAverageLifeEstimate(aLease: myLease)
        var prevRate: Decimal = estimatedRate(decAmount: myLease.amount.toDecimal(), decNetTotal: myLease.getNetAmount(), averageLife: avgLife)
        var iCounter = 1
        var y1: Decimal = getBalanceAfterNewRate(aLease: myLease, newRate: prevRate)
        var currRate: Decimal = getNewRate(aLease: myLease, currRate: prevRate, prevRate: 0.0)
        var y2 = getBalanceAfterNewRate(aLease: myLease, newRate: currRate)
        
        var newRate: Decimal = 0.0
         while iCounter < 5 {
            newRate = mxbFactor(factor1: prevRate, value1: y1, factor2: currRate, value2: y2)
            let myBalance = getBalanceAfterNewRate(aLease: myLease, newRate: newRate)
            if abs(myBalance) < 0.001 {
                break
            }
            prevRate = newRate
            iCounter = iCounter + 1
            y1 = myBalance
             currRate = getNewRate(aLease: myLease, currRate: prevRate, prevRate: currRate)
            y2 = getBalanceAfterNewRate(aLease: myLease, newRate: currRate)
        }
        
        if iCounter == 5 {
            interestRate = newRate.toString(decPlaces: 10)
            myLease.groups.unlockAllGroups()
            solveForUnlockedPayments()
        } else {
            interestRate = newRate.toString(decPlaces: 10)
        }
    }
    
    func estimatedRate (decAmount: Decimal, decNetTotal: Decimal, averageLife: Decimal) -> Decimal {
        let totalInterest: Decimal = decNetTotal
        let annualInterest: Decimal = totalInterest / averageLife
        let guessInterestRate: Decimal = annualInterest / decAmount
    
        return guessInterestRate
    }
    
    func getAverageLifeEstimate(aLease: Lease) -> Decimal {
        let avgLifeLease = aLease.clone()
        avgLifeLease.groups.unlockAllGroups()
        avgLifeLease.interestRate = "0.10"
        avgLifeLease.solveForUnlockedPayments()
        let myAvgLife = AverageLives(aLease: avgLifeLease)
        let avgLife = myAvgLife.getWeightedAverageLife()
        
        return avgLife
    }
    
    
    func getBalanceAfterNewRate(aLease: Lease, newRate: Decimal) -> Decimal {
        let tempLease = aLease.clone()
        tempLease.interestRate = newRate.toString(decPlaces: 10)
        let decBalance = tempLease.getEndingBalance()
       
        return decBalance
    }
    
    func getNewRate(aLease: Lease, currRate: Decimal, prevRate: Decimal) -> Decimal {
        var newRate: Decimal = currRate
        var factor:Decimal = 0.001
        
        if prevRate > 0.0 {
            factor = abs(currRate - prevRate) / 10.0
        }
        
        newRate = currRate
        var y2 = getBalanceAfterNewRate(aLease: aLease, newRate: newRate)
        
        if y2 < 0.0 {
            while y2 < 0.0 {
                newRate = newRate + factor
                y2 = getBalanceAfterNewRate(aLease: aLease, newRate: newRate)
            }
        } else {
            while y2 > 0.0 {
                newRate = newRate - factor
                y2 = getBalanceAfterNewRate(aLease: aLease, newRate: newRate)
            }
        }
        return newRate
    }
}

extension Lease {
    func isSolveForTermValid(maxBase: Int) -> Bool {
        var bolSolveForTermIsValid: Bool = false
        let myLease = self.clone()

        guard myLease.groups.getNumberOfUnlockedGroups() == 1 else {
            return false
        }

        let grpNo: Int = myLease.groups.getIndexOfUnlocked()

        guard grpNo > -1 else {
            return false
        }

        guard myLease.groups.items[grpNo].noOfPayments > 1 else {
            return false
        }

        guard myLease.groups.items[grpNo].type != .interest else {
            return false
        }

        myLease.createPayments()
        let decBalance: Decimal = myLease.getEndingBalance()
        myLease.resetPayments()
        if decBalance > 0.0 {
            if testForIncreasingTerm(aLease: myLease, aGrpNo: grpNo, maxBase: maxBase) == true {
                bolSolveForTermIsValid = true
            }
        } else {
            if testForDecreasingTerm(aLease: myLease, aGrpNo: grpNo) == true {
              bolSolveForTermIsValid = true
            }
        }

        return bolSolveForTermIsValid
}
    
    func testForIncreasingTerm(aLease: Lease, aGrpNo: Int, maxBase: Int) -> Bool {
        var testIsValid: Bool = false
        let tempLease: Lease = aLease.clone()
        
        while tempLease.groups.items[aGrpNo].noOfPayments < aLease.getMaxRemainNumberPayments(maxBaseTerm: maxBase, freq: aLease.paymentsPerYear, eom: aLease.endOfMonthRule, aRefer: aLease.firstAnniversaryDate) {
           
            let decBalance: Decimal = tempLease.getEndingBalance()
            if decBalance < 0.0 {
                testIsValid = true
                break
            }
            
            let intNumber = tempLease.groups.items[aGrpNo].noOfPayments + 1
            tempLease.groups.items[aGrpNo].noOfPayments = intNumber
        }
        return testIsValid
    }
    
    func testForDecreasingTerm(aLease: Lease, aGrpNo: Int) -> Bool {
        var testIsValid: Bool = false
        let tempLease: Lease = aLease.clone()
        
        while tempLease.groups.items[aGrpNo].noOfPayments > aLease.getMinTotalNumberPayments() {
            
            let decBalance: Decimal = tempLease.getEndingBalance()
            
            if decBalance > 0.0 {
                testIsValid = true
                break
            }
            let intNumber = tempLease.groups.items[aGrpNo].noOfPayments - 1
            tempLease.groups.items[aGrpNo].noOfPayments = intNumber
        }
        
        return testIsValid
    }
}

extension Lease {
    func solveForTerm(maxBase: Int) {
        let idx: Int = groups.getIndexOfUnlocked()
        let decBalance: Decimal = self.getEndingBalance()

            if decBalance > 0.0 {
                solveForIncreasingTerm(grpNo: idx, maxBase: maxBase)
            } else {
                solveForDecreasingTerm(grpNo: idx)
            }
        groups.unlockAllGroups()
    }
    
    func solveForIncreasingTerm(grpNo: Int, maxBase: Int) {
        let maxNumber: Int = self.getMaxRemainNumberPayments(maxBaseTerm: maxBase, freq: self.paymentsPerYear, eom: self.endOfMonthRule, aRefer: self.firstAnniversaryDate)
        var intNumber: Int = 0
        let startNoOfPayments = self.groups.items[grpNo].noOfPayments
        var newNoOfPayments: Int = startNoOfPayments
        
        while intNumber < maxNumber {
            let decBalance: Decimal = self.getEndingBalance()
            if decBalance < 0.0 {
                break
            }
            
            intNumber += 1
            newNoOfPayments = startNoOfPayments + intNumber
            self.groups.items[grpNo].noOfPayments = newNoOfPayments
        }
        
        if intNumber == maxNumber {
            newNoOfPayments = startNoOfPayments
        } else {
            newNoOfPayments = newNoOfPayments - 1
        }

        self.groups.items[grpNo].noOfPayments = newNoOfPayments
        self.groups.items[grpNo].locked = true
        let endDate: Date = self.groups.items[grpNo].endDate
        self.groups.items[grpNo].endDate = subtractOnePeriodFromDate(dateStart: endDate, payperYear: self.paymentsPerYear, dateRefer: self.firstAnniversaryDate, bolEOMRule: self.endOfMonthRule)

        // add 1 new payment group, unlock the group and solve for unlocked payments
        let strAmount:String = self.groups.items[grpNo].amount
        let grpStart:Date = self.groups.items[grpNo].endDate
        let grpEnd:Date = addOnePeriodToDate(dateStart: self.groups.items[grpNo].endDate, payperYear: self.paymentsPerYear, dateRefer: self.firstAnniversaryDate, bolEOMRule: self.endOfMonthRule)
        let aTiming:PaymentTiming = groups.items[grpNo].timing
        let aType: PaymentType = groups.items[grpNo].type
        
        let myGroup = Group(aAmount: strAmount, aEndDate: grpEnd, aLocked: false, aNoOfPayments: 1, aStartDate: grpStart, aTiming: aTiming, aType: aType, aUndeletable: false)
      
        self.groups.items.insert(myGroup, at: grpNo + 1)
        self.resetFirstGroup(isInterim: self.interimGroupExists())
        self.groups.items[grpNo].locked = true
        self.solveForUnlockedPayments()
    }

    func solveForDecreasingTerm(grpNo: Int) {
        let minNumber = self.getMinTotalNumberPayments()
        var intNumber: Int = 0
        let startNoOfPayments = self.groups.items[grpNo].noOfPayments
        var newNoOfPayments = startNoOfPayments - intNumber
        
        while newNoOfPayments > minNumber {
            let decBalance: Decimal = getEndingBalance()
            
            if decBalance > 0.0 {
                break
            }
            intNumber += 1
            newNoOfPayments = startNoOfPayments - intNumber
            groups.items[grpNo].noOfPayments = newNoOfPayments
        }
        
        if newNoOfPayments == minNumber {
            groups.items[grpNo].noOfPayments = startNoOfPayments - 1
        }
    
        let strAmount = groups.items[grpNo].amount
        let grpStart = groups.items[grpNo].endDate
        let grpEnd = addOnePeriodToDate(dateStart: groups.items[grpNo].endDate, payperYear: paymentsPerYear, dateRefer: firstAnniversaryDate, bolEOMRule: endOfMonthRule)
        let aTiming = groups.items[grpNo].timing
        let aType = groups.items[grpNo].type
        let myGroup = Group(aAmount: strAmount, aEndDate: grpEnd, aLocked: false, aNoOfPayments: 1, aStartDate: grpStart, aTiming: aTiming, aType: aType, aUndeletable: false)
    
        groups.items.insert(myGroup, at: grpNo + 1)
        resetFirstGroup(isInterim: self.interimGroupExists())
        groups.items[grpNo].locked = true
        solveForUnlockedPayments()
    }
}
