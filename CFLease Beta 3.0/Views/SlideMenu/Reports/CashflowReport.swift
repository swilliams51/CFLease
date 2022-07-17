//
//  CashflowReport.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 2/23/22.
//

import SwiftUI

struct CashflowReport: View {
    @ObservedObject var myLease: Lease
    @Binding var currentFile: String
    @Binding var isDark: Bool
    @Binding var isPad: Bool
    
    @State var myCashflows: Cashflows = Cashflows()
    @State private var myFont: Font = reportFontSmall
    @State private var maxChars: Int = reportWidthSmall
    
    @State private var combineDatesLabel: String = "Combine Dates Off"
    @State private var combineDatesImage: String = "square"
    @State private var combineDates: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView (.vertical, showsIndicators: false) {
                Text(textForOneCashflow(aAmount: myLease.amount.toDecimal(), aCFs: myCashflows, currentFile: currentFile, maxChars: maxChars))
                    .font(self.myFont)
                    .foregroundColor(isDark ? .white : .black)
                    .textSelection(.enabled)
            }
            .navigationTitle("Cashflow")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            .toolbar{
                Menu("+") {
                    combineDatesButtonItem
                }
                .foregroundColor(.red)
            }
    
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .onAppear {
            self.myCashflows = self.myLease.getTotalCashflows()
            if self.isPad == true {
                self.myFont = reportFontTiny
                self.maxChars = reportWidthTiny
            }
            
        }
    }
    var combineDatesButtonItem: some View {
        Button(action: {
            if self.combineDates == false {
                self.combineDates = true
                self.combineDatesLabel = "Combine Dates On"
                self.combineDatesImage = "checkmark.square"
                self.myCashflows.consolidateCashflows()
            } else {
                self.combineDates = false
                self.combineDatesLabel = "Combine Dates Off"
                self.combineDatesImage = "square"
                self.myCashflows = self.myLease.getTotalCashflows()
            }
        }) {
            HStack {
                Text(combineDatesLabel)
                Image(systemName: combineDatesImage)
            }
        }
    }
    
}

struct CashflowReport_Previews: PreviewProvider {
    static var previews: some View {
        CashflowReport(myLease: Lease(aDate: today()), currentFile: .constant("file is new"), isDark: .constant(false), isPad: .constant(false))
    }
}
