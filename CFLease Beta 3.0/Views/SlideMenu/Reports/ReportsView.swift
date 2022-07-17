//
//  ReportsView.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/10/21.
//

import SwiftUI

struct ReportsView: View {
    @ObservedObject var myLease: Lease
    @Binding var showMenu: Bool
    @Binding var currentFile: String
    @Binding var isDark: Bool
    @Binding var isPad: Bool
    
    @State var investorLinkIsActive: Bool = false
    @State var customerLinkIsActive: Bool = false
    @State var leaseBalanceIsActive: Bool = false
    
    var body: some View {
        NavigationView{
                List {
                    investorSummaryItemNoCursor
                    amortizationReportsItem
                    averageLifeReportItem
                    cashflowReportItem
                    daycountReportItem
                    customerSummaryItemNoCursor
                    presentValueRentReportItem
                    terminationValuesReportItem
                    leaseBalanceReportItem
                }
                .navigationTitle("Lease Reports")
                .navigationBarTitleDisplayMode(.inline)
                .navigationViewStyle(.stack)
            }
        
        .environment(\.colorScheme, isDark ? .dark : .light)
        .onAppear{
            if modificationDate != "01/01/1900" {
                leaseBalanceIsActive = true
            }
        }
        .onDisappear{
            self.showMenu.toggle()
        
        }
    }
    
    
    var investorSummaryItemNoCursor: some View {
        NavigationLink(destination: SummaryReport(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
            Text("Investor Summary")
                .font(.subheadline)
        }
    }
    
    var amortizationReportsItem: some View {
        NavigationLink(destination: AmortizationReportsView(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
            Text("Amortization Reports")
                .font(.subheadline)
        }
    }
    
    var averageLifeReportItem: some View {
        NavigationLink(destination: AverageLifeReport(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
            Text("Average Life")
                .font(.subheadline)
        }
    }
    
    var cashflowReportItem: some View {
        NavigationLink(destination: CashflowReport(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
            Text("Cashflow")
                .font(.subheadline)
        }
    }
    
    var daycountReportItem: some View {
        NavigationLink(destination: DayCountReport(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
            Text("Day Count")
                .font(.subheadline)
        }
    }
    
    var customerSummaryItemNoCursor: some View {
        NavigationLink(destination: CustomerReport(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
            Text("Customer Report")
                .font(.subheadline)
        }
    }
    
    var presentValueRentReportItem: some View {
        NavigationLink(destination: PVOfRentsProof(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
            Text("PV Proof of Minimum Rents")
                .font(.subheadline)
        }.disabled(myLease.isTrueLease() ? false : true )
    }
    
    var terminationValuesReportItem: some View {
        NavigationLink(destination: TValuesReport(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
            Text("Termination Values")
                .font(.subheadline)
        }.disabled(myLease.terminationsExist() ? false : true)
    }
    
    var leaseBalanceReportItem: some View {
        NavigationLink(destination: LeaseBalanceReport(myLease: myLease, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
            Text("Lease Balance Report")
                .font(.subheadline)
        }.disabled(leaseBalanceIsActive ? false : true)
        
    }
    
}

struct ReportsView_Previews: PreviewProvider {
    static var previews: some View {
        ReportsView(myLease: Lease(aDate: today()), showMenu: .constant(false), currentFile: .constant("file is new"), isDark: .constant(false), isPad: .constant(false))
            .preferredColorScheme(.light)
    }
}

struct ReportMenuItemView: View {

    let fontSize: CGFloat
    let textMenu: String
    let menuImage: String
    
    var body: some View {
            HStack {
                Image(systemName: menuImage)
                    .imageScale(.medium)
                    .foregroundColor(.white)
                Text (textMenu)
                    .foregroundColor(.white)
                    .font(.subheadline)
            }
        }
}







