//
//  LeaseBalanceView.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 4/2/22.
//

import SwiftUI

struct LeaseBalanceView: View {
    @ObservedObject var myLease: Lease
    @Binding var isDark: Bool
    @Environment(\.presentationMode) var presentationMode
    
    @State private var asOfDate: Date = today()
    @State private var currDate: Date = today()
    @State private var principal: Decimal = 1000.00
    @State private var interest: Decimal = 0.00
    @State private var totalOut: Decimal = 165.00
    @State private var perDiem: Decimal = 0.00
    @State private var days: Int = 0
    
    @State var paymentDates: Cashflows = Cashflows()
    @State var showPopover: Bool = false
    @State var balanceHelp = leaseBalanceHelp
   
    var body: some View {
        NavigationView {
            Form{
                Section (header: Text("Effective Date").font(.footnote)) {
                    asOfDateItem
                    principalOutItem
                    daysOfInterestItem
                    perDiemItem
                    accruedInterestItem
                    totalOutItem
                }
                Section (header: Text("Submit Form").font(.footnote)) {
                   submitFormItem
                }
            }
            .navigationTitle("Outstanding Balance").font(.body).foregroundColor(isDark ? .white : .black)
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
        }
        .onAppear {
            self.paymentDates = Cashflows(aLease: self.myLease)
            self.paymentDates.consolidateCashflows()
            
            if modificationDate == "01/01/1900" {
                self.asOfDate = self.myLease.fundingDate
                self.principal = self.paymentDates.items[0].amount * -1.0
                self.perDiem = getDailyInterest(newDate: self.myLease.fundingDate)
                self.days = getNumberOfDays(newDate: self.myLease.fundingDate)
                
            } else {
                self.asOfDate = stringToDate(strAskDate: modificationDate)
                self.principal = getPrincipalBalance(newDate: self.asOfDate)
                self.interest = getInterest(newDate: self.asOfDate)
                self.perDiem = getDailyInterest(newDate: self.asOfDate)
                self.days = getNumberOfDays(newDate: self.asOfDate)
            }
        }
        
    }
    
    var asOfDateItem: some View {
        HStack {
            Text("as of date:")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover = true
                }
            Spacer()
            DatePicker("", selection: $asOfDate, in: asOfDates, displayedComponents:[.date])
                .transformEffect(.init(scaleX: 1.0, y: 0.9))
                .onChange(of: asOfDate, perform: { value in
                    self.principal = getPrincipalBalance(newDate: value)
                    self.interest = getInterest(newDate: value)
                    self.perDiem = getDailyInterest(newDate: value)
                    self.days = getNumberOfDays(newDate: value)
                })
            
        }
        .popover(isPresented: $showPopover) {
            PopoverView(myHelp: $balanceHelp, isDark: $isDark)
        }
    }
    
    var asOfDates: ClosedRange<Date> {
        let startDate: Date = myLease.fundingDate
        let endDate: Date = myLease.getMaturityDate()
      
        return startDate...endDate
    }
    
    var principalOutItem: some View {
        HStack {
            Text("principal out:")
                .font(.subheadline)
            Spacer()
            Text("\(principal.toCurrency(false))")
                .font(.subheadline)
        }
    }
    
    var accruedInterestItem: some View {
        HStack {
            Text("accrued interest:")
                .font(.subheadline)
            Spacer()
            Text("\(interest.toCurrency(false))")
                .font(.subheadline)
        }
    }
    
    var totalOutItem: some View {
        HStack {
            Text("total balance:")
                .font(.subheadline)
            Spacer()
            Text("\(getTotalOutstanding().toCurrency(false))")
                .font(.subheadline)
        }
    }
    
    var daysOfInterestItem: some View {
        HStack {
            Text("days of interest:")
                .font(.subheadline)
            Spacer()
            Text("\(days.toString())")
                .font(.subheadline)
        }
    }
    
    var perDiemItem: some View {
        HStack {
            Text("per diem:")
                .font(.subheadline)
            Spacer()
            Text("\(perDiem.toCurrency(false))")
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
                .foregroundColor(Color.theme.accent)
        }
        .multilineTextAlignment(.leading)
        .onTapGesture {
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
            modificationDate = dateToString(dateAsk: self.asOfDate)
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func getTotalOutstanding () -> Decimal {
        return principal + interest
    }
    
    func getPrincipalBalance(newDate: Date) -> Decimal {
        let myCashflow: Cashflow = paymentDates.vLookup(dateAsk: newDate, returnNextOnMatch: true)
        self.currDate = myCashflow.dueDate
        
        return self.myLease.getParValue(askDate: self.currDate, rentDueIsPaid: true)
    }
    
    func getInterest(newDate: Date) -> Decimal {
        return getAccruedInterest(aLease: self.myLease, principalBalance: self.principal, startDate: self.currDate, endDate: newDate)
    }
    
    func getDailyInterest(newDate: Date) -> Decimal {
        let daily:Decimal = getPerDiem(aLease: self.myLease, askDate: newDate)
        
        return daily
    }
    
    func getNumberOfDays(newDate: Date) -> Int {
        let idx = paymentDates.getIndex(dateAsk: newDate, returnNextOnMatch: true)
        let aDate: Date = paymentDates.items[idx].dueDate
        let noOfDays: Int = dayCount(aDate1: aDate, aDate2: newDate, aDaycount: myLease.interestCalcMethod)
        
        return noOfDays
    }
    
}

struct LeaseBalanceView_Previews: PreviewProvider {
    static var previews: some View {
        LeaseBalanceView(myLease: Lease(aDate: today()), isDark: .constant(false))
    }
}
