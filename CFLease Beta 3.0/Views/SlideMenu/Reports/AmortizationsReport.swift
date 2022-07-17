//
//  AmortizationsView.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/10/21.
//

import SwiftUI

struct AmortizationsReport: View {
    @ObservedObject var myLease: Lease
    @Binding var currentFile: String
    @Binding var reportTitle: String
    @Binding var isDark: Bool
    @Binding var isPad: Bool
    
    @State private var leaseCashFlows: Cashflows = Cashflows()
    @State private var leaseAmortizations: Amortizations = Amortizations()
    @State private var discountRate: Decimal = 0.10
    @State private var dayCountMethod: DayCountMethod = .Actual_Actual

    @State private var combineDates: Bool = false
    @State private var combineDatesLabel: String = "Combine Dates Off"
    @State private var combineDatesImage: String = "square"
    
    @State private var buyerPaidFee: Bool = false
    @State private var buyerPaidFeeAdded: Bool = false
    @State private var includeBuyerPaidFee: Bool = false
    @State private var includeBuyerPaidFeeLabel: String = "Incl Buyer Paid Fee"
    @State private var includeBuyerPaidFeeImage: String = "square"
    
    @State private var lesseePaidFee: Bool = false
    @State private var lesseePaidFeeAdded: Bool = false
    @State private var includeLesseeFee: Bool = false
    @State private var includeLesseeFeeLabel: String = "Incl Lessee Paid Fee"
    @State private var includeLesseeFeeImage: String = "square"
    
    @State private var toolBarMenuActive: Bool = true
    @State private var myFont: Font = reportFontSmall
    @State private var maxChars: Int = reportWidthSmall
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ScrollView(.vertical, showsIndicators: false) {
                    Text(textForOneAmortizations(aAmount: myLease.amount.toDecimal(), aAmortizations: leaseAmortizations, interestRate: discountRate.toString(decPlaces: 6), dayCountMethod: dayCountMethod, currentFile: currentFile, maxChars: maxChars))
                        .font(self.myFont)
                        .foregroundColor(isDark ? .white : .black)
                        .textSelection(.enabled)
                }
                
