//
//  FileManager3.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/1/21.
//

import Foundation
import SwiftUI


class LocalFileManager {
    
    static let instance = LocalFileManager()
    let appFolder: String = "My_Leases_Data"
    
    init() {
        createLeaseDataFolder()
    }
    
    func createLeaseDataFolder() {
        let path = getDocumentDirectory()
        let folderPath = path.appendingPathComponent(appFolder)
        
        if !FileManager.default.fileExists(atPath: folderPath.path) {
            do {
                try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print("\(error)")
            }
        }
    }
    
    
    func fileSaveAs(strDataFile: String, fileName: String) {
        let fileURL = getDocumentDirectory().appendingPathComponent(appFolder).appendingPathComponent(fileName)
        
        do {
            try strDataFile.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Saved to file")
        } catch {
            print("Failed to save file")
        }
    }

    func getDocumentDirectory() -> URL {
        let path = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? nil)!
        return path
    }
    
    func getCacheDirectory() -> URL {
        let path = (FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first ?? nil)!
        return path
    }
    
    func getTempDirectory() -> URL {
        let path = FileManager.default.temporaryDirectory
        return path
    }
    
    func fileOpen(fileName: String) -> String {
        var classRoomText: String = ""
        let fileURL = getDocumentDirectory().appendingPathComponent(appFolder).appendingPathComponent(fileName)
       
        do {
            classRoomText = try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            print ("Failed to read")
        }

        return classRoomText
    }
    
    func getFileURL(fileName: String) -> URL {
        return getDocumentDirectory().appendingPathComponent(appFolder).appendingPathComponent(fileName)
    }
    
    func deleteFile(fileName: String) {
        let fileURL = getDocumentDirectory().appendingPathComponent(appFolder).appendingPathComponent(fileName)
        let fm = FileManager.default
        
        do {
            try fm.removeItem(at: fileURL)
        } catch let error {
            print("\(error)")
        }
    }
    
    func fileExists(fileName: String) -> Bool {
        let fileURL = getDocumentDirectory().appendingPathComponent(appFolder).appendingPathComponent(fileName)
        let fm = FileManager.default
        if fm.fileExists(atPath: fileURL.absoluteString) {
            return true
        } else {
            return false
        }
    }
    
    func renameFile(from: String, to: String) {
        let fm = FileManager.default
        
        let origFilePath = getDocumentDirectory().appendingPathComponent(appFolder).appendingPathComponent(from)
        let newFilePath = getDocumentDirectory().appendingPathComponent(appFolder).appendingPathComponent(to)
        
        do {
            try fm.moveItem(at: origFilePath, to: newFilePath)
        } catch let error {
            print("\(error)")
        }
    }
    
//    func listFilesByDate() -> [String] {
//        let fm = FileManager.default
//        let myPath = getTempDirectory()
//        let directoryURL = URL(string: myPath.path)
//        var items: [String] = []
//
//        do {
//            items = try fm.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: [.contentModificationDateKey], options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
//                .filter { $0.lastPathComponent.hasSuffix(".swift")}
//                .sorted(by: {
//                    let date0 = try $0.promisedItemResourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate!
//                    let date1 = try $1.promisedItemResourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate!
//                    return date0.compare(date1) == .orderedDescending
//                })
//        } catch {
//            print("No Files")
//        }
//
//        return items
//    }
    
    
    
    func listFiles() -> [String] {
        let fm = FileManager.default
        var items: [String] = []
        
        do {
            items = try fm.contentsOfDirectory(atPath: getDocumentDirectory().appendingPathComponent(appFolder).path)
        } catch {
            print("No Files")
        }
    
        return items.sorted()
    }
}
