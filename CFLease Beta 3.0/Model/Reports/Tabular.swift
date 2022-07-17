//
//  ColumnReports.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 1/6/22.
//

import Foundation


func textForOneAmortizations(aAmount: Decimal, aAmortizations: Amortizations, interestRate: String, dayCountMethod: DayCountMethod, currentFile: String, maxChars: Int) -> String {
    var arry = [String]()
    let emptyLine: String = "\n"
    let fiveColumns: [Int] = [4, 10, 9, 9, 10]
    
    let indentSmall: Int = 1
    
    let title = getFileNameAndDateLead(fileName: currentFile, maxCharsInLine: maxChars, spaces: 0)
    for x in 0..<title.count {
        arry.append(title[x])
    }

    let strInterestRate: String = interestRate.toDecimal().toPercent(3)
    let str_Line_InterestRate: String = justifyText(strA: "Interest Rate:", strB: strInterestRate, maxLength: maxChars)
    arry.append(str_Line_InterestRate)
    
    let strDayCount: String = dayCountMethod.toString()
    let str_Line_DayCount: String = justifyText(strA: "Day Count Method", strB: strDayCount, maxLength: maxChars)
    arry.append(str_Line_DayCount)
    
    let strBasis: String = aAmount.toCurrency(false)
    let str_Line_Basis: String = justifyText(strA: "As a % of", strB: strBasis, maxLength: maxChars)
    arry.append(str_Line_Basis)
    arry.append(emptyLine)

    var strNo: String = justifyColumn(cellData: buffer(spaces: indentSmall) + "No.", leftJustify: false, cellWidth: fiveColumns[0])
    var strDate: String = justifyColumn(cellData: "Date", leftJustify: false, cellWidth: fiveColumns[1])
    var strPayment: String = justifyColumn(cellData: "Payment", leftJustify: false, cellWidth: fiveColumns[2])
    var strInterest: String = justifyColumn(cellData: "Interest", leftJustify: false, cellWidth: fiveColumns[3])
    var strEndBalance: String = justifyColumn(cellData: "Balance", leftJustify: false, cellWidth: fiveColumns[4])
    let line_Header = strNo + strDate + strPayment + strInterest + strEndBalance
    arry.append(line_Header)

    let decAmount: Decimal = aAmount
    for x in 0..<aAmortizations.items.count {
        strNo = justifyColumn(cellData: buffer(spaces: indentSmall) + (x + 1).toString(), leftJustify: false, cellWidth: fiveColumns[0])
        strDate = justifyColumn(cellData: aAmortizations.items[x].dueDate.toStringDateShort(), leftJustify: false, cellWidth: fiveColumns[1])
        let decPayment: Decimal = aAmortizations.items[x].payment / decAmount * 100.0
        strPayment = justifyColumn(cellData: decPayment.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[2])
        let decInterest: Decimal = aAmortizations.items[x].interest / decAmount * 100.0
        strInterest = justifyColumn(cellData: decInterest.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[3])
        let decBalance: Decimal = aAmortizations.items[x].endBalance / decAmount * 100.0
        strEndBalance = justifyColumn(cellData: decBalance.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[4])
        let line_BodyRow = strNo + strDate + strPayment + strInterest  + strEndBalance
        arry.append(line_BodyRow)
    }
    arry.append(emptyLine)

    strNo = justifyColumn(cellData: buffer(spaces: indentSmall) + "", leftJustify: false, cellWidth: fiveColumns[0])
    strDate = justifyColumn(cellData: "Totals", leftJustify: false, cellWidth: fiveColumns[1])
    let decTotalPayments: Decimal = aAmortizations.getTotalPayments() / decAmount * 100.0
    let strTotalPayments: String = justifyColumn(cellData: decTotalPayments.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[2])
    let decTotalInterest: Decimal = aAmortizations.getTotalInterest() / decAmount * 100.0
    let strTotalInterest: String = justifyColumn(cellData: decTotalInterest.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[3])
//    let decBalance: Decimal = (decAmount - aAmortizations.getTotalPrincipal()) / decAmount * 100.0
//    strEndBalance = justifyColumn(cellData: decBalance.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[4])
    strEndBalance = justifyColumn(cellData: "", leftJustify: false, cellWidth: fiveColumns[4])
    
    let line_TotalsRow = strNo + strDate + strTotalPayments + strTotalInterest + strEndBalance
    arry.append(line_TotalsRow)

    var amortizationReport: String = ""
    for i in 0...arry.count - 1 {
        amortizationReport = amortizationReport + arry[i] + "\n"
    }
    return amortizationReport
}

