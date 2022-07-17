//
//  EBOAmortizationsRpt.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 1/11/22.
//

import SwiftUI

//struct EBOAmortizationsReport: View {
//    @ObservedObject var myLease: Lease
//    @Binding var currentFile: String
//
//    @State private var combineDates: Bool = false
//    @State private var combineDatesLabel: String = "Combine Dates off"
//    @State private var combineDatesImage: String = "checkmark.square"
//    @Binding var isDark: Bool
//
//    var body: some View {
//        GeometryReader { geometry in
//            NavigationView {
//                ScrollView(.vertical, showsIndicators: false) {
//                    Text(textForOneAmortizations(aAmount: myLease.amount.toDecimal(), aAmortizations: myLease.amortizations, interestRate: myLease.interestRate, dayCountMethod: myLease.interestCalcMethod, currentFile: currentFile))
//                        .font(Font.system(.caption2, design: .monospaced))
//                        .foregroundColor(isDark ? .white : .black)
//                }
//                .navigationTitle("EBO Amortization")
//                .navigationBarTitleDisplayMode(.inline)
//                .navigationViewStyle(.stack)
//                .toolbar {
//                    Menu("+") {
//                        Button(action: {
//                            if combineDates == false {
//                                combineDates = true
//                                combineDatesLabel = "Combine Dates Off"
//                                combineDatesImage = "square"
//                                myLease.amortizations.items.removeAll()
//                                myLease.setAmortizationsFromCashflow()
//                            } else {
//                                combineDates = false
//                                combineDatesLabel = "Combine Dates On"
//                                combineDatesImage = "checkmark.square"
//                                myLease.amortizations.items.removeAll()
//                                myLease.setAmortizationsFromLease()
//                            }
//                        }) {
//                            Label(combineDatesLabel, systemImage: combineDatesImage)
//                        }
//                    }
//
//                }
//            }
//            .environment(\.colorScheme, isDark ? .dark : .light)
//            .onAppear{
//                myLease.setAmortizationsFromLease()
//                print(geometry.size.width)
//            }
//            .onDisappear {
//                myLease.amortizations.items.removeAll()
//            }
//
//        }
//    }
//
//}
//
//struct EBOAmortizationsRpt_Previews: PreviewProvider {
//    static var previews: some View {
//        EBOAmortizationsReport(myLease: Lease(aDate: today()), currentFile: .constant("file is new"), isDark: .constant(false))
//            .preferredColorScheme(.light)
//    }
//}
