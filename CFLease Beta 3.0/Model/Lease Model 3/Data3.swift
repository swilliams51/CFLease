//
//  Data3.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/2/21.
//

import Foundation


extension Lease {
    
    func readLeaseFromString(strFile: String) {
        let arryLease: [String] = strFile.components(separatedBy: str_split_Properties_Groups_Classes)
        let leaseData: [String] = arryLease[0].components(separatedBy: ",")
        let groupsData: [String] = arryLease[1].components(separatedBy: str_Split_Groups)
        
        amount = leaseData[0]
        baseTermCommenceDate = leaseData[1].toDate()
        baseTerm = leaseData[2].toInteger()
        childOf = leaseData[3].toInteger()
        endOfMonthRule = leaseData[4].toBool()
        firstAnniversaryDate = leaseData[5].toDate()
        fundingDate = leaseData[6].toDate()
        interestCalcMethod = leaseData[7].toDayCountMethod()
        interestRate = leaseData[8]
        lesseePaidFee = leaseData[9]
        paymentsPerYear = leaseData[10].toFrequency()
        purchaseFee = leaseData[11]
        groups.items.removeAll()
        
        for i in 0..<groupsData.count{
            let myGroup = readGroup(strGroup: groupsData[i])
            groups.items.append(myGroup)
        }
        
        let classData = arryLease[2].components(separatedBy: str_split_Classes)
        
        let obligationsData = classData[0].components(separatedBy: ",")
        let strDiscountRate = obligationsData[0]
        let strResidGty = obligationsData[1]
        leaseObligations = Obligations(aDiscountRate: strDiscountRate, aResidualGuarantyAmount: strResidGty)
       
        let earlybuyoutData = classData[1].components(separatedBy: ",")
        let dateExercise = earlybuyoutData[0].toDate()
        let strAmount = earlybuyoutData[1]
        let rentDueIsPaid = earlybuyoutData[2].toBool()
        
        earlyBuyOut = EarlyPurchaseOption(aExerciseDate: dateExercise, aAmount: strAmount, rentDue: rentDueIsPaid)
      
        let terminationsData = classData[2].components(separatedBy: ",")
        let decDiscountRateForRent: Decimal = terminationsData[0].toDecimal()
        let decDiscounRateForResidual: Decimal = terminationsData[1].toDecimal()
        let decAdditionalResidual: Decimal = terminationsData[2].toDecimal()
        terminations = Terminations(discountRate_Rent: decDiscountRateForRent, discountRate_Residual: decDiscounRateForResidual, additionalResidual: decAdditionalResidual)
    
        
    }
    
}

