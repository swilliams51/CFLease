//
//  LeaseMainView.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/22/21.
//

import SwiftUI

struct LeaseMainView: View {
    @ObservedObject var myLease: Lease
    @Binding var endingBalance: String
    @Binding var currentFile: String
    
    @Binding var fileExported: Bool
    @Binding var exportSuccessful: Bool
    @Binding var fileImported: Bool
    @Binding var importSuccessful: Bool

    @Binding var selfIsNew: Bool
    @Binding var editAmountStarted: Bool
    @Binding var editRateStarted: Bool
    @Binding var menuIsActive: Bool
    @Binding var isPad: Bool
    @Binding var isDark: Bool
    
    @AppStorage("maxBaseTerm") var maxBaseTerm = 120
    @AppStorage("savedDefault") var savedDefaultLease: String = "No_Data"
    @AppStorage("useSaved") var useSavedAsDefault: Bool = false
    
    @State var amountOnEntry: String = "0.00"
    @State var interestRateOnEntry: String = "0.05"
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
    
    @State private var oldBaseTerm: Int = 0
    @State var showPopover: Bool = false
    @State var showPopover2: Bool = false
    @State var showPopover3: Bool = false
    @State var stepperHelp: Help = baseTermStepperHelp
    @State var baseHelp: Help = baseTermHelp
    @State var termHelp: Help = solveForTermHelp
    
    @FocusState private var amountIsFocused: Bool
    @FocusState private var rateIsFocused: Bool
    