func textForOneCashflow(aAmount: Decimal, aCFs: Cashflows,  currentFile: String, maxChars: Int) -> String {
    var arry = [String]()
    let myCFs: Cashflows = aCFs
    let indent = 0
    let emptyLine: String = "\n"
    let fourColumns: [Int] = [4, 10, 14, 14]
    
    let title = getFileNameAndDateLead(fileName: currentFile, maxCharsInLine: maxChars, spaces: 0)
    for x in 0..<title.count {
        arry.append(title[x])
    }
    let strBasis: String = aAmount.toCurrency(false)
    let str_Line_Basis: String = justifyText(strA: buffer(spaces: indent) + "As a % of", strB: strBasis, maxLength: maxChars)
    arry.append(str_Line_Basis)
    arry.append(emptyLine)

    let strNo: String = justifyColumn(cellData: buffer(spaces: indent) + "No.", leftJustify: false, cellWidth: fourColumns[0])
    var strDate: String = justifyColumn(cellData: "Date", leftJustify: false, cellWidth: fourColumns[1])
    var strAmount: String = justifyColumn(cellData: "Amount", leftJustify: false, cellWidth: fourColumns[2])
    var strRunTotal : String = justifyColumn(cellData: "Run Total", leftJustify: false, cellWidth: fourColumns[3])

    let line_Headers: String =  strNo + strDate + strAmount + strRunTotal
    arry.append(line_Headers)

    let decAmount: Decimal = aAmount
    var decRunTotal: Decimal = 0.0
    for x in 0..<myCFs.items.count {
        let strRow: String = justifyColumn(cellData: buffer(spaces: indent) + (x + 1).toString(), leftJustify: false, cellWidth: fourColumns[0])
        strDate = justifyColumn(cellData: myCFs.items[x].dueDate.toStringDateShort(), leftJustify: false, cellWidth: fourColumns[1])
        let decCF = myCFs.items[x].amount / decAmount * 100.0
        strAmount = justifyColumn(cellData: decCF.toString(decPlaces: 4), leftJustify: false, cellWidth: fourColumns[2])
        decRunTotal = decRunTotal + decCF
        strRunTotal = justifyColumn(cellData: decRunTotal.toString(decPlaces: 4), leftJustify: false, cellWidth: fourColumns[3])
        let rowData = strRow + strDate + strAmount + strRunTotal
        arry.append(rowData)
    }

    var myCashflowRpt: String = ""
    for i in 0...arry.count - 1 {
        myCashflowRpt = myCashflowRpt + arry[i] + "\n"
    }
    return myCashflowRpt
}

