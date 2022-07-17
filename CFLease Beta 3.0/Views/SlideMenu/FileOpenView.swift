//
//  FileOpenView.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/1/21.
//

import SwiftUI

struct FileOpenView: View {
    @ObservedObject var myLease: Lease
    @Binding var currentFile: String
    @Binding var fileExported: Bool
    @Binding var exportSuccessful: Bool
    @Binding var fileImported: Bool
    @Binding var importSuccessful: Bool
    @Binding var selfIsNew: Bool
    @Binding var noOfSavedFiles: Int
    @Binding var showMenu: Bool
    @Binding var isDark: Bool
    @Environment(\.presentationMode) var presentationMode
    
    @State private var leaseDoc: LeaseDocument = LeaseDocument(myData: "")
    @State private var showingExporter: Bool = false
    @State private var showingImporter = false
    @State private var exportIsOn: Bool = true
    @State private var fm = LocalFileManager()
    @State private var files: [String] = [String]()
    @State private var selectedFileIndex: Int = 0
    @State private var selectedFile: String = ""
    @State private var textFileLabel: String = "select a file:"
    @State private var folderIsEmpty: Bool = false
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var showPopover1: Bool = false
    @State private var showPopover2: Bool = false //import help
    @State private var showPopover3: Bool = false //export help
    
    @State var importHelp = importFileHelp
    @State var exportHelp = exportFileHelp
    @State var importExport = importExportHelp
    
