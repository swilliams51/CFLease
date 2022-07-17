//
//  LesseePaidFeeView.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 1/1/22.
//

import SwiftUI

struct LesseePaidFeeView: View {
    @ObservedObject var myLease: Lease
    @Binding var isDark: Bool
    @Environment(\.presentationMode) var presentationMode
    
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
    
    @State private var solveForImplicit: Bool = false
    @State var feePaid: String = "0.00"
    @State var amountOnEntry: String = "0.00"
    @State var rateOnEntry: String = "0.05"
    @State var customerRate: String = "0.05"
    @State var editAmountStarted: Bool = false
    @State var editRateStarted: Bool = false
    @State var showPopover: Bool = false
    @State var myImplictRateHelp: Help = implicitRateHelp
    
    @FocusState private var feeIsFocused: Bool
    @FocusState private var rateIsFocused: Bool
    
    var calculatedColor: Color = Color.theme.calculated
    var defaultActive: Color = Color.theme.active
    var defaultInactive: Color = Color.theme.inActive
    
    var body: some View {
        NavigationView {
            Form {
                Section (header: Text("Fee Paid at Funding").font(.footnote)) {
                    solveForRow
                    feePaidRow
                    implicitRateRow
                }
                Section (header: Text("Submit Form").font(.footnote)) {
                    submitFormRow
                }
            }
            .navigationTitle("Lessee Paid Fee")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Cancel"){
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
        .onAppear {
            self.amountOnEntry = self.myLease.lesseePaidFee
            self.feePaid = self.myLease.lesseePaidFee
            self.customerRate = self.myLease.implicitRate().toString()
        }
        .alert(isPresented: $showAlert, content: getAlert)
        .popover(isPresented: $showPopover) {
            PopoverView(myHelp: $myImplictRateHelp, isDark: $isDark)
        }
    }
    
    var solveForRow: some View {
        HStack {
            Text(solveForImplicit ? "solve for fee:" : "solve for implicit:")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover = true
                }
            Spacer()
            Toggle("", isOn: $solveForImplicit)
        }
    }