func textForDayCount(aLease: Lease, currentFile: String, maxChars: Int) -> String {
    var arry = [String]()
    let emptyLine: String = "\n"
    let indentSmall: Int = 1
    let fiveColumns: [Int] = [4, 10, 9, 9, 10]

    let title = getFileNameAndDateLead(fileName: currentFile, maxCharsInLine: maxChars, spaces: 0)
    for x in 0..<title.count {
        arry.append(title[x])
    }
    
    let strDayCount: String = aLease.interestCalcMethod.toString()
    let str_Line_DayCount: String = justifyText(strA: buffer(spaces: indentSmall) + "Day Count Method", strB: strDayCount, maxLength: maxChars)
    arry.append(str_Line_DayCount)
    
    let strEOM: String = aLease.endOfMonthRule.toString()
    let str_Line_EOMRule: String = justifyText(strA: buffer(spaces: indentSmall) + "End of Month Rule", strB: strEOM, maxLength: maxChars)
    arry.append(str_Line_EOMRule)
    arry.append(emptyLine)
    
    var strNo: String = justifyColumn(cellData: buffer(spaces: indentSmall) + "No.", leftJustify: false, cellWidth: fiveColumns[0])
    var strDate: String = justifyColumn(cellData: "Date", leftJustify: false, cellWidth: fiveColumns[1])
    var strActual: String = justifyColumn(cellData: "Actual", leftJustify: false, cellWidth: fiveColumns[2])
    var strCounted: String = justifyColumn(cellData: "Counted", leftJustify: false, cellWidth: fiveColumns[3])
    var strInYear: String = justifyColumn(cellData: "In Year", leftJustify: false, cellWidth: fiveColumns[4])
    var row_Data: String = strNo + strDate + strActual + strCounted + strInYear
    arry.append(row_Data)
    
    var runTotalActual: Int = 0
    var runTotalCounted: Int = 0
    let rentCFs: Cashflows = Cashflows(aLease: aLease, returnType: .payment)
    for x in 0..<rentCFs.items.count {
        strNo = justifyColumn(cellData: buffer(spaces: indentSmall) + (x + 1).toString(), leftJustify: false, cellWidth: fiveColumns[0])
        strDate = justifyColumn(cellData: rentCFs.items[x].dueDate.toStringDateShort(), leftJustify: false, cellWidth: fiveColumns[1])
        var actualDays: Int = 0
        var countedDays: Int = 0
        var yearDays: Double = 0.0
        if x > 0 {
            actualDays = daysBetween(start: rentCFs.items[x - 1].dueDate, end: rentCFs.items[x].dueDate)
            countedDays = dayCount(aDate1: rentCFs.items[x - 1].dueDate, aDate2: rentCFs.items[x].dueDate, aDaycount: aLease.interestCalcMethod)
            yearDays = daysInYear(aDate1: rentCFs.items[x - 1].dueDate, aDate2: rentCFs.items[x].dueDate, aDayCountMethod: aLease.interestCalcMethod)
        }
        strActual = justifyColumn(cellData: actualDays.toString(), leftJustify: false, cellWidth: fiveColumns[2])
        strCounted = justifyColumn(cellData: countedDays.toString(), leftJustify: false, cellWidth: fiveColumns[3])
        strInYear = justifyColumn(cellData: Decimal(yearDays).toString(decPlaces: 2), leftJustify: false, cellWidth: fiveColumns[4])
        runTotalActual = runTotalActual + actualDays
        runTotalCounted = runTotalCounted + countedDays
        row_Data = strNo + strDate + strActual + strCounted + strInYear
        arry.append(row_Data)
    }
    
    arry.append(emptyLine)
    strNo = justifyColumn(cellData: buffer(spaces: indentSmall) + "", leftJustify: false, cellWidth: fiveColumns[0])
    strDate = justifyColumn(cellData: "Totals", leftJustify: false, cellWidth: fiveColumns[1])
    strActual = justifyColumn(cellData: runTotalActual.withCommas(), leftJustify: false, cellWidth: fiveColumns[2])
    strCounted = justifyColumn(cellData: runTotalCounted.withCommas(), leftJustify: false, cellWidth: fiveColumns[3])
    strInYear = justifyColumn(cellData: "", leftJustify: false, cellWidth: fiveColumns[4])
    row_Data = strNo + strDate + strActual + strCounted + strInYear
    arry.append(row_Data)
    
    var dayCountReport: String = ""
    for i in 0...arry.count - 1 {
        dayCountReport = dayCountReport + arry[i] + emptyLine
    }
    return dayCountReport
}

