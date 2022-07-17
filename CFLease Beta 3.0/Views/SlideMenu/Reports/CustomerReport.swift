//
//  EarlyBuyoutView.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/13/21.
//

import SwiftUI

struct CustomerReport: View {
    @ObservedObject var myLease: Lease
    @Binding var currentFile: String
    @Binding var isDark: Bool
    @Binding var isPad: Bool
    
    @State private var includeInterestRate: Bool = true
    @State private var inclInterestRateLabel: String = "Exclude Interest Rate"
    @State private var inclInterestRateImage: String = "square"
    @State var maxChars: Int = reportWidthSmall
    @State var myFont: Font = reportFontSmall
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(textForCustomerReport(aLease: myLease, currentFile: currentFile, includeRate: includeInterestRate, maxChars: maxChars))
                    .font(self.myFont)
                    .foregroundColor(isDark ? .white : .black)
                    .textSelection(.enabled)
            }
            .navigationTitle("Customer Report")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            .toolbar {
                Menu("+") {
                    Button(action: {
                        if self.includeInterestRate == false {
                            self.includeInterestRate = true
                            self.inclInterestRateImage = "square"
                        } else {
                            self.includeInterestRate = false
                            self.inclInterestRateImage = "checkmark.square"
                          
                        }
                    }) {
                        Label(inclInterestRateLabel, systemImage: inclInterestRateImage)
                    }
                }
            }//
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .onAppear {
            if self.isPad == true {
                self.maxChars = reportWidthTiny
                self.myFont = reportFontTiny
            }
        }
    }
}

struct CustomerReport_Previews: PreviewProvider {
    static var previews: some View {
        CustomerReport(myLease: Lease(aDate: today()), currentFile: .constant("file is new"), isDark: .constant(false), isPad: .constant(false))
            .preferredColorScheme(.light)
    }
}
