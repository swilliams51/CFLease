//
//  DayCountReport.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 1/6/22.
//

import SwiftUI

struct DayCountReport: View {
    @ObservedObject var myLease: Lease
    @Binding var currentFile: String
    @Binding var isDark: Bool
    @Binding var isPad: Bool
    
    @State private var myFont: Font = reportFontSmall
    @State private var maxChars: Int = reportWidthSmall
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(textForDayCount(aLease: myLease, currentFile: currentFile, maxChars: maxChars))
                    .font(self.myFont)
                    .foregroundColor(isDark ? .white : .black)
                    .textSelection(.enabled)
            }
            .navigationTitle("Day Count")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
           
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .onAppear {
            if self.isPad == true {
                self.myFont = reportFontTiny
                self.maxChars = reportWidthTiny
            }
        }
    }
}

struct DayCountReport_Previews: PreviewProvider {
    static var previews: some View {
        DayCountReport(myLease: Lease(aDate: Date()), currentFile: .constant("file is new"), isDark: .constant(false), isPad: .constant(false))
            .preferredColorScheme(.light)
    }
}