func textForOneGroups (aGroups: [Group], columns: Int = 7, tblWidth: Int = 74) -> String {
    var arry = [String]()
    let myGroups: [Group] = aGroups

    var strRow: String = justifyColumn(cellData: "Row", leftJustify: false, cellWidth: 4)
    var strNo: String = justifyColumn(cellData: "Num", leftJustify: false, cellWidth: 4)
    var strType: String = justifyColumn(cellData: "Type", leftJustify: false, cellWidth: 10)
    var strFrom: String = justifyColumn(cellData: "From", leftJustify: false, cellWidth: 14)
    var strTo: String = justifyColumn(cellData: "To", leftJustify: false, cellWidth: 14)
    var strTiming: String = justifyColumn(cellData: "Timing", leftJustify: false, cellWidth: 14)
    var strAmount: String = justifyColumn(cellData: "Amount", leftJustify: false, cellWidth: 14)
    let line_Headers: String = strRow + strNo + strType + strFrom + strTo + strTiming + strAmount
    arry.append(line_Headers)

    for x in myGroups.indices {
        strRow = justifyColumn(cellData: (x + 1).toString(), leftJustify: false, cellWidth: 4)
        strNo = justifyColumn(cellData: myGroups[x].noOfPayments.toString(), leftJustify: false, cellWidth: 4)
        strType = justifyColumn(cellData: myGroups[x].type.toString(), leftJustify: false, cellWidth: 10)
        strFrom = justifyColumn(cellData: myGroups[x].startDate.toStringDateShort(), leftJustify: false, cellWidth: 14)
        strTo = justifyColumn(cellData: myGroups[x].endDate.toStringDateShort(), leftJustify: false, cellWidth: 14)
        strTiming = justifyColumn(cellData: myGroups[x].timing.toString(), leftJustify: false, cellWidth: 14)
        strAmount = justifyColumn(cellData: myGroups[x].amount.toDecimal().toCurrency(false), leftJustify: false, cellWidth: 14)
        let rowData: String = strRow + strNo + strType + strFrom + strTo + strTiming + strAmount
        arry.append(rowData)
    }

    var strReport: String = ""
    for i in 0...arry.count - 1 {
        strReport = strReport + arry[i] + "\n"
    }

    return strReport
}


