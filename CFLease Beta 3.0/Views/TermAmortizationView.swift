//
//  TermAmortizationView.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 1/17/22.
//

import SwiftUI

struct TermAmortizationView: View {
    @ObservedObject var myLease: Lease
    @Binding var endingBalance: String
    @Environment(\.presentationMode) var presentationMode
    @State var amortTerm: Int = 120
    @Binding var isDark: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section (header: Text("Input Amortization Term").font(.footnote)){
                    amortizationTermStepper
                }
                Section (header: Text("Submit Form").font(.footnote)) {
                   submitFormItem
                }
                
            }
            .navigationTitle("Structure Input")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
    }
    
    var amortizationTermStepper: some View {
        VStack {
            Text("Select Amortization Term")
                .font(.subheadline)
            Stepper("Term in mons: \(amortTerm)", value: $amortTerm, in: 60...180, step: 12)
                .font(.subheadline)
        }
    }
    
    var submitFormItem: some View {
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
        .multilineTextAlignment(.trailing)
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
        .onTapGesture {
            self.myLease.groups.termAmortization(aLease: self.myLease, amortTerm: self.amortTerm)
            self.endingBalance = self.myLease.getEndingBalance().toString(decPlaces: 5)
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct TermAmortizationView_Previews: PreviewProvider {
    static var previews: some View {
        TermAmortizationView(myLease: Lease(aDate: today()), endingBalance: .constant("0.00"), isDark: .constant(false))
            .preferredColorScheme(.light)
    }
}


extension TermAmortizationView {
    func getMinTerm() -> Int {
        let minTerm: Int = myLease.getBaseTermInMons() + 12
        
        return minTerm
    }
}
