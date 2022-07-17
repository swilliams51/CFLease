//
//  CFLease_Beta_3_0App.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/1/21.
//

import SwiftUI

@main
struct CFLease_Beta_3_0App: App {
    @State var showLaunchView: Bool = true
    
    
    var body: some Scene {
        
        WindowGroup {
            ZStack {
                ContentView()
                ZStack {
                    if showLaunchView == true {
                        LaunchView(showLaunchView: $showLaunchView)
                            .transition(.move(edge: .leading))
                    }
                }
                .zIndex(2.0)
            }
            
        }
    }
        
}