func textForPVOfRentProof(aLease: Lease, currentFile: String, maxChars: Int) -> String {
    let lesseePaidFeesCF: Cashflow = Cashflow(due: aLease.fundingDate, amt: aLease.lesseePaidFee.toDecimal())
    let rentCFs: Cashflows = Cashflows(aLease: aLease, returnType: .payment)
    let residualCFS: Cashflows = Cashflows(aLease: aLease, returnType: .residual)
    residualCFS.items[residualCFS.items.count - 1].amount = aLease.leaseObligations!.residualGuarantyAmount.toDecimal()
    rentCFs.items.insert(lesseePaidFeesCF, at:  0)
    rentCFs.consolidateCashflows()
    let minRents: Cashflows = Cashflows().netTwoCashflows(cfsOne: rentCFs, cfsTwo: residualCFS)
   
    var arry = [String]()
    let emptyLine: String = "\n"
    let indentSmall: Int = 1
    let fiveColumns: [Int] = [4, 10, 9, 9, 10]
    
    let title = getFileNameAndDateLead(fileName: currentFile, maxCharsInLine: maxChars, spaces: 0)
    for x in 0..<title.count {
        arry.append(title[x])
    }
    
    let strBasis: String = aLease.amount.toDecimal().toCurrency(false)
    let str_Line_Basis: String = justifyText(strA: "As a % of", strB: strBasis, maxLength: maxChars)
    arry.append(str_Line_Basis)
    
    let discountRate: String = aLease.leaseObligations!.discountRate
    let line_DiscountRate = justifyText(strA: "Discount Rate", strB: discountRate.toDecimal().toPercent(2), maxLength: maxChars)
    arry.append(line_DiscountRate)
    arry.append(emptyLine)
    
    var strNo: String = justifyColumn(cellData: buffer(spaces: indentSmall) + "No.", leftJustify: false, cellWidth: fiveColumns[0])
    var strDate: String = justifyColumn(cellData: "Date", leftJustify: false, cellWidth: fiveColumns[1])
    var strMinRents: String = justifyColumn(cellData: "MinRent", leftJustify: false, cellWidth: fiveColumns[2])
    var strPVOf1: String = justifyColumn(cellData: "PVFactor", leftJustify: false, cellWidth: fiveColumns[3])
    var strPVMinRents: String = justifyColumn(cellData: "RentPV", leftJustify: false, cellWidth: fiveColumns[4])
    var line_Data = strNo + strDate + strMinRents + strPVOf1 + strPVMinRents
    arry.append(line_Data)

    let decAmount: Decimal = aLease.amount.toDecimal()
    var prevFactor: Decimal = 1.0
    var dailyInterestRate: Decimal = 0.0
    var daysInPeriod: Int = 0
    var runTotalMinRents: Decimal = 0.0
    var runTotalPV: Decimal = 0.0
    for x in 0..<minRents.items.count {
        strNo = justifyColumn(cellData: buffer(spaces: indentSmall) + (x + 1).toString(), leftJustify: false, cellWidth: fiveColumns[0])
        strDate = justifyColumn(cellData: minRents.items[x].dueDate.toStringDateShort(), leftJustify: false, cellWidth: fiveColumns[1])
        let decMinRents: Decimal = minRents.items[x].amount / decAmount * 100.0
        runTotalMinRents = runTotalMinRents + decMinRents
        strMinRents = justifyColumn(cellData: decMinRents.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[2])
        if x > 0 {
            dailyInterestRate = dailyRate(iRate: aLease.leaseObligations!.discountRate.toDecimal(), aDate1: minRents.items[x - 1].dueDate, aDate2: minRents.items[x].dueDate, aDayCountMethod: aLease.interestCalcMethod)
            daysInPeriod = dayCount(aDate1: minRents.items[x - 1].dueDate, aDate2: minRents.items[x].dueDate, aDaycount: aLease.interestCalcMethod)
        }
        let currFactor: Decimal = prevFactor / (1 + dailyInterestRate * Decimal(daysInPeriod))
        strPVOf1 = justifyColumn(cellData: currFactor.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[3])
        let adjMinRents: Decimal = decMinRents * currFactor
        runTotalPV = runTotalPV + adjMinRents
        strPVMinRents = justifyColumn(cellData: adjMinRents.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[4])
        prevFactor = currFactor
        line_Data = strNo + strDate + strMinRents + strPVOf1 + strPVMinRents
        arry.append(line_Data)
    }
    arry.append(emptyLine)
    strNo = justifyColumn(cellData: buffer(spaces: indentSmall) + "", leftJustify: false, cellWidth: fiveColumns[0])
    strDate = justifyColumn(cellData: "Totals", leftJustify: false, cellWidth: fiveColumns[1])
    strMinRents = justifyColumn(cellData: runTotalMinRents.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[2])
    strPVOf1 = justifyColumn(cellData: "", leftJustify: false, cellWidth: fiveColumns[3])
    strPVMinRents = justifyColumn(cellData: runTotalPV.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[4])
    line_Data =  strNo + strDate + strMinRents + strPVOf1 + strPVMinRents
    arry.append(line_Data)
    
    var pvProofReport: String = ""
    for i in 0..<arry.count {
        pvProofReport = pvProofReport + arry[i] + emptyLine
    }
    arry.removeAll()
    
    return pvProofReport
}