    var body: some View {
            VStack {
                    Form {
                        Section (header: Text("Inputs").font(.footnote), footer: getCalculationsText()) {
                                leaseAmountItem
                                fundingDateItem
                                baseCommencementDateItem
                                interestRateItem
                                paymentFrequencyItem
                                baseTermMonthsItem
                                paymentsScheduleItem
                            }
                            
                            if balanceIsZero() != true {
                                Section (header: Text("Solve For Options")) {
                                    solveForAmountAndRateRow
                                    solveForPaymentsAndTermRow
                                }
                            
                            } else {
                                Section (header: Text("Results").font(.footnote), footer: Text("file name: \(currentFile)")) {
                                        endingBalanceRow
                                    }
                            }
                        }
                        .navigationTitle("Lease Parameters")
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationViewStyle(.stack)
                        .navigationBarItems(trailing: (
                            Button(action: {
                                self.selfIsNew.toggle()
                            }) {
                                if self.selfIsNew {
                                    Image(systemName: "lock")
                                        .imageScale(.medium)
                                } else {
                                    Image(systemName: "lock.open")
                                        .imageScale(.medium)
                                }
                            }
                        ))
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Button("Cancel") {
                                    updateForCancel()
                                }
                                Spacer()
                                Button("Enter") {
                                    updateForSubmit()
                                }
                            }
                        }
                }
            .environment(\.colorScheme, isDark ? .dark : .light)
            .alert(isPresented: $showAlert, content: getAlert)
            .popover(isPresented: $showPopover2) {
                PopoverView(myHelp: $baseHelp, isDark: $isDark)
            }
            .onAppear {
                self.amountOnEntry = self.myLease.amount
                self.interestRateOnEntry = self.myLease.interestRate
                self.oldBaseTerm = self.myLease.getBaseTermInMons()
                
                if self.fileExported == true {
                    if self.exportSuccessful == true {
                        self.alertTitle = alertExportSuccess
                    } else {
                        self.alertTitle = alertExportFailure
                    }
                    self.showAlert.toggle()
                    self.fileExported = false
                    self.exportSuccessful = false
                }
                
                if self.fileImported == true {
                    if self.importSuccessful == true {
                        self.alertTitle = alertImportSuccess
                    } else {
                        self.alertTitle = alertImportFailure
                    }
                    self.showAlert.toggle()
                    self.fileImported = false
                    self.importSuccessful = false
                }
                
        }
    }
    
   
    
    var leaseAmountItem: some View {
        HStack{
            Text(selfIsNew ? "amount:" : "amount: \(Image(systemName: "return"))")
                .font(.subheadline)
            Spacer()
            ZStack(alignment: .trailing) {
                TextField("",
                          text: $myLease.amount,
                          onEditingChanged: { (editing) in
                    if editing == true {
                        self.editAmountStarted = true
                    }})
                    .disabled(selfIsNew ? true : false)
                    .keyboardType(.decimalPad).foregroundColor(.clear)
                    .focused($amountIsFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                    .accentColor(.clear)
                Text("\(amountFormatted(editStarted: editAmountStarted))")
                    .font(.subheadline)
            }
        }
    }
    
    var fundingDateItem: some View {
            HStack {
                Text("funding:")
                    .font(.subheadline)
                Spacer()
                DatePicker("", selection: $myLease.fundingDate, displayedComponents: [.date])
                    .id(myLease.fundingDate)
                    .transformEffect(.init(scaleX: 1.0, y: 0.9))
                    .onChange(of: myLease.fundingDate, perform: { value in
                        if self.selfIsNew == false {
                            self.myLease.resetForFundingDateChange()
                            self.endingBalance = myLease.getEndingBalance().toCurrency(false)
                            self.myLease.resetLease()
                            setMenu()
                        }
                    })
                    .disabled(selfIsNew ? true : false )
                    .font(.subheadline)
            }
    }
    
    var baseCommencementDateItem: some View {
        HStack{
            Text("base start:")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover2.toggle()
                }
            Spacer()
            DatePicker("", selection: $myLease.baseTermCommenceDate, in: rangeBaseTermDates, displayedComponents:[.date])
                .id(myLease.baseTermCommenceDate)
                .transformEffect(.init(scaleX: 1.0, y: 0.9))
                .onChange(of: myLease.baseTermCommenceDate, perform: { value in
                    if self.selfIsNew == false {
                        self.myLease.resetForBaseTermCommenceDateChange()
                        self.endingBalance = myLease.getEndingBalance().toCurrency(false)
                        self.myLease.resetLease()
                        setMenu()
                    }
                })
                .disabled(selfIsNew ? true : false)
        }
    }
    
    var interestRateItem: some View {
        HStack{
            Text(selfIsNew ? "interest rate:" : "interest rate: \(Image(systemName: "return"))")
                .font(.subheadline)
            Spacer()
            ZStack(alignment: .trailing) {
                TextField("",
                          text: $myLease.interestRate,
                          onEditingChanged: { (editing) in
                    if editing == true {
                        self.editRateStarted = true
                }})
                    .disabled(selfIsNew ? true : false)
                    .keyboardType(.decimalPad).foregroundColor(.clear)
                    .focused($rateIsFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                    .accentColor(.clear)
                Text("\((rateFormatted(editStarted: editRateStarted)))")
                    .font(.subheadline)
            }
        }
    }
    
    var paymentFrequencyItem: some View {
            HStack {
                Text("frequency:")
                    .font(.subheadline)
                Spacer()
                Picker(selection: $myLease.paymentsPerYear, label: Text("")) {
                    ForEach(getFrequencies(), id: \.self) { frequency in
                        Text(frequency.toString())
                            .font(.subheadline)
                    }
                    .onChange (of: myLease.paymentsPerYear) { value in
                        if self.selfIsNew == false {
                            self.myLease.resetForFrequencyChange()
                            self.oldBaseTerm = self.myLease.baseTerm
                            self.endingBalance = myLease.getEndingBalance().toCurrency(false)
                            setMenu()
                        }
                    }
                }
                .disabled(selfIsNew ? true : false)
            }
    }
    
    var baseTermMonthsItem: some View {
            HStack {
                if isPad == true {
                    baseTermStackTextItem
                } else {
                    baseTermTextItem
                }
                Image(systemName: "questionmark.circle")
                    .foregroundColor(Color.theme.accent)
                    .onTapGesture {
                        self.showPopover.toggle()
                    }
                
                if isPad == true {
                    baseTermResultsStackItem
                } else {
                    baseTermResultsTextItem
                }
                
                Stepper("", value: $myLease.baseTerm, in: rangeBaseTermMonths, step: stepValue,
                        onEditingChanged: { didChange in

                })
                .transformEffect(.init(scaleX: 1.0, y: 0.9))
                .disabled(stepperIsDisabled() ? true : false )
           }
        .alert(isPresented: $showAlert, content: getAlert)
        .popover(isPresented: $showPopover) {
            PopoverView(myHelp: $stepperHelp, isDark: $isDark)
        }
    }
    
    func stepperIsDisabled() -> Bool {
        var isDisabled: Bool = false
        
        if self.selfIsNew == true || self.myLease.groups.noOfGroupsWithMoreThanOnePayment() > 1 {
            isDisabled = true
        }
        
        return isDisabled
    }
    
    var baseTermStackTextItem:some View {
            VStack{
                Text("base")
                    .font(.subheadline)
                Text("term:")
                    .font(.subheadline)
            }
    }
    
    var baseTermTextItem: some View {
        Text("base term:")
            .font(.subheadline)
    }
    
    var baseTermResultsStackItem: some View {
        VStack{
            Text("\(myLease.baseTerm)")
                .font(.subheadline)
                .onChange(of: myLease.baseTerm, perform: { value in
                   setNewBaseTerm(newTerm: value)
            })
            
            Text("mons")
                .font(.subheadline)
        }
    }
    
    var baseTermResultsTextItem: some View {
        Text(" \(myLease.baseTerm) mons")
            .font(.subheadline)
            .onChange(of: myLease.baseTerm, perform: { value in
                setNewBaseTerm(newTerm: value)
        })
        
    }
    
    func setNewBaseTerm (newTerm: Int) {
        if self.selfIsNew == false {
            if self.myLease.getBaseTermInMons() != newTerm {
                let idx: Int = self.myLease.groups.indexOfGroupWithMoreThanOnePayment()
                if idx != -1 {
                    let changeBaseTerm = newTerm - self.oldBaseTerm
                    var step: Int = 1
                    if changeBaseTerm < 0 {
                        step = -1
                    }
                    self.myLease.groups.items[idx].noOfPayments = self.myLease.groups.items[idx].noOfPayments + step
                    self.myLease.resetFirstGroup(isInterim: self.myLease.interimGroupExists())
                    self.endingBalance = myLease.getEndingBalance().toCurrency(false)
                    setMenu()
                    self.oldBaseTerm = self.myLease.baseTerm
                }
            }
        } else {
            self.myLease.baseTerm = myLease.getBaseTermInMons()
        }
    }
    
    var paymentsScheduleItem: some View {
        NavigationLink(
            destination: GroupsView(myGroups: $myLease.groups, myLease: myLease, endingBalance: $endingBalance, selfIsNew: $selfIsNew, menuIsActive: $menuIsActive, isDark: $isDark),
            label: {
                Text("payments schedule:")
                    .font(.subheadline)
            })
    }
    
    var endingBalanceRow: some View {
        HStack {
            Text("ending balance:")
                .font(.subheadline)
            ZStack (alignment: .trailing){
                TextField("", text: $endingBalance)
                    .font(.subheadline)
                    .foregroundColor(.clear)
                    .multilineTextAlignment(.trailing)
                    .onChange(of: endingBalance) { newValue in
                        if abs(newValue.toDecimal()) < 0.0075 {
                            self.menuIsActive = true
                        } else {
                            self.menuIsActive = false
                        }
                }
                Text("\(endingBalance.toDecimal().toCurrency(false))")
                    .font(.subheadline)
            }
        }
    }
    
    var solveForAmountAndRateRow: some View {
        HStack {
            solveForAmountButton
            Spacer()
            solveForInterestRateButton
        }
    }
    
    var solveForPaymentsAndTermRow: some View {
        HStack {
            solveForPaymentsButton
            Spacer()
            solveForTermButton
        }
        .popover(isPresented: $showPopover3) {
            PopoverView(myHelp: $termHelp, isDark: $isDark)
        }
    }
    
    var solveForAmountButton: some View {
        Button(action: {}) {
            Text("lease amount")
                .font(.subheadline)
        }
        .onTapGesture {
            self.myLease.solveForPrincipal()
            if self.myLease.amount.toDecimal() > maximumLeaseAmount.toDecimal() {
                self.alertTitle = alertMaxAmount
                self.showAlert.toggle()
                self.myLease.resetLeaseToDefault(useSaved: useSavedAsDefault, currSaved: savedDefaultLease)
                self.myLease.solveForRate()
                self.selfIsNew = true
            }
            self.endingBalance = myLease.getEndingBalance().toCurrency(false)
            self.myLease.resetLease()
            self.setMenu()
        }
    }
    
    var solveForInterestRateButton: some View {
        Button(action: {}) {
            Text("interest rate")
                .font(.subheadline)
        }
        .disabled(solveForRateIsValid() ? false : true)
        .onTapGesture {
            self.myLease.solveForRate()
            self.endingBalance = myLease.getEndingBalance().toCurrency(false)
            self.myLease.resetLease()
            self.setMenu()
        }
    }
    
    var solveForPaymentsButton: some View {
        Button(action: {}) {
            Text("unlocked payments")
                .font(.subheadline)
        }
        .disabled(solveForPaymentsIsValid() ? false : true)
        .onTapGesture {
            self.myLease.solveForUnlockedPayments()
            self.endingBalance = self.myLease.getEndingBalance().toCurrency(false)
            self.myLease.resetLease()
            self.setMenu()
        }
    }
    
    var solveForTermButton: some View {
        HStack {
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover3.toggle()
                }
            Button(action: {}) {
                Text("term")
                    .font(.subheadline)
            }
            .disabled(solveForTermIsValid() ? false : true)
            .onTapGesture {
                self.myLease.solveForTerm(maxBase: maxBaseTerm)
                self.endingBalance = self.myLease.getEndingBalance().toCurrency(false)
                self.myLease.resetLease()
                self.setMenu()
        }
        }
    }
    
    var stepValue: Int {
        switch self.myLease.paymentsPerYear {
        case .monthly:
            return 1
        case .quarterly:
            return 3
        case .semiannual:
            return 6
        default:
            return 12
        }
    }
    
    func amountFormatted (editStarted: Bool) -> String {
        if editStarted == true {
            return myLease.amount
        } else {
            return myLease.amount.toDecimal().toCurrency(false)
        }
    }
    
    func balanceIsZero() -> Bool {
        var isZero: Bool = false
        
        let balance: Decimal = endingBalance.toDecimal()
        if abs(balance) < 0.075 {
            isZero = true
        }
        return isZero
    }
    
    func getAlert() -> Alert{
        return Alert(title: Text(alertTitle))
    }
    
    func getCalculationsText() -> Text {
        let strLead = Text("Calculations")
        let strSpacer = Text(": ")
        var strFee = Text(Image(systemName:"dollarsign.square"))
        var strPurchase = Text(Image(systemName: "cart"))
        var strPVRents = Text(Image(systemName: "sum"))
        var strEBO = Text(Image(systemName: "option"))
        var strTV = Text(Image(systemName: "tablecells"))
        var strBalance = Text(Image(systemName: "hourglass"))
        
        if myLease.lesseePaidFee.toDecimal() == 0.0 {
            strFee = Text("")
        }
        if myLease.purchaseFee.toDecimal() == 0.0 {
            strPurchase = Text("")
        }
        if myLease.isTrueLease() == false {
            strPVRents = Text("")
        }
        if myLease.eboExists() == false {
            strEBO = Text("")
        }
        
        if myLease.terminationsExist() == false {
            strTV = Text("")
        }
        
        if modificationDate == "01/01/1900" {
            strBalance = Text("")
        }
        
        return strLead + strSpacer + strFee + strPurchase + strPVRents + strEBO + strTV + strBalance
    }
    
    func getFrequencies( ) -> [Frequency] {
        let freqValue1: Int = 1
        var freqValue2: Int = 0
        var freqValue3: Int = 0
        var freqValue4: Int = 0

        if isFrequencyValid(divisor: 12) == true {
            freqValue4 = 4
        }
        if isFrequencyValid(divisor: 6) == true {
            freqValue3 = 3
        }
        if isFrequencyValid(divisor: 3) == true {
            freqValue2 = 2
        }
        let highestValue = max(freqValue4, freqValue3, freqValue2, freqValue1)

        switch highestValue {
        case 4:
            return Frequency.allCases
        case 3:
            return Frequency.three
        case 2:
            return Frequency.two
        default:
            return Frequency.one
        }
    }
    
    func getMaxTotalInterest() -> Decimal {
        let estimateAvgLife:Decimal = self.myLease.getAverageLifeEstimate(aLease: self.myLease)
        let maxInterest: Decimal = self.myLease.amount.toDecimal() * 0.30 * estimateAvgLife
        
        return maxInterest
    }
  
    func isFrequencyValid(divisor: Int) -> Bool {
        var bolIsValid: Bool = true
        
        for x in 0..<self.myLease.groups.items.count {
            if myLease.groups.items[x].noOfPayments > 1 {
                let sDate:Date = self.myLease.groups.items[x].startDate
                let eDate: Date = self.myLease.groups.items[x].endDate
                let number: Int = monthsBetween(start: sDate, end: eDate)
                if number % divisor != 0 {
                    bolIsValid = false
                    return bolIsValid
                }
            }
        }

        return bolIsValid
    }
    
    func minLeaseAmount() -> Decimal {
        var decMinimum: Decimal = minimumLeaseAmount.toDecimal()
        
        for x in 0..<myLease.groups.items.count {
            if myLease.groups.items[x].locked == true {
                decMinimum = decMinimum + myLease.groups.items[x].amount.toDecimal()
            }
        }
        return decMinimum
    }

    var rangeBaseTermDates: ClosedRange<Date> {
        let starting: Date = myLease.fundingDate
        var maxInterim: Int
        
        switch myLease.paymentsPerYear {
        case .quarterly:
            maxInterim = 89
        case .semiannual:
            maxInterim = 179
        case .annual:
            maxInterim = 364
        default:
            maxInterim = 89
        }
        
        let ending: Date = Calendar.current.date(byAdding: .day, value: maxInterim, to: starting)!
        
        return starting...ending
    }
    
    var rangeBaseTermMonths: ClosedRange<Int> {
        let starting: Int = 24
        let ending: Int = maxBaseTerm
        return starting...ending
    }
    
    func rateFormatted (editStarted: Bool) -> String {
        if editStarted == true {
            return myLease.interestRate.toTruncDecimalString(decPlaces: 7)
        } else {
            return myLease.interestRate.toDecimal().toPercent(3)
        }
    }
    
    func setMenu() {
        if balanceIsZero(){
            self.menuIsActive = true
        } else {
            self.menuIsActive = false
        }
    }
    
    func solveForPaymentsIsValid() -> Bool {
        var solveFor: Bool = true
        
        if myLease.groups.allGroupsAreLocked() == true {
            solveFor = false
        }
        
        return solveFor
    }
    
    func solveForRateIsValid() -> Bool {
        if self.myLease.groups.hasPrincipalPayments() {
            return false
        }
        
        let maxAmount:Decimal = getMaxTotalInterest()
        
        if self.myLease.getNetAmount() < 0.00 || self.myLease.getNetAmount() > maxAmount {
            return false
        }

        return true
    }
    
    func solveForTermIsValid() -> Bool {
        if myLease.isSolveForTermValid(maxBase: maxBaseTerm) == true {
            return true
        } else {
            return false
        }
    }
    
    func updateForCancel() {
        if self.editAmountStarted == true {
            self.editAmountStarted = false
            self.myLease.amount = self.amountOnEntry
        }
        if self.editRateStarted == true {
            self.editRateStarted = false
            self.myLease.interestRate = self.interestRateOnEntry
        }
        self.endingBalance = self.myLease.getEndingBalance().toCurrency(false)
        self.myLease.resetTerminations()
        self.setMenu()
        self.amountIsFocused = false
        self.rateIsFocused = false
    }
    
    func updateForSubmit() {
        if self.editAmountStarted == true {
            self.editAmountStarted = false
            if isAmountValid(strAmount: myLease.amount, decLow: minLeaseAmount(), decHigh: maximumLeaseAmount.toDecimal(), inclusiveLow: false, inclusiveHigh: true) == false {
                self.myLease.amount = self.amountOnEntry
                self.alertTitle = "A valid amount must be a decimal greater than \(minLeaseAmount().toString(decPlaces: 2)) and less than \(maximumLeaseAmount.toDecimal().toString(decPlaces: 2))!!!"
                self.showAlert.toggle()
            } else {
                self.endingBalance = self.myLease.getEndingBalance().toCurrency(false)
                self.myLease.resetTerminations()
                setMenu()
            }
        }
        if self.editRateStarted == true {
            self.editRateStarted = false
            if isInterestRateValid(strRate: myLease.interestRate, decLow: 0.0, decHigh: maximumInterestRate.toDecimal(), inclusiveLow: false, inclusiveHigh: true) == false {
                self.alertTitle = alertInterestRate
                self.showAlert.toggle()
                myLease.interestRate = self.interestRateOnEntry
            } else {
                self.endingBalance = self.myLease.getEndingBalance().toCurrency(false)
                self.myLease.resetTerminations()
                self.setMenu()
            }
        }
        self.amountIsFocused = false
        self.rateIsFocused = false
    }
    
}

