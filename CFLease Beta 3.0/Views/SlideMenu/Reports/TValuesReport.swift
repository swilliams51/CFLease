//
//  TValuesInputsView.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/22/21.
//

import SwiftUI

struct TValuesReport: View {
    @ObservedObject var myLease: Lease
    @Binding var currentFile: String
    @Binding var isDark: Bool
    @Binding var isPad: Bool
    
    @State private var inLieuOfRentDue: Bool = true
    @State private var inLieuLabel: String = "In Lieu of Rent Due"
    @State private var inLieuImage: String = "square"
    
    @State private var includeParValues: Bool = true
    @State private var inclParValuesLabel: String = "Remove Par Values"
    @State private var inclParValueImage: String = "square"
    
    @State var maxChars: Int = reportWidthSmall
    @State var myFont: Font = reportFontSmall
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(textForTerminationValues(aLease: myLease, inLieuRent: inLieuOfRentDue, includeParValues: includeParValues, currentFile: currentFile, maxChars: maxChars))
                    .font(self.myFont)
                    .foregroundColor(isDark ? .white : .black)
                    .textSelection(.enabled)
            }
            .navigationTitle("Termination Values")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Section {
                            excludeParValuesOption
                            inLieuOfRentDueOption
                        }
                    }
                label: {
                    Label("Add", systemImage: "plus")
                }
                .font(self.myFont)
                }
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .onAppear{
            if self.isPad == true {
                self.myFont = reportFontTiny
                self.maxChars = reportWidthTiny
            }
            
        }
        
    }
    var excludeParValuesOption: some View {
        Button(action: {
            if self.includeParValues == false {
                self.includeParValues = true
                self.inclParValueImage = "square"
            } else {
                self.includeParValues = false
                self.inclParValueImage = "checkmark.square"

            }
        }) {
            Label(inclParValuesLabel, systemImage: inclParValueImage)
        }
        .font(self.myFont)
    }
    
    
    var inLieuOfRentDueOption: some View {
        Button(action: {
            if self.inLieuOfRentDue == false {
                self.inLieuOfRentDue = true
                self.inLieuImage = "square"
            } else {
                self.inLieuOfRentDue = false
                self.inLieuImage = "checkmark.square"

            }
        }) {
            Label(inLieuLabel, systemImage: inLieuImage)
        }
        .font(self.myFont)
    }
    
}

struct TValuesInputsView_Previews: PreviewProvider {
    static var previews: some View {
        TValuesReport(myLease: Lease(aDate: today()), currentFile: .constant("file is new"), isDark: .constant(false), isPad: .constant(false))
            .preferredColorScheme(.dark)
    }
}
