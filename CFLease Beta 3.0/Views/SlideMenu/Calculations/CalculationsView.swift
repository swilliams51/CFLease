//
//  CalculationsView.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/13/21.
//

import SwiftUI

struct CalculationsView: View {
    @ObservedObject var myLease: Lease
    @Binding var isDark: Bool
    
    var body: some View {
        NavigationView {
            List {
                lesseePaidFeeLink
                buyRateLink
                presentValueOfRentsLink
                earlyBuyoutLink
                terminationsLink
                leaseBalanceLink
            }
            .navigationTitle("Calculations").font(.body).foregroundColor(isDark ? .white : .black)
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
    }
    
    var lesseePaidFeeLink: some View {
        NavigationLink(destination: LesseePaidFeeView(myLease: myLease, isDark: $isDark)) {
            Text("\(Image(systemName: "dollarsign.square"))  Lessee Paid Fee")
                .font(.subheadline)
        }
    }
    
    var buyRateLink: some View {
        NavigationLink(destination: PurchaseView(myLease: myLease, isDark: $isDark)) {
            Text("\(Image(systemName: "cart"))  Purchase Lease")
                .font(.subheadline)
        }
    }
    
    var presentValueOfRentsLink: some View {
        NavigationLink(destination: PVRentsView(myLease: myLease, isDark: $isDark)) {
            Text("\(Image(systemName: "sum"))  Present Value of Rents")
                .font(.subheadline)
        }.disabled(myLease.isTrueLease() ? false : true )
    }
    
    var earlyBuyoutLink: some View {
        NavigationLink(destination: EarlyBuyoutView(myLease: myLease, isDark: $isDark)) {
            Text("\(Image(systemName: "option"))  Early Buyout Option")
                .font(.subheadline)
        }.disabled(myLease.isTrueLease() ? false : true)
    }
    
    var terminationsLink: some View {
        NavigationLink(destination: TValuesView(myLease: myLease, isDark: $isDark)) {
            Text("\(Image(systemName: "tablecells"))  Termination Values")
                .font(.subheadline)
        }
    }
    
    var leaseBalanceLink: some View {
        NavigationLink(destination: LeaseBalanceView(myLease: myLease, isDark: $isDark)) {
            Text("\(Image(systemName: "hourglass"))  Lease Balance")
                .font(.subheadline)
        }
    }
    
    
}

struct CalculationsView_Previews: PreviewProvider {
    static var previews: some View {
        CalculationsView(myLease: Lease(aDate: today()), isDark: .constant(false))
            .preferredColorScheme(.light)
    }
}