func textForTerminationValues (aLease: Lease, inLieuRent: Bool, includeParValues: Bool, currentFile: String, maxChars: Int) -> String {
    let rentDR = aLease.terminations?.discountRate_Rent ?? aLease.interestRate.toDecimal()
    let residualDR = aLease.terminations?.discountRate_Residual ?? aLease.interestRate.toDecimal()
    let additional = aLease.terminations?.additionalResidual ?? 0.00
    
    let myTValues:Cashflows = aLease.terminationValues(rateForRent: rentDR, rateForResidual: residualDR, adder: additional, inLieuOfRent: inLieuRent)
    let myParValues = aLease.parValues()
    
    var arry = [String]()
    let emptyLine: String = "\n"
    let indentSmall: Int = 1
    let fiveColumns: [Int] = [4, 10, 9, 9, 10]
    
    let title = getFileNameAndDateLead(fileName: currentFile, maxCharsInLine: maxChars, spaces: 0)
    for x in 0..<title.count {
        arry.append(title[x])
    }
    let strBasis: String = aLease.amount.toDecimal().toCurrency(false)
    let str_Line_Basis: String = justifyText(strA: "As a % of", strB: strBasis, maxLength: maxChars)
    arry.append(str_Line_Basis)
    arry.append(emptyLine)
    
    var strNo: String = justifyColumn(cellData: buffer(spaces: indentSmall) + "No.", leftJustify: false, cellWidth: fiveColumns[0])
    var strDate: String = justifyColumn(cellData: "Date", leftJustify: false, cellWidth: fiveColumns[1])
    var strTValue: String = justifyColumn(cellData: "TValue", leftJustify: false, cellWidth: fiveColumns[2])
    var parValueLead = "PValue"
    var coverageLead = "Delta"
    if includeParValues == false {
        parValueLead = ""
        coverageLead = ""
    }
    var strParValue: String = justifyColumn(cellData: parValueLead, leftJustify: false, cellWidth: fiveColumns[3])
    var strCoverage: String = justifyColumn(cellData: coverageLead, leftJustify: false, cellWidth: fiveColumns[4])
    let line_Header = strNo + strDate + strTValue + strParValue + strCoverage
    arry.append(line_Header)

    for x in 0..<myTValues.items.count {
        strNo = justifyColumn(cellData: buffer(spaces: indentSmall) + (x + 1).toString(), leftJustify: false, cellWidth: fiveColumns[0])
        strDate = justifyColumn(cellData: myTValues.items[x].dueDate.toStringDateShort(), leftJustify: false, cellWidth: fiveColumns[1])
        let decTValue = myTValues.items[x].amount * 100.0
        strTValue = justifyColumn(cellData: decTValue.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[2])
        let decParValue = myParValues.items[x].amount * 100.0
        strParValue = justifyColumn(cellData: decParValue.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[3])
        let decCoverage = decTValue - decParValue
        strCoverage = justifyColumn(cellData: decCoverage.toString(decPlaces: 4), leftJustify: false, cellWidth: fiveColumns[4])
        if includeParValues == false {
            strParValue = ""
            strCoverage = ""
        }
        let line_BodyRow = strNo + strDate + strTValue + strParValue  + strCoverage
        arry.append(line_BodyRow)
    }
    arry.append(emptyLine)

    var terminationValuesReport: String = ""
    for i in 0..<arry.count {
        terminationValuesReport = terminationValuesReport + arry[i] + "\n"
    }
    arry.removeAll()
    
    return terminationValuesReport
}

