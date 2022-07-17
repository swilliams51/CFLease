//
//  LaunchView.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 2/5/22.
//

import SwiftUI

struct LaunchView: View {
    private let phrase: String = "Lease pricing for the next generation!!"
    @State private var banner: String = ""
    @Binding var showLaunchView: Bool
    
    
    var body: some View {
        ZStack {
            Color.launch.background
                .ignoresSafeArea()
            HStack {
                Text("CFLease")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
            .offset(y: -80)
            
            Image("cfLeaseLogo")
                .resizable()
                .frame(width: 100, height: 100)
            
            HStack {
                Text(banner).animation(.spring())
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .offset(y: 80)
        }
        .transition(AnyTransition.scale.animation(.easeIn))
        .onAppear {
            banner = ""
            phrase.enumerated().forEach { index, character in
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.075) {
                    banner += String(character)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                showLaunchView = false
            }
            
        }
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView(showLaunchView: .constant(true))
    }
}
