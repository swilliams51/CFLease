//
//  PaymentGroupsView.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/1/21.
//

import SwiftUI

import UIKit

struct GroupsView: View {
    @Binding var myGroups: Groups
    @ObservedObject var myLease: Lease
    @Binding var endingBalance: String
    @Binding var selfIsNew: Bool
    @Binding var menuIsActive: Bool
    @Binding var isDark: Bool
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("maxBaseTerm") var maxBaseTerm: Int = 120
    
    @State private var selectedGroup:Group? = nil
    @State private var isPresented: Bool = false
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
    @State var showActionSheet1: Bool = false
    @State var showActionSheet2: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Payment Groups")) {
                   fundingGroupRow
                    ForEach(myGroups.items) { group in
                        VStack {
                            HStack {
                                Text(groupToFirstText(aGroup: group))
                                    .font(.subheadline)
                                Spacer()
                                Button(action: {
                                    self.selectedGroup = group
                                }) {
                                   Text("Edit")
                                        .font(.subheadline)
                                } .disabled(selfIsNew ? true : false )
                                
                            }
                            HStack {
                                Text(groupToSecondText(aGroup: group))
                                    .font(.subheadline)
                                Spacer()
                                Text("place")
                                    .foregroundColor(.clear)
                            }
                        }
                    }
            
                }
                Section(header: Text("Totals")) {
                    totalsHeader
                    totalAmounts
                }
            }

        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    Section {
                        firstAndLast
                        firstAndLastTwo
                        lowHigh
                        highLow
                        termAmortization
                        escalation
                    }
                }
            label: {
                Label("Structure", systemImage: "gearshape")
            }
                .font(.footnote)
                .disabled(selfIsNew ? true : false )
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Section {
                        addDuplicateGroup
                        addBalloonGroup
                        addResidualGroup
                    }
                }
            label: {
                Label("Add", systemImage: "plus")
            }
                .font(.footnote)
                .disabled(selfIsNew ? true : false )
            }
        }
        .navigationTitle("Payment Schedule")
        .navigationBarTitleDisplayMode(.inline)
        .navigationViewStyle(.stack)
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .onAppear {
            self.menuIsActive = false
        }
        
        .fullScreenCover(item: $selectedGroup) { myGroup in
            OneGroupView(myGroup: myGroup, myGroups: myGroups, myLease: myLease, endingBalance: $endingBalance, isDark: $isDark)
        }
        .sheet(isPresented: $showActionSheet1, content:  { TermAmortizationView(myLease: myLease, endingBalance: $endingBalance, isDark: $isDark) })
        .sheet(isPresented: $showActionSheet2, content:  { EscalatorView(myLease: myLease, endingBalance: $endingBalance, isDark: $isDark) })
        .alert(isPresented: $showAlert, content: getAlert)
        .onDisappear {
            if abs(endingBalance.toDecimal()) < 0.75 {
                self.menuIsActive = true
            }
        }
    }
    
    var fundingGroupRow: some View {
        VStack {
            HStack {
                Text(fundingAmountToText())
                    .font(.subheadline)
                Spacer()
            }
            
            HStack {
                Text(fundingDateToText())
                    .font(.subheadline)
                Spacer()
            }
        }
    }
    
    func fundingAmountToText() -> String {
        let strAmount = "1 @ -\(myLease.amount.toDecimal().toCurrency(false))"
        let strFunding = strAmount + " Funding "
        return strFunding
    }
    
    func fundingDateToText() -> String {
        let strFundingDate: String = "\(myLease.fundingDate.toStringDateShort())"
        let strFundingDateRow: String = strFundingDate + " to " + strFundingDate
        let strFundingType: String = " Equals Unlocked"
        return strFundingDateRow + strFundingType
    }

    var totalsHeader: some View {
        HStack {
            Text("Number:")
                .font(.subheadline)
            Spacer()
            Text("Net Amount:")
                .font(.subheadline)
        }
    }
    
    var totalAmounts: some View {
        HStack {
            Text("\(myGroups.getTotalNoOfPayments() + 1)")
                .font(.subheadline)
            Spacer()
            Text("\(myLease.getNetAmount().toCurrency(false))")
                .font(.subheadline)
        }
    }
    
    var firstAndLast: some View {
        Button(action: {
            if self.myLease.groups.structureCanBeApplied(freq: myLease.paymentsPerYear) == false && balanceIsZero() == true {
                alertTitle = alertForStructureWarning()
                showAlert.toggle()
            } else {
                self.myLease.groups.firstAndLast(freq: myLease.paymentsPerYear, baseCommence: myLease.baseTermCommenceDate, EOMRule: myLease.endOfMonthRule)
                self.endingBalance = self.myLease.getEndingBalance().toString(decPlaces: 5)
            }
        }) {
            Label("1stAndLast", systemImage: "arrowshape.turn.up.backward")
                .font(.caption2)
        }
    }
    
    var firstAndLastTwo: some View {
        Button(action: {
            if self.myLease.groups.structureCanBeApplied(freq: myLease.paymentsPerYear) == false && balanceIsZero() == true {
                alertTitle = alertForStructureWarning()
                showAlert.toggle()
            } else {
                self.myLease.groups.firstAndLastTwo(freq: myLease.paymentsPerYear, baseCommence: myLease.baseTermCommenceDate, EOMRule: myLease.endOfMonthRule)
                self.endingBalance = self.myLease.getEndingBalance().toString(decPlaces: 5)
            }
        }) {
            Label("1stAndLastTwo", systemImage: "arrowshape.turn.up.backward.2")
                .font(.caption2)
        }
    }
    
    var lowHigh: some View {
        Button(action: {
            if self.myLease.groups.structureCanBeApplied(freq: myLease.paymentsPerYear) == false && balanceIsZero() == true {
                alertTitle = alertForStructureWarning()
                showAlert.toggle()
            } else {
                self.myLease.groups.unevenPayments(lowHigh: true, freq: myLease.paymentsPerYear, baseCommence: myLease.baseTermCommenceDate, EOMRule: myLease.endOfMonthRule)
                self.endingBalance = self.myLease.getEndingBalance().toString(decPlaces: 5)
            }
        }) {
            Label("Low-High", systemImage: "arrow.up.right")
                .font(.caption2)
        }
    }
    
    var highLow: some View {
        Button(action: {
            if self.myLease.groups.structureCanBeApplied(freq: myLease.paymentsPerYear) == false && balanceIsZero() == true {
                alertTitle = alertForStructureWarning()
                showAlert.toggle()
            } else {
                self.myLease.groups.unevenPayments(lowHigh: false, freq: myLease.paymentsPerYear, baseCommence: myLease.baseTermCommenceDate, EOMRule: myLease.endOfMonthRule)
                self.endingBalance = self.myLease.getEndingBalance().toString(decPlaces: 5)
            }
        }) {
            Label("High-Low", systemImage: "arrow.down.right")
                .font(.caption2)
        }
    }
    
    var termAmortization: some View {
        Button(action: {
            if self.myLease.groups.structureCanBeApplied(freq: myLease.paymentsPerYear) == false {
                alertTitle = alertForStructureWarning()
                showAlert.toggle()
            } else {
                self.showActionSheet1 = true
            }
               
        }) {
            Label("Term-Amortization", systemImage: "arrow.forward.to.line")
                .font(.caption2)
        }
    }
    
    var escalation: some View {
        Button(action: {
            if escalationCanBeApplied() == false {
                alertTitle = alertForStructureWarning()
                showAlert.toggle()
            } else {
                self.showActionSheet2 = true
            }
               
        }) {
            Label("Annual Escalator", systemImage: "arrow.up.right")
                .font(.caption2)
        }
    }
    
    
    var addDuplicateGroup: some View {
        Button(action: {
            if myGroups.residualGroupExists() == false {
                let lastIdx: Int = myGroups.items.count - 1
                var numberOfPayments = myGroups.items[lastIdx].noOfPayments
                let maxRemaining: Int = myLease.getMaxRemainNumberPayments(maxBaseTerm: maxBaseTerm, freq: self.myLease.paymentsPerYear, eom: self.myLease.endOfMonthRule, aRefer: self.myLease.firstAnniversaryDate)
                if maxRemaining > 0 {
                    if numberOfPayments > maxRemaining {
                        numberOfPayments = maxRemaining
                    }
                    self.myGroups.addDuplicateGroup(groupToCopy: myGroups.items[lastIdx], numberPayments: numberOfPayments)
                    self.myLease.resetRemainderOfGroups(startGrp: lastIdx + 1)
                    self.endingBalance = self.myLease.getEndingBalance().toString(decPlaces: 5)
                } else {
                    alertTitle = alertDuplicate2
                    showAlert.toggle()
                }
            } else {
                alertTitle = alertDuplicate
                showAlert.toggle()
            }
        }) {
            Label("Duplicate", systemImage: "doc.on.doc")
                .font(.caption2)
        }
    }
    
    var addResidualGroup: some View {
        Button(action: {
            if myGroups.residualGroupExists() == false {
                let lastIdx: Int = self.myGroups.items.count - 1
                self.myGroups.addResidualGroup(leaseAmount: myLease.amount)
                self.myLease.resetRemainderOfGroups(startGrp: lastIdx + 1)
                self.endingBalance = self.myLease.getEndingBalance().toString(decPlaces: 5)
            } else {
                alertTitle = alertResidual
                showAlert.toggle()
            }
        }) {
            Label("Residual", systemImage: "bag.badge.plus")
                .font(.caption2)
        }
    }
    
    var addBalloonGroup: some View {
        Button(action: {
            if myGroups.residualGroupExists() == false {
                let lastIdx: Int = self.myGroups.items.count - 1
                self.myGroups.addBalloonGroup(leaseAmount: myLease.amount)
                self.myLease.resetRemainderOfGroups(startGrp: lastIdx + 1)
                self.endingBalance = self.myLease.getEndingBalance().toString(decPlaces: 5)
            } else {
                alertTitle = alertResidual
                showAlert.toggle()
            }
        }) {
            Label("Balloon", systemImage: "plus.message")
                .font(.caption2)
        }
    }
    
   
    
}