                .navigationBarTitleDisplayMode(.inline)
                .navigationViewStyle(.stack)
                .navigationTitle(reportTitle)
                .toolbar {
                    Menu("+") {
                        combineDatesButtonItem
                        buyerPaidFeeButtonItem
                            .disabled(buyerPaidFee ? false : true)
                        lesseePaidFeeButtonItem
                            .disabled(lesseePaidFee ? false : true)
                        
                    }
                    .disabled(toolBarMenuActive ? false : true)
                    .foregroundColor(toolBarMenuActive ? .red : .black)
                }
            }
            .environment(\.colorScheme, isDark ? .dark : .light)
            .onAppear{
                if self.reportTitle == "Lease Balance Amortization" {
                    self.toolBarMenuActive = false
                }
                
                if myLease.lesseePaidFee.toDecimal() > 0.0 {
                    self.lesseePaidFee = true
                }
                
                if myLease.purchaseFee.toDecimal() > 0.0 {
                    self.buyerPaidFee = true
                }
                
                self.dayCountMethod = myLease.interestCalcMethod
                self.leaseCashFlows = Cashflows(aLease: self.myLease)
                self.discountRate = self.leaseCashFlows.XIRR(guessRate: 0.10, _DayCountMethod: self.dayCountMethod)
                self.leaseAmortizations = setAmortizationsFromCashflow(aCashflows: self.leaseCashFlows, decAnnualRate: self.discountRate, aDayCount: self.dayCountMethod)
                
                if self.isPad == true {
                    self.myFont = reportFontTiny
                    self.maxChars = reportWidthTiny
                }
            }
            .onDisappear {
                self.myLease.amortizations.items.removeAll()
            }

        }
       
    }
    var combineDatesButtonItem: some View {
        Button(action: {
            if self.combineDates == false {
                self.combineDates = true
                self.combineDatesLabel = "Combine Dates On"
                self.combineDatesImage = "checkmark.square"
                self.consolidateLeaseCashflow()
            } else {
                self.combineDates = false
                self.combineDatesLabel = "Combine Dates Off"
                self.combineDatesImage = "square"
                self.resetLeaseCashflows()
            }
        }) {
            HStack {
                Text(combineDatesLabel)
                Image(systemName: combineDatesImage)
            }
        }
    }
    
    var buyerPaidFeeButtonItem: some View {
        Button(action: {
          if self.includeBuyerPaidFee == false {
              self.includeBuyerPaidFee = true
              self.includeBuyerPaidFeeImage = "checkmark.square"
              self.addBuyerPaidFee()
          } else {
              self.includeBuyerPaidFee = false
              self.includeBuyerPaidFeeImage = "square"
              self.removeBuyerPaidFee()
          }
      }) {
          HStack {
              Text(includeBuyerPaidFeeLabel)
              Image(systemName: includeBuyerPaidFeeImage)
          }
          }
    }
    
    var lesseePaidFeeButtonItem: some View {
      Button(action: {
        if self.includeLesseeFee == false {
            self.includeLesseeFee = true
            self.includeLesseeFeeImage = "checkmark.square"
            self.addLesseeFee()
        } else {
            self.includeLesseeFee = false
            self.includeLesseeFeeImage = "square"
            self.removeLesseeFee()
        }
    }) {
        HStack {
            Text(includeLesseeFeeLabel)
            Image(systemName: includeLesseeFeeImage)
        }
        }
    }
    
    func addBuyerPaidFee() {
        let decAmount:Decimal = myLease.purchaseFee.toDecimal() * -1.0
        let dateDue: Date = myLease.fundingDate
        let myCF: Cashflow = Cashflow(due: dateDue, amt: decAmount)
        self.leaseCashFlows.items.insert(myCF, at: 1)
        self.calculateLeaseAmortizations()
        self.buyerPaidFeeAdded = true
    }
    
    func removeBuyerPaidFee() {
        let idx = indexOfRemoved(lesseeFeeIsAsking: false)
        self.leaseCashFlows.items.remove(at: idx)
        self.calculateLeaseAmortizations()
        self.lesseePaidFeeAdded = false
    }
    
    func addLesseeFee() {
        let decAmount: Decimal = myLease.lesseePaidFee.toDecimal()
        let dateDue: Date = myLease.fundingDate
        let myCF:Cashflow = Cashflow(due: dateDue, amt: decAmount)
        self.leaseCashFlows.items.insert(myCF, at: 1)
        self.calculateLeaseAmortizations()
        self.lesseePaidFeeAdded = true
    }
    
    func removeLesseeFee() {
        let idx = indexOfRemoved(lesseeFeeIsAsking: true)
        self.leaseCashFlows.items.remove(at: idx)
        self.calculateLeaseAmortizations()
        self.lesseePaidFeeAdded = false
    }
    
    func indexOfRemoved(lesseeFeeIsAsking: Bool) -> Int {
        if lesseePaidFeeAdded == true && buyerPaidFeeAdded == false {
            return 1
        }
        if lesseePaidFeeAdded == false && buyerPaidFeeAdded == true {
            return 1
        }
        if lesseePaidFeeAdded == true && buyerPaidFeeAdded == true {
            if lesseeFeeIsAsking == true {
                if leaseCashFlows.items[1].amount > 0.0 {
                    return 1
                } else {
                    return 2
                }
            } else {
                if leaseCashFlows.items[1].amount < 0.0 {
                    return 1
                } else {
                    return 2
                }
            }
        }
        return 0
    }
   
    func consolidateLeaseCashflow() {
        self.leaseCashFlows.consolidateCashflows()
        calculateLeaseAmortizations()
    }
    
    func resetLeaseCashflows() {
        self.leaseCashFlows.items.removeAll()
        self.leaseCashFlows = Cashflows(aLease: self.myLease)
        if self.includeBuyerPaidFee == true {
            addBuyerPaidFee()
        }
        if self.lesseePaidFeeAdded == true {
            addLesseeFee()
        }
    }
    
    func calculateLeaseAmortizations() {
        self.leaseAmortizations.items.removeAll()
        self.discountRate = leaseCashFlows.XIRR(guessRate: 0.10, _DayCountMethod: self.dayCountMethod)
        self.leaseAmortizations = setAmortizationsFromCashflow(aCashflows: self.leaseCashFlows, decAnnualRate: self.discountRate, aDayCount: self.dayCountMethod)
    }
    
}

struct AmortizationsView_Previews: PreviewProvider {
    
    static var previews: some View {
        AmortizationsReport(myLease: Lease(aDate: today()),currentFile: .constant("file is new"), reportTitle: .constant("Report Title"), isDark: .constant(false), isPad: .constant(false))
            .preferredColorScheme(.light)
    }
}

