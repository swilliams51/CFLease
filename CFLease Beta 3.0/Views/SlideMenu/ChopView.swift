//
//  ChopView.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/1/21.
//

import SwiftUI

struct ChopView: View {
    @ObservedObject var myLease: Lease
    @Binding var endingBalance: String
    @Binding var selfIsNew: Bool
    @Binding var showMenu: Bool
    @State private var chopDate: Date = today()
    
    @State var showPopover: Bool = false
    @State var cutOff = cutOffHelp
    @Environment(\.presentationMode) var presentationMode
    @Binding var isDark: Bool
    
    var body: some View {
        NavigationView{
            Form{
                Section (header: Text("Effective Date").font(.footnote)) {
                  chopDatePickerItem
                }
                Section (header: Text("Submit Form").font(.footnote)) {
                   submitFormItem
                }
            }
            .navigationTitle("Cut-Off Lease").font(.body).foregroundColor(isDark ? .white : .black)
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
    }
        
    var chopDatePickerItem: some View {
        HStack {
            Text("cut-off date")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover = true
                }
            Spacer()
            DatePicker("", selection: $chopDate, in: chopDates, displayedComponents:[.date])
                .onChange(of: chopDate, perform: { value in
                    
                })
            
        }
        .popover(isPresented: $showPopover) {
            PopoverView(myHelp: $cutOff, isDark: $isDark)
        }
            
    }
    
    var chopDates: ClosedRange<Date> {
        var startDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: myLease.fundingDate)!
        let endDate: Date = Calendar.current.date(byAdding: .month, value: -12, to: myLease.getMaturityDate())!
        
        if startDate > endDate {
            startDate = endDate
        }
        
        return startDate...endDate
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
        .multilineTextAlignment(.leading)
        .onTapGesture {
            
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    var doneButtonItem: some View {
        Button(action: {}) {
            //update myLease.LesseeObligations with new parameters
            
            Text("Done")
                .font(.subheadline)
                .foregroundColor(Color.theme.accent)
        }
        .multilineTextAlignment(.trailing)
        .onTapGesture {
            self.myLease.resetLeaseToChop(modDate: self.chopDate)
            self.endingBalance = self.myLease.getEndingBalance().toCurrency(false)
            self.selfIsNew = true
            self.showMenu = false
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    
}

struct ChopView_Previews: PreviewProvider {
    static var previews: some View {
        ChopView(myLease: Lease(aDate: today()),endingBalance: .constant("0.00"), selfIsNew: .constant(true), showMenu: .constant(false), isDark: .constant(false))
            .preferredColorScheme(.light)
    }
}

