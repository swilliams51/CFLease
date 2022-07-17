//
//  PVRentsView.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/8/21.
//

import SwiftUI

struct PVRentsView: View {
    @ObservedObject var myLease: Lease
    @Binding var isDark: Bool
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var useImplicitRate: Bool = true
    @State private var implicitRate: String = "0.05"
    @State private var discountRate: String = "0.055"
    @State private var editRateStarted: Bool = false
    @State private var editAmountStarted: Bool = false
    @State private var discountRateOnEntry: String = "0.00"
    @State private var residualIsGuaranteed: Bool = false
    @State private var residualGuarantyAmount: String = "0.00"
    @State private var calculateMaxGuaranty:Bool = false
    @State private var residualGuarantyOnEntry: String = "0.00"
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
    
    @State var bookedResidual: Decimal = 0.00
    @State var showPopover: Bool = false
    @State var rateHelp = discountRateHelp
    
    @FocusState private var specifiedRateIsFocused: Bool
    @FocusState private var guarantyAmountIsFocused: Bool
    
    var defaultInactive: Color = Color.theme.inActive
    var defaultActive: Color = Color.theme.active
    var defaultCalculated: Color = Color.theme.calculated
    var activeButton: Color = Color.theme.accent

    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Lease Discount rate").font(.footnote)) {
                    useImplicitRateOptionRow
                    implicitRateRow
                    discountRateRow
                }
                
                Section(header: Text("Lessee Residual Guaranty").font(.footnote), footer: Text("Booked Residual: " + bookedResidual.toPercent(2))) {
                    residualIsGuaranteedRow
                    calculateMaxGtyOptionRow
                        .disabled(residualIsGuaranteed ? false : true)
                    guaranteedAmountRow
                        .disabled(residualIsGuaranteed ? false : true)
                }
                
                Section(header: Text("submit form").font(.footnote)) {
                    submitFormRow
                }
            }
            .navigationTitle("PV of Lease Obligations")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
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
        .onAppear {
            self.implicitRate = self.myLease.implicitRate().toString(decPlaces: 4)
            self.discountRate = self.myLease.leaseObligations?.discountRate ?? "0.00"
            self.residualGuarantyAmount = self.myLease.leaseObligations!.residualGuarantyAmount
            if self.residualGuarantyAmount.toDecimal() > 0.0 {
                self.residualIsGuaranteed = true
            }
            if amountsAreEqual(aAmt1: self.implicitRate.toDecimal(), aAmt2: self.discountRate.toDecimal(), aLamda: 0.0005) == false {
                useImplicitRate = false
            }
            let residualPercent: Decimal = myLease.getTotalResidual() / myLease.amount.toDecimal()
            self.bookedResidual = residualPercent
            
        }
        .alert(isPresented: $showAlert, content: getAlert)
    }
    
    var useImplicitRateOptionRow: some View {
        Toggle(isOn: $useImplicitRate) {
            Text(useImplicitRate ? "use implicit rate:" : "use specified rate:")
                .font(.subheadline)
                .onChange(of: useImplicitRate) { value in
                   recalculate()
                }
        }
    }
    
    var implicitRateRow: some View {
        HStack {
            Text("implicit rate:")
                .font(.subheadline)
                .foregroundColor(useImplicitRate ? defaultActive : defaultInactive)
            Spacer()
            Text(implicitRate.toDecimal().toPercent(2))
                .font(.subheadline)
                .foregroundColor(useImplicitRate ? defaultActive : defaultInactive)
                .disabled(useImplicitRate ? false : true)
        }
        
    }
    
    var discountRateRow: some View {
        HStack{
            Text(useImplicitRate ? "specified rate:" : "specified rate: \(Image(systemName: "return"))")
                .font(.subheadline)
                .foregroundColor(useImplicitRate ? defaultInactive : defaultActive)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover = true
                }
            Spacer()
            ZStack(alignment: .trailing) {
                TextField("",
                          text: $discountRate,
                          onEditingChanged: { (editing) in
                    if editing == true {
                        self.editRateStarted = true
                }})
                    .disabled(useImplicitRate ? true : false)
                    .keyboardType(.decimalPad).foregroundColor(.clear)
                    .focused($specifiedRateIsFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                    .accentColor(.clear)
                Text("\((rateFormatted(editStarted: editRateStarted)))")
                    .font(.subheadline)
                    .foregroundColor(useImplicitRate ? defaultInactive : defaultActive)
            }
        }
        .popover(isPresented: $showPopover) {
            PopoverView(myHelp: $rateHelp, isDark: $isDark)
        }
        
    }
    
    var residualIsGuaranteedRow: some View {
        Toggle(isOn: $residualIsGuaranteed) {
            Text(residualIsGuaranteed ? "residual is guaranteed:" : "no residual guaranty:")
                .font(.subheadline)
                .onChange(of: residualIsGuaranteed) { value in
                    if residualIsGuaranteed == false {
                        self.calculateMaxGuaranty = false
                        self.residualGuarantyAmount = "0.00"
                    } else {
                        self.residualGuarantyAmount = self.residualGuarantyOnEntry
                    }
                }
        }

    }

    var calculateMaxGtyOptionRow: some View {
        Toggle(isOn: $calculateMaxGuaranty) {
            Text(calculateMaxGuaranty ? "calc max guaranty (90% test):" : "specify guaranty amount:")
                .font(.subheadline)
                .onChange(of: calculateMaxGuaranty) { value in
                    if value == true {
                        recalculate()
                        if residualGuarantyAmount.toDecimal() == 0.0 {
                            self.alertTitle = alertInvalidCalculatedGuarantyAmount
                            self.showAlert.toggle()
                            self.residualIsGuaranteed = false
                        }
                    } else {
                        self.residualGuarantyAmount = self.residualGuarantyOnEntry
                    }
                }
        }
    }
    
    var guaranteedAmountRow: some View {
        HStack{
            Text(enterSpecifiedAmount() ? "amount: \(Image(systemName: "return"))" : "amount:")
                .font(.subheadline)
                .foregroundColor(colorGuarantyAmount())
            Spacer()
            ZStack(alignment: .trailing) {
                TextField("",
                          text: $residualGuarantyAmount,
                          onEditingChanged: { (editing) in
                    if editing == true {
                        self.editAmountStarted = true
                }})
                    .disabled(calculateMaxGuaranty ? true : false)
                    .keyboardType(.decimalPad).foregroundColor(.clear)
                    .focused($guarantyAmountIsFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                    .accentColor(.clear)
                Text("\(guaranteedAmountFormatted(editStarted: editAmountStarted))")
                    .font(.subheadline)
                    .foregroundColor(colorGuarantyAmount())
            }
            
        }
        
    }
    
    var submitFormRow: some View {
        HStack {
            Button(action: {}) {
                Text("Cancel")
                    .font(.subheadline)
            }
                .multilineTextAlignment(.leading)
                .disabled(decimalpadIsActive())
                .onTapGesture {
                    self.presentationMode.wrappedValue.dismiss()
            }
            Spacer()
            Button(action: {}) {
                Text("Done")
                    .font(.subheadline)
            }
                .multilineTextAlignment(.trailing)
                .disabled(decimalpadIsActive())
                .onTapGesture {
                    if self.useImplicitRate == true {
                        self.myLease.leaseObligations = Obligations(aDiscountRate: self.implicitRate, aResidualGuarantyAmount: self.residualGuarantyAmount)
                    } else {
                        self.myLease.leaseObligations = Obligations(aDiscountRate: self.discountRate, aResidualGuarantyAmount: self.residualGuarantyAmount)
                    }
                    self.presentationMode.wrappedValue.dismiss()
            }
        }
        
    }
    
    func getAlert() -> Alert{
        return Alert(title: Text(alertTitle))
    }
    
    func colorGuarantyAmount() -> Color {
        if residualIsGuaranteed == false {
            return defaultInactive
        } else if calculateMaxGuaranty == false {
            return defaultActive
        } else {
            return defaultCalculated
        }
    }
    
    func enterSpecifiedAmount() -> Bool{
        if residualIsGuaranteed == false {
            return false
        } else {
            if calculateMaxGuaranty == true {
                return false
            } else {
                return true
            }
        }
    }
    
    func maxResidualGuaranty() -> Decimal {
        return myLease.getTotalResidual()
    }
    
    func decimalpadIsActive() -> Bool {
        var padIsActive: Bool = false
        if specifiedRateIsFocused == true || guarantyAmountIsFocused == true {
            padIsActive = true
        }
        
        return padIsActive
    }
    
    func recalculate() {
        var maxGuaranty: Decimal = 0.0
        if self.calculateMaxGuaranty == true {
            if self.useImplicitRate == true {
                
                maxGuaranty = max(0.00,self.myLease.getMaxResidualGuaranty(discountRate: self.implicitRate.toDecimal()))
            } else {
                
                maxGuaranty = max(0.00,self.myLease.getMaxResidualGuaranty(discountRate: self.discountRate.toDecimal()))
            }
        }
        self.residualGuarantyAmount = maxGuaranty.toString()
    }
    
    func rateFormatted (editStarted: Bool) -> String {
        if editStarted == true {
            return discountRate.toTruncDecimalString(decPlaces: 6)
        } else {
            return discountRate.toDecimal().toPercent(2)
        }
    }
    
    func guaranteedAmountFormatted(editStarted: Bool) -> String {
        if editStarted == true {
            return residualGuarantyAmount.toTruncDecimalString(decPlaces: 7)
        } else {
            return residualGuarantyAmount.toDecimal().toCurrency(false)
        }
    }
    
    func percentToAmount(percent: String) -> String {
        let decAmount: Decimal = percent.toDecimal() * self.myLease.amount.toDecimal()
        return decAmount.toString(decPlaces: 2)
    }
    
    func updateForCancel() {
        if editRateStarted == true {
            self.discountRate = self.discountRateOnEntry
        }
        if editAmountStarted == true {
            self.residualGuarantyAmount = self.residualGuarantyOnEntry
        }
        self.specifiedRateIsFocused = false
        self.guarantyAmountIsFocused = false
    }
    
    
    func updateForSubmit() {
        if editRateStarted == true {
            self.editRateStarted = false
            if isInterestRateValid(strRate: discountRate, decLow: 0.0, decHigh: 0.20, inclusiveLow: false, inclusiveHigh: true) == false {
                discountRate = discountRateOnEntry
                self.alertTitle = alertInvalidSpecifiedRate
                self.showAlert.toggle()
            } else {
                recalculate()
            }
        }
        if editAmountStarted == true {
            editAmountStarted = false
            if isAmountValid(strAmount: residualGuarantyAmount, decLow: 0.0, decHigh: maxResidualGuaranty(), inclusiveLow: false, inclusiveHigh: true) == false {
                self.residualGuarantyAmount = self.residualGuarantyOnEntry
                self.alertTitle = alertInvalidGuarantyAmount
                self.showAlert.toggle()
            } else {
                if self.residualGuarantyAmount.toDecimal() < 1.0 {
                    self.residualGuarantyAmount = percentToAmount(percent: residualGuarantyAmount)
                }
            }
        }
        self.specifiedRateIsFocused = false
        self.guarantyAmountIsFocused = false
    }
    
    
}

struct PVRentsView_Previews: PreviewProvider {
    static var previews: some View {
        PVRentsView(myLease: Lease(aDate: today()), isDark: .constant(false))
            .preferredColorScheme(.dark)
    }
}

let alertInvalidGuarantyAmount: String = "The amount of the residual guaranty must be equal to or greater than zero but cannot excced the residual amount!!!"
let alertInvalidCalculatedGuarantyAmount: String = "The calculated amount of the residual guaranty is less then zero. Therefore, the lessee residual guaranty will be set to no residual guaranty!!!"
let alertInvalidSpecifiedRate: String = "The discount rate must equal to or greater than 0.00% and less than the maxumum allowable rate!!!"
