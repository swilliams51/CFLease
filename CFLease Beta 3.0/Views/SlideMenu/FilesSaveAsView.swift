//
//  FilesSaveAsView.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/1/21.
//

import SwiftUI

struct FileSaveAsView: View {
    @ObservedObject var myLease: Lease
    @Binding var currentFile: String
    @Binding var noOfSavedFiles: Int
    @Binding var showMenu: Bool
    @Binding var isDark: Bool
    
    @Environment(\.presentationMode) var presentationMode
    @State private var fileNameOnEntry: String = ""
    @State private var fm = LocalFileManager()
    @State private var files: [String] = [String]()
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
    @State private var renameIsActive: Bool = false
    @State private var fileSaveAsIsActive: Bool = true
    @State private var newFileName: String = ""
    @State private var showPopover: Bool = false
    @State var helpFileRename: Help = renameHelp
    
    @AppStorage("maxNoFiles") var maximumNoOfFiles: Int = 20
    @AppStorage("maxBaseTerm") var maximumBaseTerm: Int = 120
  
    var defaultInactive: Color = Color.theme.inActive
    var activeButton: Color = Color.theme.accent

    var body: some View {
        NavigationView{
            Form {
                Section(header: Text("File Save As").font(.footnote)) {
                    saveAsRow
                    submitSaveAsCancelRow
                }
                .disabled(fileSaveAsIsActive ? false : true)
                Section(header: Text("Rename File").font(.footnote)) {
                    inactiveRowItem
                    fromFileNameRowItem
                    toFileNameRowItem
                    submitCancelRowItem
                }
            }
            .navigationTitle("File Management").font(.body).foregroundColor(isDark ? .white : .black)
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .alert(isPresented: $showAlert, content: getAlert)
        .onAppear{
            self.fileNameOnEntry = currentFile
            self.files = fm.listFiles()
        }
    }
    
    var saveAsRow: some View {
        HStack {
            Text("save as:")
                .font(.subheadline)
            Spacer()
            TextField("file name", text: $currentFile,
                onCommit: {
                if validFileName(strName: self.currentFile) == false {
                    self.currentFile = fileNameOnEntry
                }
            })
                .font(.subheadline)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.default)
                .disableAutocorrection(true)
        }
    }
    
    var submitSaveAsCancelRow: some View {
        HStack {
            cancelButtonItem
            Spacer()
            saveAsButtonItem
        }
    }

    var inactiveRowItem: some View {
        Toggle(isOn: $renameIsActive) {
            Text(renameIsActive ? "active:" : "inactive:")
                .font(.subheadline)
                .onChange(of: renameIsActive) { value in
                    if value == true {
                        self.fileSaveAsIsActive = false
                    } else {
                        self.fileSaveAsIsActive = true
                    }
                }
        }
    }
    
    var fromFileNameRowItem: some View {
        HStack {
            Text("from:")
                .font(.subheadline)
            Spacer()
            Text(renameIsActive ? "\(currentFile)" : "current name")
                .font(.subheadline)
               
        }
    }
    
