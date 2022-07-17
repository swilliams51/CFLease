//
//  SlideMenuView.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/1/21.
//

import SwiftUI


struct SlideMenuView: View {
    @ObservedObject var myLease: Lease
    @Binding var endingBalance: String
    @Binding var showMenu: Bool
    @Binding var currentFile: String
    @Binding var fileExported: Bool
    @Binding var exportSuccessful: Bool
    @Binding var fileImported: Bool
    @Binding var importSuccessful: Bool
    @Binding var noOfSavedFiles: Int
    @Binding var selfIsNew: Bool
    @Binding var isPad: Bool
    @Binding var isDark: Bool
    
    @State private var fontSize: CGFloat = 18
    @State private var padding: CGFloat = 10
    @State private var myColor:Color = Color(red: 33/255.0, green: 33/255.0, blue: 33/255.0)
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
    
    @AppStorage("savedDefault") var savedDefaultLease: String = "No_Data"
    @AppStorage("useSaved") var useSavedAsDefault: Bool = false
   
    var body: some View {
        ZStack {
            Color(UIColor(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1)).edgesIgnoringSafeArea(.all)
            List {
                newFileMenuItem
                saveFileMenuItem
                saveAsFileMenuItem
                openFileMenuItem
                dayCountMenuItem
                chopMenuItem
                calculationsMenuItem
                reportsMenuItem
                preferencesMenuItem
                aboutMenuItem
            }
            .listStyle(PlainListStyle())
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .alert(isPresented: $showAlert, content: getAlert)
    }
    
    var newFileMenuItem: some View {
        HStack {
           Image(systemName: "doc")
                .imageScale(.medium)
                .foregroundColor(.white)
           Button(action: {
               self.myLease.resetLeaseToDefault(useSaved: useSavedAsDefault, currSaved: savedDefaultLease)
               self.myLease.solveForRate()
               self.endingBalance = myLease.getEndingBalance().toString()
               self.myLease.resetLease()
               self.showMenu.toggle()
               self.selfIsNew = true
               self.currentFile = "file is new"
           }) {
               Text("New")
                   .foregroundColor(.white)
                   .font(.subheadline)
           }
           .multilineTextAlignment(.trailing)
       }.listRowBackground(myColor)
    }
    
    var saveFileMenuItem: some View {
        HStack {
           Image(systemName: "square.and.arrow.down")
                .imageScale(.medium)
               .foregroundColor(.white)
            Button(action: {
                if self.currentFile == "file is new" {
                    self.alertTitle = alertFileSave
                    self.showAlert.toggle()
                } else {
                    let fm = LocalFileManager()
                    let strLeaseData: String = writeLeaseAndClasses(aLease: myLease)
                    fm.fileSaveAs(strDataFile: strLeaseData, fileName: currentFile)
                    self.showMenu.toggle()
                }
              
           }) {
               Text("Save")
                   .foregroundColor(.white)
                   .font(.subheadline)
           }
           .multilineTextAlignment(.trailing)
       }.listRowBackground(myColor)
        
    }
    
    var saveAsFileMenuItem: some View {
        NavigationLink(destination: FileSaveAsView(myLease: myLease, currentFile: $currentFile, noOfSavedFiles: $noOfSavedFiles, showMenu: $showMenu, isDark: $isDark)) {
           SlideMenuItemView(fontSize: fontSize, textMenu: "Save As", menuImage: "square.and.arrow.down.on.square")
        }.listRowBackground(myColor)
    }
    
    var openFileMenuItem: some View {
        NavigationLink(destination: FileOpenView(myLease: myLease, currentFile: $currentFile, fileExported: $fileExported, exportSuccessful: $exportSuccessful, fileImported: $fileImported, importSuccessful: $importSuccessful, selfIsNew: $selfIsNew, noOfSavedFiles: $noOfSavedFiles, showMenu: $showMenu, isDark: $isDark) ) {
             SlideMenuItemView(fontSize: fontSize, textMenu: "Open", menuImage: "envelope.open")
        }.listRowBackground(myColor)
    }
    
    var dayCountMenuItem: some View {
        NavigationLink(destination: DayCountView(myLease: myLease, endingBalance: $endingBalance, showMenu: $showMenu, isDark: $isDark) ) {
             SlideMenuItemView(fontSize: fontSize, textMenu: "Day Count", menuImage: "calendar")
        }.listRowBackground(myColor)
    }
    
    var chopMenuItem: some View {
        NavigationLink(destination: ChopView(myLease: myLease, endingBalance: $endingBalance, selfIsNew: $selfIsNew, showMenu: $showMenu, isDark: $isDark)){
           SlideMenuItemView(fontSize: fontSize, textMenu: "Cut-Off", menuImage: "scissors")
        }.listRowBackground(myColor)
    }
    
    var calculationsMenuItem: some View {
        NavigationLink(destination: CalculationsView(myLease: myLease, isDark: $isDark)) {
         SlideMenuItemView(fontSize: fontSize, textMenu: "Calculations", menuImage: "sum")
        }.listRowBackground(myColor)
    }
    
    var reportsMenuItem: some View {
        NavigationLink(destination: ReportsView(myLease: myLease, showMenu: $showMenu, currentFile: $currentFile, isDark: $isDark, isPad: $isPad)) {
            SlideMenuItemView(fontSize: fontSize, textMenu: "Reports", menuImage: "doc.text")
        }.listRowBackground(myColor)
    }
    
    var preferencesMenuItem: some View {
        NavigationLink (destination: PreferencesView(myLease: myLease, isDark: $isDark)) {
            SlideMenuItemView(fontSize: fontSize, textMenu: "Preferences", menuImage: "gearshape")
        }.listRowBackground(myColor)
    }
    
    var aboutMenuItem: some View {
        NavigationLink(destination: AboutView(isDark: $isDark)) {
            SlideMenuItemView(fontSize: fontSize, textMenu: "About", menuImage: "questionmark.circle")
        }.listRowBackground(myColor)
    }
    
    func getAlert() -> Alert{
        return Alert(title: Text(alertTitle))
    }
    
    func balanceIsZero() -> Bool {
        let balance: Decimal = endingBalance.toDecimal()
        if abs(balance) < 0.075 {
            return true
        }
        return false
    }
}

struct SlideMenuView_Previews: PreviewProvider {

    static var previews: some View {
        SlideMenuView(myLease: Lease(aDate: today()), endingBalance: .constant("0.00"), showMenu: .constant(false), currentFile: .constant("file is new"), fileExported: .constant(false), exportSuccessful: .constant(false), fileImported: .constant(false), importSuccessful: .constant(false), noOfSavedFiles: .constant(0), selfIsNew: .constant(false), isPad: .constant(false), isDark: .constant(false))
    }
}

struct SlideMenuItemView: View {

    let fontSize: CGFloat
    let textMenu: String
    let menuImage: String
    
    var body: some View {
        HStack {
            Image(systemName: menuImage)
                .imageScale(.medium)
                .foregroundColor(.white)
            Text (textMenu)
                .foregroundColor(.white)
                .font(.subheadline)
        }
    }
}
            
let alertFileSave: String = "A file name has not been provided.  Select File Save As and enter a valid name.  Then File Save can be selected!"

    

   
