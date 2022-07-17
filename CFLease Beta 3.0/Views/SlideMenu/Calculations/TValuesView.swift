//
//  TestView.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/21/21.
//

import SwiftUI

struct TValuesView: View {
    @ObservedObject var myLease: Lease
    @Binding var isDark: Bool
    @Environment(\.presentationMode) var presentationMode
    
    @State private var sliderThreeValue: Double = 0
    @State private var discountRateRent: String = "0.05"
    @State private var convertedValue: Double = 1000.00
    @State private var maxValue: Double = 200.00
    @State private var discountRateResidual: String = "0.05"
    @State private var convertedValue2: Double = 1000.00
    @State private var maxValue2: Double = 200.00
    @State private var additionalResidual: String = "0.00"
    @State private var factor: Decimal = 10000.00

    var body: some View {
        NavigationView{
            Form{
                Section(header: Text("Inputs").font(.footnote)) {
                    discountRateRentItem
                    discountRateResidualItem
                    additionalResidualItem
                }
                Section(header: Text("Submit Form").font(.footnote)) {
                    submitFormItem
                }
                
            }
            .navigationTitle("Termination Values")
            .navigationBarTitleDisplayMode(.inline)
            navigationViewStyle(.stack)
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .onAppear{
            self.discountRateRent = myLease.interestRate
            self.discountRateResidual = myLease.interestRate
            let myString = self.discountRateRent
            maxValue = myString.toDouble() / 0.0001
            convertedValue = myString.toDouble() / 0.0001
            
            let myString2 = self.discountRateResidual
            maxValue2 = myString2.toDouble() / 0.0001
            convertedValue2 = myString2.toDouble() / 0.0001
        }
    }
    
    var discountRateRentItem: some View {
        VStack {
            HStack {
                Text("discount rate for rent:")
                    .font(.subheadline)
                Spacer()
                Text("\(discountRateRent.toDecimal().toPercent(2))")
                    .font(.subheadline)
            }
            Slider(value: $convertedValue, in: 0...maxValue, step: 1) {
                
            }
            .transformEffect(.init(scaleX: 1.0, y: 0.9))
            .onChange(of: convertedValue, perform: { newNumber in
                let newValue: Decimal = (Decimal(newNumber)) * 0.0001
                self.discountRateRent = newValue.toString(decPlaces: 5)
            })
        
            Stepper("",onIncrement: {
                convertedValue = convertedValue + 1
            },onDecrement: {
                convertedValue = convertedValue - 1
            })
            .transformEffect(.init(scaleX: 1.0, y: 0.9))
        }
    }
    
    var discountRateResidualItem: some View {
        VStack {
            HStack {
                Text("discount rate for residual:")
                    .font(.subheadline)
                Spacer()
                Text("\(discountRateResidual.toDecimal().toPercent(2))")
                    .font(.subheadline)
            }
            Slider(value: $convertedValue2, in: 0...maxValue, step: 1) {
                
            }
            .transformEffect(.init(scaleX: 1.0, y: 0.9))
        
            .onChange(of: convertedValue2, perform: { newNumber in
                let newValue: Decimal = (Decimal(newNumber)) * 0.0001
                self.discountRateResidual = newValue.toString(decPlaces: 5)
            })
        
            Stepper("",onIncrement: {
                convertedValue2 = convertedValue2 + 1
            },onDecrement: {
                convertedValue2 = convertedValue2 - 1
            })
            .transformEffect(.init(scaleX: 1.0, y: 0.9))
        }
    }
    
    var additionalResidualItem: some View {
        VStack {
            HStack {
                Text("additional residual:")
                    .font((.subheadline))
                Spacer()
                Text("\(additionalResidual.toDecimal().toPercent(2))")
                    .font(.subheadline)
            }
            Slider(value: $sliderThreeValue, in: 0...20, step: 1) {
            }
            .disabled(myLease.isTrueLease() ? false : true )
            .onChange(of: sliderThreeValue, perform: { newNumber in
                additionalResidual = (newNumber / 100.0).toString()
            })
        }
        
    }
    
    var submitFormItem: some View {
        HStack {
            Button(action: {}) {
                Text("Cancel")
                    .font(.subheadline)
            }
            .multilineTextAlignment(.trailing)
            .onTapGesture {
                self.presentationMode.wrappedValue.dismiss()
            }
            Spacer()
            Button(action: {}) {
                Text("Done")
                    .font(.subheadline)
            }
            .multilineTextAlignment(.trailing)
            .onTapGesture {
                self.myLease.terminations!.discountRate_Rent = self.discountRateRent.toDecimal()
                self.myLease.terminations!.discountRate_Residual = self.discountRateResidual.toDecimal()
                self.myLease.terminations!.additionalResidual = self.additionalResidual.toDecimal()
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TValuesView(myLease: Lease(aDate: today()), isDark: .constant(false))
            .preferredColorScheme(.dark)
            
    }
}