    var toFileNameRowItem: some View {
        HStack {
            Text("to:")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover = true
                }
            Spacer()
            TextField("", text: $newFileName)
                .font(.subheadline)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.default)
                .disableAutocorrection(true)
                .disabled(renameIsActive ? false : true)
        }
        .popover(isPresented: $showPopover) {
            PopoverView(myHelp: $helpFileRename, isDark: $isDark)
        }
    }
    
    var submitCancelRowItem: some View {
        HStack {
            cancelButtonItem2
            Spacer()
            submitRowItem
        }
    }
    
    var submitRowItem: some View {
        Button(action: {}) {
            Text("Submit")
                .font(.subheadline)
                .foregroundColor(renameIsActive ? activeButton : defaultInactive)
        }
        .disabled(renameIsActive ? false : true)
        .multilineTextAlignment(.trailing)
        .onTapGesture {
            if fileNameExists(strName: self.currentFile) {
                if validFileName(strName: self.newFileName) == true {
                    if fileNameExists(strName: self.newFileName) == false {
                        fm.renameFile(from: self.currentFile, to: self.newFileName)
                        self.currentFile = self.newFileName
                        self.presentationMode.wrappedValue.dismiss()
                    } else {
                        self.currentFile = fileNameOnEntry
                        self.alertTitle = alertFileNameAlreadyExists
                        self.showAlert.toggle()
                    }
                } else {
                    self.currentFile = fileNameOnEntry
                    self.alertTitle = alertInvalidName
                    self.showAlert.toggle()
                    self.newFileName = ""
                }
            } else {
                self.currentFile = fileNameOnEntry
                self.alertTitle = alertFileNameDoesNotExist
                self.showAlert.toggle()
            }
            
        }
    }
    
    var cancelButtonItem: some View {
        Button(action: {}) {
            Text("Cancel")
                .font(.subheadline)
                .foregroundColor(renameIsActive ? defaultInactive : activeButton)
        }
        .disabled(renameIsActive ? false : true)
        .multilineTextAlignment(.trailing)
        .onTapGesture {
            self.showMenu.toggle()
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    var cancelButtonItem2: some View {
        Button(action: {}) {
            Text("Cancel")
                .font(.subheadline)
                .foregroundColor(renameIsActive ? activeButton : defaultInactive)
        }
        .disabled(renameIsActive ? false : true)
        .multilineTextAlignment(.trailing)
        .onTapGesture {
            self.showMenu.toggle()
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    var saveAsButtonItem: some View {
        Button(action: {}) {
            Text("Save")
                .font(.subheadline)
                .foregroundColor(renameIsActive ? defaultInactive : activeButton)
        }
        .disabled(maxNoOfFilesSavedExceeded())
        .multilineTextAlignment(.trailing)
        .onTapGesture {
            //let fm = LocalFileManager()
            if isLeaseValid() == true {
                if validFileName(strName: self.currentFile) == true && fileNameExists(strName: self.currentFile) == false {
                    if noOfSavedFiles > 14 {
                        self.alertTitle = alertMaxFiles
                        self.showAlert.toggle()
                    }
                    let strLeaseData: String = writeLeaseAndClasses(aLease: myLease)
                    fm.fileSaveAs(strDataFile: strLeaseData, fileName: currentFile)
                    self.showMenu.toggle()
                    self.presentationMode.wrappedValue.dismiss()
                } else {
                    self.currentFile = fileNameOnEntry
                    self.alertTitle = alertInvalidName
                    self.showAlert.toggle()
                }
            } else {
                self.alertTitle = alertInvalidLease
                self.showAlert.toggle()
                self.showMenu.toggle()
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        
    }
    
    func getAlert() -> Alert{
        return Alert(title: Text(alertTitle))
    }
    
    func fileNameExists(strName: String) -> Bool {
        var fileExists: Bool = false
        if files.contains(strName) {
            fileExists = true
        }
        
        return fileExists
    }
    
    func maxNoOfFilesSavedExceeded() -> Bool {
        if noOfSavedFiles > maximumNoOfFiles {
            return true
        }
        return false
    }
    
    func validFileName(strName: String) -> Bool {
        //is string empty
        if strName.count == 0 {
            return false
        }
        //is its length longer the limit
        if strName.count > maxFileLength {
            return false
        }
        if strName == "file is new" {
            return false
        }
        //contains illegal chars or punctuation chars
        let myIllegalChars = "!@#$%^&()<>?,|[]{}:;/"
        let charSet = CharacterSet(charactersIn: myIllegalChars)
        if (strName.rangeOfCharacter(from: charSet) != nil) {
            return false
        }
    
        return true
    }
    
    func isLeaseValid() -> Bool {
        var leaseIsValid: Bool = true
        
        if self.myLease.amount.toDecimal() > maximumLeaseAmount.toDecimal() {
            leaseIsValid = false
        }
        
        if self.myLease.amount.toDecimal() < minimumLeaseAmount.toDecimal() {
            leaseIsValid = false
        }
        
        if self.myLease.interestRate.toDecimal() > maximumInterestRate.toDecimal(){
            leaseIsValid = false
        }
        
        if self.myLease.interestRate.toDecimal() == 0.00 {
            leaseIsValid = false
        }
        
        if self.myLease.baseTerm > maximumBaseTerm {
            leaseIsValid = false
        }
        
        for x in 0..<myLease.groups.items.count{
            if myLease.groups.items[x].amount.toDecimal() < 0.0 {
                leaseIsValid = false
                break
            }
        }
        
        return leaseIsValid
    }
    
}

struct FileSaveAs_Previews: PreviewProvider {
    static var previews: some View {
        FileSaveAsView(myLease: Lease(aDate: today()), currentFile: .constant("file is new"), noOfSavedFiles: .constant(0), showMenu: .constant(true), isDark: .constant(false))
            .preferredColorScheme(.light)
    }
}

let alertMaxFiles: String = "The number of saved files is approaching the maximum number. Consider deleting some older files!!!"
let alertInvalidName: String = "A valid file name must contain only numbers and letters and be less than 45 characters long!!!"
let alertInvalidLease: String = "Certain parameters such amount, interest rate, or base term exceed the minimum or maximum allowable amounts.  The lease cannot be saved!!!"
let alertFileNameDoesNotExist: String = "The filename does not exist in the collection."
let alertFileNameAlreadyExists: String = "The file name already exists in the collection."