struct GroupsView_Previews: PreviewProvider {
    static var myLease: Lease = Lease(aDate: today())
    
    static var previews: some View {
        GroupsView(myGroups: .constant(myLease.groups), myLease: Lease(aDate: today()), endingBalance: .constant("0.00"), selfIsNew: .constant(false), menuIsActive: .constant(false), isDark: .constant(false))
            .preferredColorScheme(.light)
    }
}

extension GroupsView {
    func getAlert() -> Alert{
        return Alert(title: Text(alertTitle))
    }
    
    func alertForStructureWarning() -> String {
        let strAlert = altertStructure
        return strAlert
    }
    
    func balanceIsZero() -> Bool {
        var isZero: Bool = false
        
        let balance: Decimal = endingBalance.toDecimal()
        menuIsActive = false
        if abs(balance) < 0.075 {
            menuIsActive = true
            isZero = true
        }
        return isZero
    }
    
    func escalationCanBeApplied () -> Bool {
        if self.myLease.groups.structureCanBeApplied(freq: myLease.paymentsPerYear) == false {
            return false
        }
        
        if balanceIsZero() == false {
           return false
        }
        
        if myLease.baseTermIsInWholeYears() == false {
            return false
        }
        
        return true
    }
    
    func removeGroup(at offsets: IndexSet) {
        self.myGroups.items.remove(atOffsets: offsets)
        self.myLease.resetRemainderOfGroups(startGrp: 1)
        self.endingBalance = self.myLease.getEndingBalance().toString(decPlaces: 5)
    }
}



