//
//  EarlyBuyoutView.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/30/21.
//

import SwiftUI

struct EarlyBuyoutView: View {
    @ObservedObject var myLease: Lease
    @Environment(\.presentationMode) var presentationMode
    @Binding var isDark: Bool
    
    @State private var eboDate: Date = today()
    @State private var eboAmount: String = "0.00"
    @State private var eboTerm: Int = 42
    @State private var rentDueIsPaid = true
    @State private var parValue: String = "0.00"
    @State private var basisPoints: Double = 0.00
    @State private var premiumIsSpecified = false
    @State private var editStarted: Bool = false
    @State private var stepValue: Int = 1
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
    @State private var showPopover: Bool = false
    @State private var myEBOHelp = eboHelp
    @State private var amountColor: Int = 1
    @FocusState private var specifiedAmountIsFocused: Bool
    
    var defaultInactive: Color = Color.theme.inActive
    var defaultCalculated: Color = Color.theme.calculated
    var activeButton: Color = Color.theme.accent
    var standard: Color = Color.theme.active
   
    var body: some View {
        NavigationView{
            Form {
                Section (header: Text("Excercise Date").font(.footnote)) {
                    eboTermInMonsRow
                    exerciseDateRow
                    includesRentDueRowItem
                    parValueOnDateRow
                }
                
                Section (header: Text("EBO Amount").font(.footnote)) {
                    eboOptionAmountRow
                    interestRateAdderRow
                    specifiedAmountRow
                }
                Section (header: Text("Submit Form").font(.footnote)) {
                    submitFormRow
                }
            }
            .navigationTitle("Early Buyout Parameters")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            .toolbar{
                ToolbarItemGroup (placement: .keyboard) {
                    Button("Cancel") {
                        if self.editStarted == true {
                            self.eboAmount = self.parValue
                        }
                        self.specifiedAmountIsFocused = false
                    }
                    Spacer()
                    Button("Enter") {
                        if self.editStarted == true {
                            self.editStarted = false
                            if isAmountValid(strAmount: eboAmount, decLow: 0.0, decHigh: myLease.amount.toDecimal(), inclusiveLow: false, inclusiveHigh: true) == false {
                                self.eboAmount = self.parValue
                                alertTitle = alertInvalidEBOAmount
                                showAlert.toggle()
                            } else {
                                var decEBOAmount:Decimal = self.eboAmount.toDecimal()
                                if decEBOAmount < 1.0 {
                                    decEBOAmount = self.myLease.amount.toDecimal() * decEBOAmount
                                }
                                if decEBOAmount < self.parValue.toDecimal() {
                                    self.eboAmount = self.parValue
                                    alertTitle = alertInvalidEBOAmount
                                    showAlert.toggle()
                                } else {
                                    self.eboAmount = decEBOAmount.toString()
                                    self.basisPoints = Double(self.myLease.getEBOPremium(aLease: self.myLease, exerDate: self.eboDate, aEBOAmount: self.eboAmount, rentDueIsPaid: rentDueIsPaid).toString().toInteger())
                                }
                            }
                            self.specifiedAmountIsFocused = false
                        }
                    }
                }
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .onAppear {
            print("\(self.myLease.getMaturityDate().toStringDateShort())")
            if self.myLease.earlyBuyOut!.exerciseDate == self.myLease.getMaturityDate() {
                self.eboDate = Calendar.current.date(byAdding: .month, value: -12, to: self.myLease.getMaturityDate())!
                print("\(self.myLease.getMaturityDate().toStringDateShort())")
            } else {
                self.eboDate = self.myLease.earlyBuyOut!.exerciseDate
            }
            self.rentDueIsPaid = self.myLease.earlyBuyOut!.rentDueIsPaid
            if self.myLease.earlyBuyOut!.amount == "0.00" {
                self.eboAmount = self.myLease.getParValue(askDate: self.eboDate, rentDueIsPaid: self.rentDueIsPaid).toString(decPlaces: 2)
            } else {
                self.eboAmount = self.myLease.earlyBuyOut!.amount
                self.basisPoints = Double(self.myLease.getEBOPremium(aLease: self.myLease, exerDate: self.eboDate, aEBOAmount: self.eboAmount, rentDueIsPaid: self.rentDueIsPaid))
            }
            self.eboTerm = self.myLease.getEBOTerm(exerDate: self.eboDate)
            self.parValue = self.myLease.getParValue(askDate: self.eboDate, rentDueIsPaid: self.rentDueIsPaid).toString()
        }
        .alert(isPresented: $showAlert, content: getAlert)
        .popover(isPresented: $showPopover) {
            PopoverView(myHelp: $myEBOHelp, isDark: $isDark)
        }
    }
    
    var eboTermInMonsRow: some View {
        HStack {
            Text("term in mons: \(eboTerm)")
                .font(.subheadline)
            Stepper(value: $eboTerm, in: rangeBaseTermMonths, step: getStep()) {
    
            }.onChange(of: eboTerm) { newTerm in
                let noOfPeriods: Int = newTerm / (12 / self.myLease.paymentsPerYear.rawValue)
                self.eboDate = self.myLease.getExerciseDate(term: noOfPeriods)
                self.basisPoints = 0.0
            }
        }
        .font(.subheadline)
    }
    
    var exerciseDateRow: some View {
        HStack {
            Text("exercise date:")
                .font(.subheadline)
                .foregroundColor(defaultInactive)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover = true
                }
            
            Spacer()
            Text(eboDate.toStringDateShort())
                .font(.subheadline)
                .foregroundColor(defaultInactive)
                .onChange(of: eboDate) { newDate in
                    self.parValue = self.myLease.getParValue(askDate: newDate, rentDueIsPaid: rentDueIsPaid).toString()
                    self.eboAmount = self.parValue
                }
        }
    }
    
    var parValueOnDateRow: some View {
        HStack {
            Text("par value on date:")
                .font(.subheadline)
                .foregroundColor(defaultInactive)
            Spacer()
            Text(parValue.toDecimal().toCurrency(false))
                .font(.subheadline)
                .foregroundColor(defaultInactive)
        }
    }
    
    var includesRentDueRowItem: some View {
        Toggle(isOn: $rentDueIsPaid) {
            Text(rentDueIsPaid ? "rent due will also be paid:" : "rent due will not be paid:")
                .font(.subheadline)
                .onChange(of: rentDueIsPaid) { value in
                    self.parValue = self.myLease.getParValue(askDate: eboDate, rentDueIsPaid: value).toString()
                    self.eboAmount = self.parValue
                    self.basisPoints = 0.0
                }
        }
    }
    
    var eboOptionAmountRow: some View {
        Toggle(isOn: $premiumIsSpecified) {
            Text(premiumIsSpecified ? "amount is specified:" : "amount is calculated:")
                .font(.subheadline)
                .onChange(of: premiumIsSpecified) { value in
                    if value == true {
                        self.basisPoints = Double(self.myLease.getEBOPremium(aLease: self.myLease,  exerDate: self.eboDate, aEBOAmount: self.eboAmount, rentDueIsPaid: rentDueIsPaid).toString().toInteger())
                        self.amountColor = 0
                    } else {
                        self.basisPoints = 0.00
                        self.eboAmount = self.parValue
                        self.amountColor = 1
                    }
                }
        }
        
    }
    
    var interestRateAdderRow: some View {
        VStack {
            HStack {
                Text("interest rate adder:")
                    .font(.subheadline)
                    .foregroundColor(premiumIsSpecified ? defaultInactive : defaultCalculated)
                Spacer()
                Text("\(basisPoints, specifier: "%.0f") bps")
                    .font(.subheadline)
                    .foregroundColor(premiumIsSpecified ? defaultInactive : defaultCalculated)
            }
            
            Slider(value: $basisPoints, in: 0...300, step: 1) { editing in
                self.amountColor = 1
            }

            .disabled(premiumIsSpecified ? true : false)
        }
    }
    
    var specifiedAmountRow: some View {
        HStack{
            calculatedButtonItem
            Spacer()
            specifiedAmountTextField
        }
    }
    
    var calculatedButtonItem: some View {
        Button(action: {}) {
            Text(self.premiumIsSpecified ? "specified: \(Image(systemName: "return"))" : "calculate")
                .font(.subheadline)
                .foregroundColor(premiumIsSpecified ?  standard : activeButton)
        }
        .disabled(premiumIsSpecified ? true : false )
        .multilineTextAlignment(.trailing)
        .onTapGesture {
            self.amountColor = 0
            self.eboAmount = self.myLease.getEBOAmount(aLease: myLease, bpsPremium: Int(self.basisPoints), exerDate: self.eboDate, rentDueIsPaid: rentDueIsPaid)
        }
        
    }
    
    var specifiedAmountTextField: some View {
        ZStack(alignment: .trailing) {
            TextField("",
              text: $eboAmount,
              onEditingChanged: { (editing) in
                if editing == true {
                    self.editStarted = true
            }})
                .disabled(self.premiumIsSpecified ? false : true)
                .focused($specifiedAmountIsFocused)
                .keyboardType(.decimalPad).foregroundColor(.clear)
                .textFieldStyle(PlainTextFieldStyle())
                .disableAutocorrection(true)
                .accentColor(.clear)

            Text("\(eboFormatted(editStarted:editStarted))")
                .font(.subheadline)
                .foregroundColor(resetAmountColor())
        }
        
    }
    
    var submitFormRow: some View {
        HStack {
            cancelButtonItem
            Spacer()
            doneButtonItem
        }
    }
    
    var cancelButtonItem: some View {
        Button(action: {}) {
            Text("Cancel")
                .font(.subheadline)
        }
        .multilineTextAlignment(.leading)
        .disabled(specifiedAmountIsFocused)
        .onTapGesture {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    var doneButtonItem: some View {
        Button(action: {}) {
            Text("Done")
                .font(.subheadline)
        }
        .multilineTextAlignment(.trailing)
        .disabled(specifiedAmountIsFocused)
        .onTapGesture {
            self.myLease.earlyBuyOut = EarlyPurchaseOption(aExerciseDate: self.eboDate, aAmount: self.eboAmount, rentDue: self.rentDueIsPaid)
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func resetAmountColor() -> Color {
        switch amountColor {
        case 0:
            return standard
        case 1:
            return defaultCalculated
        default:
            return defaultInactive
        }
    }
    
    func getAlert() -> Alert{
        return Alert(title: Text(alertTitle))
    }
    
    var rangeBaseTermMonths: ClosedRange<Int> {
        let starting: Int = 12
        let ending: Int = myLease.getBaseTermInMons() - 12
        
        return starting...ending
    }
    
    func getStep() -> Int {
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
    
    func eboFormatted(editStarted: Bool) -> String {
        if editStarted == true {
            return self.eboAmount.toTruncDecimalString(decPlaces: 7)
        } else {
            return self.eboAmount.toDecimal().toCurrency(false)
        }
    }
    
}

struct EarlyBuyoutView_Previews: PreviewProvider {
    static var previews: some View {
        EarlyBuyoutView(myLease: Lease(aDate: today()), isDark: .constant(false))
            .preferredColorScheme(.dark)
    }
}

let alertInvalidEBOAmount: String  = "The EBO amount must be equal to or greater than the par value of the lease on the exercise date and less than lease amount on the funding date!!!"
