//
//  OneGroupView.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/1/21.
//

import SwiftUI

struct OneGroupView: View {
    @State var myGroup: Group
    @ObservedObject var myGroups: Groups
    @ObservedObject var myLease: Lease
    @Binding var endingBalance: String
    @Binding var isDark: Bool

    @Environment(\.presentationMode) var presentationMode
    @AppStorage("maxBaseTerm") var maxBaseTerm: Int = 120
    @State private var index = 0
    @State private var count = 0
    
    @State private var isInterimGroup: Bool = false
    @State private var isResidualGroup: Bool = false
    @State private var isCalculatedPayment: Bool = false
    
    @State private var editStarted: Bool = false
    @State private var noOfPayments: Double = 1.0
    @State private var startingNoOfPayments: Double = 120.0
    @State private var startingTotalPayments: Double = 120.0
    @State private var pmtTextFieldIsLocked: Bool = false
    @State private var paymentOnEntry: String = "0.0"
    @State private var sliderIsLocked: Bool = false
    @State private var rangeOfPayments: ClosedRange<Double> = 1.0...120.0
   
    @State var showPopover: Bool = false
    @State var payHelp = paymentAmountHelp
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
   
    @FocusState private var amountIsFocused: Bool
   
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Payment Details").font(.footnote)) {
                    paymentTypeItem
                    noOfPaymentsItem
                    paymentTimingItem
                    paymentAmountItem
                    paymentLockedItem
                }
                Section(header: Text("Submit Form").font(.footnote)){
                    submitForm
                }
            }
            .navigationTitle("Payment Group Details")
            .navigationViewStyle(.stack)
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                ToolbarItemGroup(placement: .keyboard){
                    Button("Cancel") {
                        if self.editStarted == true {
                            self.myGroup.amount = self.paymentOnEntry
                            self.editStarted = false
                        }
                        self.amountIsFocused = false
                    }
                    Spacer()
                    Button("Enter") {
                        if self.editStarted == true {
                            updateForPaymentAmount()
                        }
                        self.amountIsFocused = false
                    }
                }
            }//
            
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .onAppear{
            self.index = self.myGroups.items.firstIndex { $0.id == myGroup.id }!
            self.count = self.myGroups.items.count - 1
            
            if self.index == 0 && myLease.interimGroupExists() == true {
                isInterimGroup = true
            }
            
            if self.myGroup.isResidualPaymentType() == true {
                self.isResidualGroup = true
            }
            if self.isInterimGroup || self.isResidualGroup {
                self.sliderIsLocked = true
            }
            
            if self.isInterimGroup == false && self.isResidualGroup == false {
                self.rangeOfPayments = rangeNumberOfPayments()
            }
            if self.myGroup.isCalculatedPaymentType() {
                self.resetForPaymentTypeChange()
            }
            
            self.noOfPayments = self.myGroup.noOfPayments.toDouble()
            self.startingNoOfPayments = self.noOfPayments
            self.startingTotalPayments = Double(self.myGroups.getTotalNoOfPayments())
            self.paymentOnEntry = self.myGroup.amount
        
        }
       
        
        .alert(isPresented: $showAlert, content: getAlert)
     
    }
    // View variables
    
    func updateForPaymentAmount() {
        if myGroup.amount == "" {
            self.myGroup.amount = "0.00"
        }
        if isAmountValid(strAmount: myGroup.amount, decLow: 0.0, decHigh: myLease.amount.toDecimal(), inclusiveLow: true, inclusiveHigh: true) == false {
            self.myGroup.amount = self.paymentOnEntry
            alertTitle = alertPaymentAmount
            showAlert.toggle()
        } else {
            if self.myGroup.amount.toDecimal() < 1.0 {
                self.myGroup.amount = percentToAmount(percent: myGroup.amount)
            }
        }
        self.editStarted = false
    }
    
    
    var paymentTypeItem: some View {
        Picker(selection: $myGroup.type, label: Text("type:").font(.subheadline)) {
            ForEach(getPaymentTypes(), id: \.self) { paymentType in
                Text(paymentType.toString())
            }
            .onChange(of: myGroup.type, perform: { value in
                self.resetForPaymentTypeChange()
            })
            .font(.subheadline)
        }
    }
    
    var noOfPaymentsItem: some View {
        VStack {
            HStack {
                Text("no. of payments:")
                    .font(.subheadline)
                Spacer()
                Text("\(myGroup.noOfPayments.toString())")
                    .font(.subheadline)
            }
            Slider(value: $noOfPayments, in: rangeOfPayments, step: 1) {

            }
            .disabled(sliderIsLocked)
            .onChange(of: noOfPayments) { newNumber in
                self.myGroup.noOfPayments = newNumber.toInteger()
            }
        }
    }
    
    var paymentTimingItem: some View {
        Picker(selection: $myGroup.timing, label: Text("timing:").font(.subheadline)) {
            ForEach(getTimingTypes(), id: \.self) { PaymentTiming in
                Text(PaymentTiming.toString())
                    .font(.subheadline)
            }
            .onChange(of: myGroup.timing, perform: { value in
            })
        }
    }
    
    var paymentAmountItem: some View {
        HStack{
            Text(isCalculatedPayment ? "amount:" : "amount: \(Image(systemName: "return"))")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover = true
                }
            Spacer()
            ZStack(alignment: .trailing) {
                TextField("",
                  text: $myGroup.amount,
                  onEditingChanged: { (editing) in
                    if editing == true {
                        self.editStarted = true
                }})
//                    .onSubmit {
//                        editStarted = false
//                        if myGroup.amount == "" {
//                            self.myGroup.amount = "0.00"
//                        }
//                        if isAmountValid(strAmount: myGroup.amount, decLow: 0.0, decHigh: myLease.amount.toDecimal(), inclusiveLow: true, inclusiveHigh: true) == false {
//                            self.myGroup.amount = self.paymentOnEntry
//                            alertTitle = alertPaymentAmount
//                            showAlert.toggle()
//
//                        } else {
//                            if myGroup.amount.toDecimal() < 1.0 {
//                                self.myGroup.amount = percentToAmount(percent: myGroup.amount)
//                            }
//                        }
//                    }
                    .disabled(pmtTextFieldIsLocked)
                    .keyboardType(.decimalPad).foregroundColor(.clear)
                    .focused($amountIsFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                    .accentColor(.clear)
                Text("\(paymentFormatted(editStarted: editStarted))")
                    .font(.subheadline)
            }
        }
        .popover(isPresented: $showPopover) {
            PopoverView(myHelp: $payHelp, isDark: $isDark)
        }
    }
    
    var paymentLockedItem: some View {
        Toggle(isOn: $myGroup.locked) {
            Text(myGroup.locked ? "locked:" : "unlocked:")
                .font(.subheadline)
        }
        .font(.subheadline)
        .disabled(pmtTextFieldIsLocked)
    }
    
    var submitForm: some View {
        HStack {
            deleteGroupButtonRow
            Spacer()
            doneButtonRow
        }
    }
    
    var deleteGroupButtonRow: some View {
        Button(action: {}) {
            Text("Delete Group")
                .font(.subheadline)
        }
        .multilineTextAlignment(.trailing)
        .disabled(amountIsFocused)
        .onTapGesture {
            if isInterimGroup {
                self.alertTitle = alertInterimGroup
                self.showAlert.toggle()
            } else if isResidualGroup {
                self.myLease.groups.items.remove(at: index)
                self.endingBalance = self.myLease.getEndingBalance().toString(decPlaces: 5)
                self.presentationMode.wrappedValue.dismiss()
            } else {
                if self.myLease.groups.items[index].undeletable == false {
                    self.myLease.groups.items.remove(at: index)
                    self.myLease.resetFirstGroup(isInterim: self.myLease.interimGroupExists())
                    self.endingBalance = self.myLease.getEndingBalance().toString(decPlaces: 5)
                    self.presentationMode.wrappedValue.dismiss()
                } else {
                    if self.myLease.groups.noOfGroupsWithMoreThanOnePayment() > 1 {
                        self.myLease.groups.items[index + 1].undeletable = true
                        self.myLease.groups.items.remove(at: index)
                        self.myLease.resetFirstGroup(isInterim: self.myLease.interimGroupExists())
                        self.endingBalance = self.myLease.getEndingBalance().toString(decPlaces: 5)
                        self.presentationMode.wrappedValue.dismiss()
                    } else {
                        self.alertTitle = alertFirstPaymentGroup
                        self.showAlert.toggle()
                    }
                }
            }
        }
    }
    
    var doneButtonRow: some View {
        Button(action: {}) {
            Text("Done")
                .font(.subheadline)
        }
        .multilineTextAlignment(.trailing)
        .disabled(amountIsFocused)
        .onTapGesture {
            self.myGroups.items[index].amount = myGroup.amount
            self.myGroups.items[index].locked = myGroup.locked
            self.myGroups.items[index].noOfPayments = myGroup.noOfPayments
            self.myGroups.items[index].timing = myGroup.timing
            self.myGroups.items[index].type = myGroup.type
            if self.myLease.interimGroupExists() == true && self.isInterimGroup == false {
                self.myLease.resetRemainderOfGroups(startGrp: 1)
            } else {
                self.myLease.resetFirstGroup(isInterim: self.isInterimGroup)
            }
            self.endingBalance = self.myLease.getEndingBalance().toString(decPlaces: 6)
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct OneGroupView_Previews: PreviewProvider {
    static var myLease: Lease = Lease(aDate: today())
    
    static var previews: some View {
        OneGroupView(myGroup: myLease.groups.items[0], myGroups: myLease.groups, myLease: Lease(aDate: today()), endingBalance: .constant("0.00"), isDark: .constant(false))
            .preferredColorScheme(.light)
    }
}

// Mark Private Functiona
extension OneGroupView {
    func getAlert() -> Alert{
        return Alert(title: Text(alertTitle))
    }
    
    func getPaymentTypes() -> [PaymentType] {
        if self.isInterimGroup {
            return PaymentType.interimTypes
        } else if self.isResidualGroup {
            return PaymentType.residualTypes
        } else {
            return PaymentType.defaultTypes
        }
    }
    
    func getTimingTypes() -> [PaymentTiming] {
        if myGroup.type == .residual || myGroup.type == .balloon {
            return PaymentTiming.residualCases
        } else if myGroup.type == .interest {
            return PaymentTiming.interestCases
        } else {
            return PaymentTiming.paymentCases
        }
    }
    
    func getDefaultPaymentAmount() -> String {
        var defaultAmount: String = (self.myLease.amount.toDecimal() * 0.015).toString(decPlaces: 3)
        
        if self.myLease.groups.items.count > 1 {
            for x in 0..<self.myLease.groups.items.count {
                if self.myLease.groups.items[x].amount != "CALCULATED" {
                    defaultAmount = self.myLease.groups.items[x].amount.toDecimal().toString(decPlaces: 3)
                    break
                }
            }
        }
        
        return defaultAmount
    }
    
    
    func percentToAmount(percent: String) -> String {
        let decAmount: Decimal = percent.toDecimal() * myLease.amount.toDecimal()
        return decAmount.toString(decPlaces: 2)
    }
    
    func paymentFormatted(editStarted: Bool) -> String {
        if isCalculatedPayment == true {
            return myGroup.amount
        } else {
            if editStarted == true {
                return myGroup.amount
            }
            return myGroup.amount.toDecimal().toCurrency(false)
        }
    }
    
    func rangeNumberOfPayments () -> ClosedRange<Double> {
        let starting: Double = 1.0
        let maxNumber: Double = myLease.getMaxRemainNumberPayments(maxBaseTerm: maxBaseTerm, freq: myLease.paymentsPerYear, eom: myLease.endOfMonthRule, aRefer: myLease.firstAnniversaryDate).toDouble()
        let currentNumber:Double = myGroup.noOfPayments.toDouble()
        let ending: Double = maxNumber + currentNumber
        
        return starting...ending
    }
    
    func resetForPaymentTypeChange() {
        if myGroup.isCalculatedPaymentType() == true {
            isCalculatedPayment = true
            pmtTextFieldIsLocked = true
            myGroup.locked = true
            if myGroup.amount != "CALCULATED" {
                myGroup.amount = "CALCULATED"
            }
            if myGroup.type == .interest {
                myGroup.timing = .arrears
            }
        } else {
            isCalculatedPayment = false
            pmtTextFieldIsLocked = false
            if myGroup.amount == "CALCULATED" {
                myGroup.amount = getDefaultPaymentAmount()
                myGroup.locked = false
            }
            if myGroup.isResidualPaymentType() {
                sliderIsLocked = true
            } else {
                sliderIsLocked = false
            }
        }
       
    }
    
}

let alertInterimGroup: String = "To delete an interim payment group go to the home screen and reset the base term commencement date to equal the funding date!!"
let alertFirstPaymentGroup: String = "The last payment group in which the number of payments is greater than 1 cannot be deleted!!"
let alertPaymentAmount: String = "The payment amount cannot exceed the lease amount. Return to home screen and adjust lease amount.  Note, payment amounts entered as a decimal < 1.00 will interpreted as a percent of lease amount and then converted to the equivalent dollar payment amount!!"