    var feePaidRow: some View {
        HStack{
            Text(solveForImplicit ? "calculated fee:" : "fee amount: \(Image(systemName: "return"))")
                .font(.subheadline)
                .foregroundColor(solveForImplicit ? calculatedColor : defaultActive)
            Spacer()
            ZStack(alignment: .trailing) {
                TextField("",
                          text: $feePaid,
                          onEditingChanged: { (editing) in
                    if editing == true {
                        editAmountStarted = true
                    }})
                    .disabled(solveForImplicit ? true : false)
                    .keyboardType(.decimalPad).foregroundColor(.clear)
                    .focused($feeIsFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                    .accentColor(.clear)
                Text("\(amountFormatted(editStarted: editAmountStarted))")
                    .font(.subheadline)
                    .foregroundColor(solveForImplicit ? calculatedColor : defaultActive)
            }
        }
    }
    
    var implicitRateRow: some View {
        HStack{
            Text(solveForImplicit ? "implicit rate: \(Image(systemName: "return"))" : "calculated implicit:")
                .font(.subheadline)
                .foregroundColor(solveForImplicit ? defaultActive : calculatedColor)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover = true
                }
            Spacer()
            ZStack(alignment: .trailing) {
                TextField("",
                          text: $customerRate,
                          onEditingChanged: { (editing) in
                    if editing == true {
                        editRateStarted = true
                    }})
                    .disabled(solveForImplicit ? false : true)
                    .keyboardType(.decimalPad).foregroundColor(.clear)
                    .focused($rateIsFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                    .accentColor(.clear)
                Text("\(implicitFormatted(editStarted: editRateStarted))")
                    .font(.subheadline)
                    .foregroundColor(solveForImplicit ? defaultActive : calculatedColor)
            }
        }
    }
    
    var submitFormRow: some View {
        HStack{
            cancelButtonRow
            Spacer()
            doneButtonRow
        }
    }
    
    var doneButtonRow: some View {
        Button(action: {}) {
            Text("Done")
                .font(.subheadline)
        }
        .multilineTextAlignment(.trailing)
        .disabled(keyboardActive())
        .onTapGesture {
            self.myLease.lesseePaidFee = self.feePaid
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    var cancelButtonRow: some View {
        Button(action: {}) {
            Text("Cancel")
                .font(.subheadline)
        }
        .multilineTextAlignment(.trailing)
        .disabled(keyboardActive())
        .onTapGesture {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func getAlert() -> Alert{
        return Alert(title: Text(alertTitle))
    }
    
    func amountFormatted (editStarted: Bool) -> String {
        if editStarted == true {
            return feePaid
        } else {
            return feePaid.toDecimal().toCurrency(false)
        }
    }
    
    func implicitFormatted (editStarted: Bool) -> String {
        if editStarted == true {
            return customerRate
        } else {
            return customerRate.toDecimal().toPercent(3)
        }
    }
    
    func percentToAmount(percent: String) -> String {
        let decAmount: Decimal = percent.toDecimal() * myLease.amount.toDecimal()
        return decAmount.toString(decPlaces: 2)
    }

    func setCustomerRate() {
        let tempLease = myLease.clone()
        tempLease.lesseePaidFee = self.feePaid
        let rate: Decimal = tempLease.implicitRate()
        
        self.customerRate = rate.toString(decPlaces: 5)
    }
    
    func setLesseePaidFee() {
        let tempLease = myLease.clone()
        let tempCashflow: Cashflows = Cashflows(aLease: tempLease, returnType: .principal)
        let npv = tempCashflow.XNPV(aDiscountRate: self.customerRate.toDecimal(), aDayCountMethod: tempLease.interestCalcMethod)
        
        let newFee: Decimal = (tempLease.amount.toDecimal() - npv)
        self.feePaid = newFee.toString(decPlaces: 4)
    }
    
    func updateForNewFeeAmount() {
        editAmountStarted = false
        if isAmountValid(strAmount: feePaid, decLow: 0.0, decHigh: myLease.amount.toDecimal(), inclusiveLow: true, inclusiveHigh: true) == false {
            feePaid = amountOnEntry
            alertTitle = alertValidFeeAmount
            showAlert.toggle()
        } else {
            if feePaid.toDecimal() < 1.0 {
                feePaid = percentToAmount(percent: feePaid)
            }
            self.setCustomerRate()
        }
    }
    
    func updateForNewImplicit() {
        editRateStarted = false
        if isInterestRateValid(strRate: self.customerRate, decLow: myLease.interestRate.toDecimal(), decHigh: maximumInterestRate.toDecimal(), inclusiveLow: true, inclusiveHigh: true) == false {
            self.customerRate = self.rateOnEntry
            alertTitle = alertValidImplicit
            showAlert.toggle()
        } else {
            self.setLesseePaidFee()
        }
    }
    
    func updateForCancel() {
        if self.editAmountStarted == true {
            self.feePaid = self.amountOnEntry
            self.editAmountStarted = false
        }
        self.feeIsFocused = false
        if self.editRateStarted == true {
            self.customerRate = self.rateOnEntry
            self.editRateStarted = false
        }
        self.rateIsFocused = false
    }
    
    func updateForSubmit() {
        if editAmountStarted == true {
           updateForNewFeeAmount()
        }
        if editRateStarted == true {
            updateForNewImplicit()
        }
        self.feeIsFocused = false
        self.rateIsFocused = false
    }
    
    func keyboardActive() -> Bool {
        if feeIsFocused == true || rateIsFocused == true {
            return true
        } else {
            return false
        }
    }
    
}


    
struct LesseePaidFeeView_Previews: PreviewProvider {
    static var previews: some View {
        LesseePaidFeeView(myLease: Lease(aDate: today()), isDark: .constant(false))
            .preferredColorScheme(.dark)
    }
}

let alertValidFeeAmount: String = "The fee amount must be equal to or greater than zero and less than the lease amount!!"
let alertValidImplicit: String = "The implicit rate must equal to or greater than the lease interest but less than the maximum interest rate!!"