struct LeaseMainView_Previews: PreviewProvider {
    static var previews: some View {
       
        LeaseMainView(myLease: Lease(aDate: today()), endingBalance: .constant("0.00"), currentFile: .constant("file is new"), fileExported: .constant(false), exportSuccessful: .constant(false), fileImported: .constant(false), importSuccessful: .constant(false), selfIsNew: .constant(false), editAmountStarted: .constant(false), editRateStarted: .constant(false), menuIsActive: .constant(true), isPad: .constant(false), isDark: .constant(false))
                .previewInterfaceOrientation(.portrait)
                .preferredColorScheme(.light)
    }
}

let alertStepper: String = "The base term stepper has been disabled because the number of payment groups with more than one payment is greater than one!!!"
let alertMaxAmount: String = "The calculated Lease amount exceeds the maximum allowable amount (50,000,000). As a result, the Lease will be reset to the default parameters.  It is likely that one or more of the Payment Groups has an incorrect payment amount!"
let alertInterestRate: String  = "A valid interest rate must be a decimal that is greater than 0.00 and less than 0.30!!"
let alertExportSuccess: String = "The file was successfully exported to the selected folder.  If exported to iCloud the file can easily be shared with another CFLease user. To delete file from local folder, select File Open then select delete."
let alertExportFailure: String = "The file was not exported!"
let alertImportSuccess: String = "The file has been sucessfully imported, but has not been saved to the CFLease file folder.  To add the imported file to the local folder under the imported name select File Save or select File Save As to savw file under a different name."
let alertImportFailure: String = "The file could not be imported and is likely not a valid CFLease data file!"