func textForAverageLife(aLease: Lease, currentFile: String, maxChars: Int) -> String {
    let avgLives: AverageLives = AverageLives(aLease: aLease)
   
    var arry = [String]()
    let emptyLine: String = "\n"
    let sixColumns: [Int] = [3, 9, 6, 7, 9, 8]
    
    let title = getFileNameAndDateLead(fileName: currentFile, maxCharsInLine: maxChars, spaces: 0)
    for x in 0..<title.count {
        arry.append(title[x])
    }
    let strBasis: String = aLease.amount.toDecimal().toCurrency(false)
    let str_Line_Basis: String = justifyText(strA: "As a % of", strB: strBasis, maxLength: maxChars)
    arry.append(str_Line_Basis)
    arry.append(emptyLine)
    
    var strNo: String = justifyColumn(cellData: "", leftJustify: false, cellWidth: sixColumns[0])
    var strDate: String = justifyColumn(cellData: "Due", leftJustify: false, cellWidth: sixColumns[1])
    var strCumDays: String = justifyColumn(cellData: "Cum", leftJustify: false, cellWidth: sixColumns[2])
    var strCumYears: String = justifyColumn(cellData: "Cum", leftJustify: false, cellWidth: sixColumns[3])
    var strPrincPaid: String = justifyColumn(cellData: "Princ", leftJustify: false, cellWidth: sixColumns[4])
    var strPrincOut: String = justifyColumn(cellData: "Princ", leftJustify: false, cellWidth: sixColumns[5])
    var line_Data = strNo + strDate + strCumDays + strCumYears + strPrincPaid + strPrincOut
    arry.append(line_Data)
    
    strNo = justifyColumn(cellData: "No.", leftJustify: true, cellWidth: sixColumns[0])
    strDate = justifyColumn(cellData: "Date", leftJustify: false, cellWidth: sixColumns[1])
    strCumDays = justifyColumn(cellData: "Days", leftJustify: false, cellWidth: sixColumns[2])
    strCumYears = justifyColumn(cellData: "Years", leftJustify: false, cellWidth: sixColumns[3])
    strPrincPaid = justifyColumn(cellData: "Repaid", leftJustify: false, cellWidth: sixColumns[4])
    strPrincOut = justifyColumn(cellData: "Out Yrs", leftJustify: false, cellWidth: sixColumns[5])
    line_Data = strNo + strDate + strCumDays + strCumYears + strPrincPaid + strPrincOut
    arry.append(line_Data)
    
    for x in 0..<avgLives.items.count {
        strNo = justifyColumn(cellData: (x + 1).toString(), leftJustify: false, cellWidth: sixColumns[0])
        strDate = justifyColumn(cellData: avgLives.items[x].dueDate.toStringDateShort(), leftJustify: false, cellWidth: sixColumns[1])
        strCumDays = justifyColumn(cellData: avgLives.items[x].cumulativeDays.toString(), leftJustify: false, cellWidth: sixColumns[2])
        strCumYears = justifyColumn(cellData: avgLives.items[x].yearsOutstanding.toString(decPlaces: 3), leftJustify: false, cellWidth: sixColumns[3])
        strPrincPaid = justifyColumn(cellData: avgLives.items[x].principalPaid.toPercent(4), leftJustify: false, cellWidth: sixColumns[4])
        strPrincOut = justifyColumn(cellData: avgLives.items[x].principalOutstanding.toString(decPlaces: 3), leftJustify: false, cellWidth: sixColumns[5])
        line_Data = strNo + strDate + strCumDays + strCumYears + strPrincPaid + strPrincOut
        arry.append(line_Data)
    }
    arry.append(emptyLine)
    strNo = justifyColumn(cellData: "", leftJustify: false, cellWidth: sixColumns[0])
    strDate = justifyColumn(cellData: "Totals", leftJustify: false, cellWidth: sixColumns[1])
    strCumDays = justifyColumn(cellData: "", leftJustify: false, cellWidth: sixColumns[2])
    strCumYears = justifyColumn(cellData: "", leftJustify: false, cellWidth: sixColumns[3])
    strPrincPaid = justifyColumn(cellData: avgLives.getTotalPrincipalPaid().toPercent(2), leftJustify: false, cellWidth: sixColumns[4])
    strPrincOut = justifyColumn(cellData: avgLives.getWeightedAverageLife().toString(decPlaces: 3), leftJustify: false, cellWidth: sixColumns[5])
    line_Data = strNo + strDate + strCumDays + strCumYears + strPrincPaid + strPrincOut
    arry.append(line_Data)
    
    var averageLifeReport: String = ""
    for x in 0..<arry.count {
        averageLifeReport = averageLifeReport + arry[x] + "\n"
    }
    arry.removeAll()
            
    return averageLifeReport
}
    