func groupToFirstText(aGroup: Group) -> String {
    var strAmount: String = "Calculated"
    if aGroup.amount != "CALCULATED" {
        strAmount = aGroup.amount.toDecimal().toCurrency(false)
    }
   
    let strOne: String = "\(aGroup.noOfPayments) @ " + strAmount + " \(aGroup.type.toString()) "
    
    return strOne
}

func groupToSecondText (aGroup: Group) -> String {
    var strTiming: String = "Equals"
    if aGroup.timing == .advance {
        strTiming = "Advance"
    } else if aGroup.timing == .arrears {
        strTiming = "Arrears"
    }
    
    var strLocked: String = "Locked"
    if aGroup.locked == false {
        strLocked = "Unlocked"
    }
    
    let strStart: String = "\(aGroup.startDate.toStringDateShort())"
    let strEnd: String = "\(aGroup.endDate.toStringDateShort())"
    let strDate: String = strStart + " to " + strEnd
    
    
    let strTwo: String =   strDate + " " + strTiming + " " + strLocked
    return strTwo
}

let altertStructure: String = "A payment structure cannot be applied to a Lease with more than one payment group or when the endiing balance is not equal to 0.00!!"
let alertResidual: String = "A payment group cannot be added after a residual or balloon payment!!"
let alertDuplicate: String = "Only one residual or balloon payment group can exist in the collection!!"
let alertDuplicate2: String = "Maximum number of payments exceeded.  Group will not be added!!"

