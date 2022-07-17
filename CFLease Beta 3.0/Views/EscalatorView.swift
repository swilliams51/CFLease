//
//  EscalatorView.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 1/17/22.
//

import SwiftUI

struct EscalatorView: View {
    @ObservedObject var myLease: Lease
    @Binding var endingBalance: String
    @Environment(\.presentationMode) var presentationMode
    @State var escalator: Double = 50.0
    @State var showPopover: Bool = false
    @State var escalateHelp = escalationRateHelp
    @Binding var isDark: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section (header: Text("Input Escalation Rate").font(.footnote)){
                    escalationRateSliderItem
                }
                Section (header: Text("Submit Form").font(.footnote)) {
                    submitFormItem
                }
                
            }
            .navigationTitle("Escalation Structure")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
    }
    
    var escalationRateSliderItem: some View {
        VStack {
            HStack {
                Text("escalation rate:")
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                Image(systemName: "questionmark.circle")
                    .foregroundColor(Color.theme.accent)
                    .onTapGesture {
                        self.showPopover = true
                    }
                Spacer()
                Text("\(formatEscalator())")
                    .font(.subheadline)
                    .multilineTextAlignment(.trailing)
            }
            .popover(isPresented: $showPopover) {
                PopoverView(myHelp: $escalateHelp, isDark: $isDark)
            }
            
            Slider(value: $escalator, in: 0...100, step: 1) {
            
            }.font(.subheadline)
        }
    }
    
    var submitFormItem:some View {
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
            self.myLease.groups.escalate(aLease: myLease, inflationRate: Decimal(escalator))
            self.endingBalance = self.myLease.getEndingBalance().toString(decPlaces: 5)
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
}

struct EscalatorView_Previews: PreviewProvider {
    static var previews: some View {
        EscalatorView(myLease: Lease(aDate: today()), endingBalance: .constant("0.00"), isDark: .constant(false))
            .preferredColorScheme(.light)
    }
}

extension EscalatorView {
    func formatEscalator() -> String{
        let dblRate:Double = self.escalator / 1000
        let decRate: Decimal = Decimal(dblRate)
        
        return decRate.toPercent(2)
    }
}
