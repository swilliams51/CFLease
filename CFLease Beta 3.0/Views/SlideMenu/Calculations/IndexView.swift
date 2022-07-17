//
//  IndexView.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 3/31/22.
//

import SwiftUI

struct IndexView: View {
    @ObservedObject var myLease: Lease
    @Binding var isDark: Bool
    @Environment(\.presentationMode) var presentationMode
    
    @State var lowerBoundIndexTerm: Int = 2
    @State var lowerBoundIndexYield: String = "0.02"
    @State var upperBoundIndexTerm: Int = 5
    @State var upperBoundIndexYield: String = "0.0425"
    @State var editRateStarted: Bool = false
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section (header: Text("Lease")){
                    HStack {
                        Text("average life:")
                        Spacer()
                        Text("\(myLease.averageLife().toString(decPlaces: 2))")
                    }

                }
                Section (header: Text("Lower Bound Index")) {
                    lowerBoundIndexTermItem
                    lowerBoundYieldItem
                }
                Section (header: Text("Upper Bound Index")) {
                    upperBoundIndexTermItem
                    upperBoundIndexYieldItem
                }
                Section (header: Text("Submit Form").font(.footnote)) {
                    submitFormRow
                }
                
            }
            .navigationTitle("Spread to Index")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
        }
       
    }
    
    var lowerBoundIndexTermItem: some View {
        HStack {
            Text("tenor: \(lowerBoundIndexTerm) year")
                .font(.subheadline)
            Stepper(value: $lowerBoundIndexTerm, in: rangeOfIndexTerms(), step: 1) {
    
            }
//            .onChange(of: lowerIndexTerm) { newTerm in
//                let noOfPeriods: Int = newTerm / (12 / self.myLease.paymentsPerYear.rawValue)
//                self.eboDate = self.myLease.getExerciseDate(term: noOfPeriods)
//                self.basisPoints = 0.0
//            }
        }
        .font(.subheadline)
    }
    
    var lowerBoundYieldItem: some View {
        HStack{
            Text("yield:")
                .font(.subheadline)
            Spacer()
            ZStack(alignment: .trailing) {
                TextField("",
                          text: $lowerBoundIndexYield,
                          onEditingChanged: { (editing) in
                    if editing == true {
                        self.editRateStarted = true
                }})
                    .onSubmit {
                        self.editRateStarted = false
                        if isInterestRateValid(strRate: lowerBoundIndexYield, decLow: 0.0, decHigh: 0.20, inclusiveLow: false, inclusiveHigh: true) == false {
                            self.alertTitle = "A valid interest rate must be a decimal that is greater than 0.00 and less than 0.20!!!"
                            self.showAlert.toggle()
        
                        } else {
                           
                        }
                       
                    }
                    .keyboardType(.numbersAndPunctuation).foregroundColor(.clear)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                    .accentColor(.clear)
                Text("\((lowerRateFormatted(editStarted: editRateStarted)))")
                    .font(.subheadline)
            }
        }
    }
    
    var upperBoundIndexTermItem: some View {
        HStack {
            Text("tenor: \(upperBoundIndexTerm) year")
                .font(.subheadline)
            Stepper(value: $upperBoundIndexTerm, in: rangeOfIndexTerms(), step: 1) {
    
            }
        }
        .font(.subheadline)
        
    }
    
    var upperBoundIndexYieldItem: some View {
        HStack{
            Text("yield:")
                .font(.subheadline)
            Spacer()
            ZStack(alignment: .trailing) {
                TextField("",
                          text: $upperBoundIndexYield,
                          onEditingChanged: { (editing) in
                    if editing == true {
                        self.editRateStarted = true
                }})
                    .onSubmit {
                        self.editRateStarted = false
                        if isInterestRateValid(strRate: upperBoundIndexYield, decLow: 0.0, decHigh: 0.20, inclusiveLow: false, inclusiveHigh: true) == false {
                            self.alertTitle = "A valid interest rate must be a decimal that is greater than 0.00 and less than 0.20!!!"
                            self.showAlert.toggle()
        
                        } else {
                           
                        }
                       
                    }
                    .keyboardType(.numbersAndPunctuation).foregroundColor(.clear)
                    .textFieldStyle(PlainTextFieldStyle())
                    .disableAutocorrection(true)
                    .accentColor(.clear)
                Text("\((upperRateFormatted(editStarted: editRateStarted)))")
                    .font(.subheadline)
            }
        }
    }
    
    func rangeOfIndexTerms() -> ClosedRange<Int> {
        let start: Int = 1
        let end: Int = 20
        
        return start...end
    }
    
    func lowerRateFormatted (editStarted: Bool) -> String {
        if editStarted == true {
            return lowerBoundIndexYield
        } else {
            return lowerBoundIndexYield.toDecimal().toPercent(3)
        }
    }
    
    func upperRateFormatted(editStarted: Bool) -> String {
        if editStarted == true {
            return upperBoundIndexYield
        } else {
            return upperBoundIndexYield.toDecimal().toPercent(3)
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
        .onTapGesture {
           
        }
    }
    
    var cancelButtonRow: some View {
        Button(action: {}) {
            Text("Cancel")
                .font(.subheadline)
        }
        .multilineTextAlignment(.trailing)
        .onTapGesture {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func getAlert() -> Alert{
        return Alert(title: Text(alertTitle))
    }

}

struct IndexView_Previews: PreviewProvider {
    static var previews: some View {
        IndexView(myLease: Lease(aDate: today()), isDark: .constant(false))
    }
}
