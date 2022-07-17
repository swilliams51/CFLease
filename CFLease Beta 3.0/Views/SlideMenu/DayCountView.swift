//
//  DayCountView.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/5/21.
//

import SwiftUI

struct DayCountView: View {
    @ObservedObject var myLease: Lease
    @State private var interestCalcMethod: DayCountMethod = .Thirty_ThreeSixty_ConvUS
    @Binding var endingBalance: String
    @Binding var showMenu: Bool
    @Binding var isDark: Bool
    
    @Environment(\.presentationMode) var presentationMode
    @State private var endOfMonthRule: Bool = false
    @State var showPopover: Bool = false
    @State var myEOMRule = eomRuleHelp
   
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Interest Calculation Options").font(.footnote)) {
                    pickerDayCountItem
                    eomRuleToggleItem
                    }
                Section(header: Text("Submit Form").font(.footnote)) {
                    submitFormItem
                }
                }
            
            .navigationTitle("Day Count Methods").font(.body).foregroundColor(isDark ? .white : .black)
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .onAppear{
            interestCalcMethod = myLease.interestCalcMethod
            endOfMonthRule = myLease.endOfMonthRule
            }
        .popover(isPresented: $showPopover) {
            PopoverView(myHelp: $myEOMRule, isDark: $isDark)
        }
    }
    
    var pickerDayCountItem: some View {
        Picker(selection: $interestCalcMethod, label: Text("day count method:").font(.subheadline)) {
            ForEach(DayCountMethod.dayCountMethods, id: \.self) { dayCountMehtod in
                Text(dayCountMehtod.toString())
            }
            .font(.subheadline)
            .onChange(of: interestCalcMethod, perform: { value in
            })
        }
    }
    
    var eomRuleToggleItem: some View {
        HStack {
            Text("end of month rule")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover = true
                }
            Spacer()
            Toggle("", isOn: $endOfMonthRule)
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
                .foregroundColor(Color.theme.accent)
        }
        .multilineTextAlignment(.trailing)
        .onTapGesture {
            self.showMenu.toggle()
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    var doneButtonItem: some View {
        Button(action: {}) {
            Text("Done")
                .font(.subheadline)
                .foregroundColor(Color.theme.accent)
        }
        .multilineTextAlignment(.trailing)
        .onTapGesture {
            self.myLease.interestCalcMethod = self.interestCalcMethod
            self.myLease.endOfMonthRule = self.endOfMonthRule
            self.showMenu.toggle()
            self.endingBalance = self.myLease.getEndingBalance().toString(decPlaces: 5)
            self.presentationMode.wrappedValue.dismiss()
        }
    }
        
}

struct DayCountView_Previews: PreviewProvider {
    static var previews: some View {
        DayCountView(myLease: Lease(aDate: Date()), endingBalance: .constant("0.00"), showMenu: .constant(true), isDark: .constant(false))
            .preferredColorScheme(.light)
    }
}