    @AppStorage("savedDefault") var savedDefaultLease: String = "No_Data"
    @AppStorage("useSaved") var useSavedAsDefault: Bool = false
   
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("File Open/Delete")) {
                    numberOfSavedFilesRow
                    pickerOfSavedFiles
                    deleteAndOpenButtonItems
                }
                Section(header: Text("Export/Import")) {
                    exportIsActiveToggleRow
                    exportActionRow
                    importActionRow
                }
            }
            .navigationTitle("File Management").font(.body).foregroundColor(isDark ? .white : .black)
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        
        .fileExporter(
              isPresented: $showingExporter,
              document: leaseDoc,
              contentType: .plainText,
              defaultFilename: self.currentFile
          ) { result in
              self.fileExported = true
              if case .success = result {
                  // Handle success.
                  self.exportSuccessful = true
              } else {
                  // Handle failure.
                  self.exportSuccessful = false
              }
              self.presentationMode.wrappedValue.dismiss()
          }
        
          .fileImporter(
              isPresented: $showingImporter,
              allowedContentTypes: [.plainText],
              allowsMultipleSelection: false
          ) { result in
              self.fileImported = true
              if case .success = result {
                  do {
                      guard let selectedFile: URL = try result.get().first else { return }
                      if selectedFile.startAccessingSecurityScopedResource(){
                          guard let data = String(data: try Data(contentsOf: selectedFile), encoding: .utf8) else { return }
                          defer { selectedFile.stopAccessingSecurityScopedResource() }
                          let fileName: String = selectedFile.deletingPathExtension().lastPathComponent
                          self.leaseDoc.leaseData = data
                          if self.leaseDoc.isValidFile() == true {
                              self.importSuccessful = true
                              self.myLease.readLeaseFromString(strFile: self.leaseDoc.leaseData)
                              self.currentFile = fileName
                              self.selfIsNew = true
                              self.showMenu.toggle()
                              modificationDate = "01/01/1900"
                          } else {
                              self.importSuccessful = false
                          }

                      } else {
                          
                      }
                      
                     
                  } catch {
                      let nsError = error as NSError
                      fatalError("File Import Error \(nsError), \(nsError.userInfo)")
                  }
              } else {
                  self.importSuccessful = false
              }
              self.presentationMode.wrappedValue.dismiss()
          }
        
        .onAppear{
            self.files = fm.listFiles()
            self.noOfSavedFiles = self.files.count
            if self.noOfSavedFiles == 0 {
                self.folderIsEmpty = true
            } else {
                self.selectedFile = self.files[0]
            }
        }
    }
    
    var numberOfSavedFilesRow: some View {
        HStack {
            Text("no. of saved files:")
                .font(.subheadline)
            Spacer()
            Text("\(self.noOfSavedFiles)")
                .font(.subheadline)
        }
    }
    
    var pickerOfSavedFiles: some View {
        Picker(selection: $selectedFileIndex, label:
                Text(textFileLabel)) {
            ForEach(0..<files.count, id: \.self) { i in
                Text(self.files[i])
                    .font(.subheadline)
            }
        }
        .font(.subheadline)
        .disabled(folderIsEmpty)
        .onChange(of: selectedFileIndex) { _ in
            self.selectedFile = String(self.files[selectedFileIndex])
        }
    }
    
    var deleteAndOpenButtonItems: some View {
        HStack {
            deleteButtonItem
            Spacer()
            openButtonItem
        }
    }
    
    var deleteButtonItem: some View {
        Button(action: {}) {
            Text("Delete")
                .font(.subheadline)
                .foregroundColor(Color.theme.accent)
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert (
                title: Text("Are you sure you want to delete this file?"),
                message: Text("There is no undo"),
                primaryButton: .destructive(Text("Delete")) {
                    fm.deleteFile(fileName: self.selectedFile)
                    // set to default
                    self.myLease.resetLeaseToDefault(useSaved: useSavedAsDefault, currSaved: savedDefaultLease)
                    self.myLease.solveForRate()
                    self.myLease.resetLease()
                    self.selfIsNew = true
                    self.currentFile = "file is new"
                    self.showMenu.toggle()
                    self.presentationMode.wrappedValue.dismiss()
            },
                   secondaryButton: .cancel()
            )}
        .multilineTextAlignment(.trailing)
        .onTapGesture {
            showDeleteAlert.toggle()
            
        }
    }
    
    var openButtonItem: some View {
        Button(action: {}) {
            Text("Open")
                .font(.subheadline)
                .foregroundColor(Color.theme.accent)
        }
        .multilineTextAlignment(.trailing)
        .onTapGesture {
            if folderIsEmpty == false {
                self.selectedFile = files[selectedFileIndex]
                let strFileText: String = fm.fileOpen(fileName: selectedFile)
                self.myLease.readLeaseFromString(strFile: strFileText)
                self.currentFile = self.selectedFile
                self.selfIsNew = true
                self.showMenu.toggle()
                modificationDate = "01/01/1900"
            } else {
                self.alertTitle = alertNoFileExists
                self.showAlert.toggle()
            }
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    var exportIsActiveToggleRow: some View {
        HStack {
            Text(exportIsOn ? "export action:" : "import action:")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover1 = true
                }
            Toggle("", isOn: $exportIsOn)
        }
        .popover(isPresented: $showPopover1) {
            PopoverView(myHelp: $importExport, isDark: $isDark)
        }
    }
    
    //Export Files
    var exportActionRow: some View {
        HStack {
            Text("above selected file:")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover2 = true
                }
            Spacer()
            Button(action: {}) {
                Text("Export")
                    .font(.subheadline)
                    .foregroundColor(exportIsOn ? Color.theme.accent : Color.theme.inActive)
                    
            }.disabled(folderIsEmpty)
            .onTapGesture {
                if self.exportIsOn == true {
                    //create the document
                    self.leaseDoc.leaseData = fm.fileOpen(fileName: selectedFile)
                    // create filename
                    self.currentFile = self.selectedFile
                    // then invoke exporter
                    self.showingExporter = true
                }
            }
        }
        .popover(isPresented: $showPopover2) {
            PopoverView(myHelp: $exportHelp, isDark: $isDark)
        }
    }
    
    //Import Files
    var importActionRow: some View {
        HStack {
            Text("selected file:")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover3 = true
                }
            Spacer()
            Button(action: {}) {
                Text("Import")
                    .font(.subheadline)
                    .foregroundColor(exportIsOn ? Color.theme.inActive : Color.theme.accent)
            }
            .onTapGesture {
                if self.exportIsOn == false {
                    self.showingImporter = true
                }
            }
        }
        .popover(isPresented: $showPopover3) {
            PopoverView(myHelp: $importHelp, isDark: $isDark)
        }
    }
    
    func fileNameExists(strName: String) -> Bool {
        var fileExists: Bool = false
        if files.contains(strName) {
            fileExists = true
        }
        
        return fileExists
    }
    
}
    

struct FileOpenView_Previews: PreviewProvider {
    static var previews: some View {
        FileOpenView(myLease: Lease(aDate: today()), currentFile: .constant("file is new"), fileExported: .constant(false), exportSuccessful: .constant(false), fileImported: .constant(false), importSuccessful: .constant(false), selfIsNew: .constant(true), noOfSavedFiles: .constant(0), showMenu: .constant(true), isDark: .constant(false))
            .preferredColorScheme(.light)
    }
}

let alertNoFileExists: String = "No CFLease files exist. The file folder is empty!!!"


