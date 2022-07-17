//
//  ContentView.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/1/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var myLease: Lease = Lease(aDate: today())
    @State var isPad: Bool = false
    
    @AppStorage("useSaved") var useSavedAsDefault: Bool = false
    @AppStorage("savedDefault") var savedDefaultLease: String = "No_Data"
    @AppStorage("isDarkMode") var isDark: Bool = false
    
    @State private var currentFile: String = "file is new"
    @State private var noOfSavedFiles: Int = 0
    @State private var endingBalance: String = "0.0"
    @State private var showMenu: Bool = false //
    @State private var menuIsActive: Bool = true
    
    @State private var fileExported: Bool = false
    @State private var exportSuccessful: Bool = false
    @State private var fileImported: Bool = false
    @State private var importSuccessful: Bool = false

    @State private var selfIsNew: Bool = false //New file has been created
    @State private var editAmountStarted: Bool = false //edit of lease amount starterd
    @State private var editRateStarted: Bool = false // edit of interest rate started
    @State private var stepperChangedByUser: Bool = false // base term stepper chnaged by user
    
    var body: some View {
        let drag = DragGesture()
            .onEnded {
                if $0.translation.width < -100 {
                    withAnimation {
                        self.showMenu = false
                    }
                }
            }
        return NavigationView {
            GeometryReader { geometry in
                VStack {
                    ZStack(alignment: .leading) {
                        LeaseMainView(myLease: myLease, endingBalance: $endingBalance, currentFile: $currentFile, fileExported: $fileExported, exportSuccessful: $exportSuccessful, fileImported: $fileImported, importSuccessful: $importSuccessful, selfIsNew: $selfIsNew, editAmountStarted: $editAmountStarted, editRateStarted: $editRateStarted, menuIsActive: $menuIsActive, isPad: $isPad, isDark: $isDark)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .offset(x: self.showMenu ? geometry.size.width/1.8 : 0, y: 0)
                            .disabled(self.showMenu ? true : false)

                        if self.showMenu == true {
                            SlideMenuView(myLease: myLease, endingBalance: $endingBalance, showMenu: $showMenu, currentFile: $currentFile, fileExported: $fileExported, exportSuccessful: $exportSuccessful, fileImported: $fileImported, importSuccessful: $importSuccessful, noOfSavedFiles: $noOfSavedFiles, selfIsNew: $selfIsNew, isPad: $isPad, isDark: $isDark)
                                .frame(width: geometry.size.width/1.8, height: geometry.size.height)
                                .transition(.move(edge: .leading))
                        }
                    }
                    .gesture(drag)
                    
                }
            }
            .navigationViewStyle(.stack)
            .navigationBarItems(leading: (
                Button(action: {
                    withAnimation {
                        if self.menuIsActive{
                            self.showMenu.toggle()
                        }
                    }
                }) {
                    Image(systemName: "line.horizontal.3")
                        .imageScale(.large)
                }
            ))
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .onAppear{
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.isPad = true
            }
        }
    }
       
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
    }
}

