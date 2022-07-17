//
//  PreferencesView.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 1/18/22.
//

import SwiftUI

struct PreferencesView: View {
    @ObservedObject var myLease: Lease
    
    @AppStorage("maxNoFiles") var maximumNoOfFiles: Int = 20
    @AppStorage("maxBaseTerm") var maximumBaseTerm: Int = 120
    @AppStorage("useSaved") var useSavedAsDefault: Bool = false
    @AppStorage("savedDefault") var savedDefaultLease: String = "No_Data"
    
    @Binding var isDark: Bool
    @State var saveCurrentAsDefault: Bool = false
    @State var showPopover: Bool = false
    @State var defaultHelp = defaultNewHelp
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    @State var maxAmount: Int = 4
    @State var maxRate: Int = 4
    @State var maxFiles: Int = 20
    @State var maxBaseTerm: Int = 120
    
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Maximum Values").font(.footnote)) {
                    maxBaseTermItem
                    maxNoSavedFilesItems
                }
                Section(header: Text("Default Lease Parameters").font(.footnote)) {
                    defaultNewLeaseItem
                    saveCurrentAsDefaultItem
                }
                
                Section(header: Text("Color Scheme").font(.footnote)) {
                    colorSchemeItem
                }
                
                Section (header: Text("Sumbit Form").font(.footnote)) {
                    HStack {
                        buttonCancelItem
                        Spacer()
                        buttonDoneItem
                    }
                }
                .navigationTitle("Preferences")
                .navigationBarTitleDisplayMode(.inline)
                .navigationViewStyle(.stack)
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .onAppear {
            self.maxBaseTerm = self.maximumBaseTerm
            self.maxFiles = self.maximumNoOfFiles
        }
        .alert(isPresented: $showAlert, content: getAlert)
    }
    
    var maxBaseTermItem: some View {
        Stepper("base term: \(maxBaseTerm) mons", value: $maxBaseTerm, in: 120...180, step: 12)
            .font(.subheadline)
    }

    
    var maxNoSavedFilesItems: some View {
        Stepper("saved files: \(maxFiles)", value: $maxFiles, in: 10...50, step: 1)
            .font(.subheadline)
    }
    
    var defaultNewLeaseItem: some View {
        HStack {
            Text(useSavedAsDefault ? "use saved:" : "use default:")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover = true
                }
            Spacer()
            Toggle("", isOn: $useSavedAsDefault)
        }
        .popover(isPresented: $showPopover) {
            PopoverView(myHelp: $defaultHelp, isDark: $isDark)
        }
    }
    
    var saveCurrentAsDefaultItem: some View {
        HStack {
            Text("save current:")
                .font(.subheadline)
            Toggle("", isOn: $saveCurrentAsDefault)
        }
    }
    
    var colorSchemeItem: some View {
        Toggle(isOn: $isDark) {
            Text(isDark ? "dark mode is on:" : "light mode is on:")
                .font(.subheadline)
        }
    }
    
    var buttonCancelItem: some View {
        Button(action: {}) {
            Text("Cancel")
                .font(.subheadline)
        }
        .multilineTextAlignment(.trailing)
        .onTapGesture {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    var buttonDoneItem: some View {
        Button(action: {}) {
            Text("Done")
                .font(.subheadline)
        }
        .multilineTextAlignment(.trailing)
        .onTapGesture {
            self.maximumBaseTerm = self.maxBaseTerm
            self.maximumNoOfFiles = self.maxFiles
            if self.saveCurrentAsDefault == true {
                if isLeaseSavable() {
                    self.savedDefaultLease = writeLeaseAndClasses(aLease: myLease)
                } else {
                   alertTitle = alertDefaultLease
                    showAlert.toggle()
                }
            }
            self.presentationMode.wrappedValue.dismiss()
        }
        
    }
    
    func getAlert() -> Alert{
        return Alert(title: Text(alertTitle))
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView(myLease: Lease(aDate: today()), isDark: .constant(false))
            .preferredColorScheme(.dark)
    }
}

extension PreferencesView {
    
    func isLeaseSavable () -> Bool {
        if myLease.fundingDate != myLease.baseTermCommenceDate {
            return false
        }
        
        return true
    }
    
}

let alertDefaultLease: String = "A default lease cannot include an interim term, i.e., the base term commencement date must equal the funding date."
