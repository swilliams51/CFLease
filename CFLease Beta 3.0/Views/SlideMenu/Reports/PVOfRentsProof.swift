//
//  PVOfRentsProof.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/31/21.
//

import SwiftUI

struct PVOfRentsProof: View {
    @ObservedObject var myLease: Lease
    @Binding var currentFile: String
    @Binding var isDark: Bool
    @Binding var isPad: Bool
    
    @State private var myFont: Font = reportFontSmall
    @State private var maxChars: Int = reportWidthSmall
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(textForPVOfRentProof(aLease: myLease, currentFile: currentFile, maxChars: maxChars))
                    .font(self.myFont)
                    .foregroundColor(isDark ? .white : .black)
                    .textSelection(.enabled)
            }
            .navigationTitle("PV of Minimum Rents")
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

struct PVOfRentsProof_Previews: PreviewProvider {
    static var previews: some View {
        PVOfRentsProof(myLease: Lease(aDate: today()), currentFile: .constant("file is new"), isDark: .constant(false), isPad: .constant(false))
            .preferredColorScheme(.light)
    }
}
