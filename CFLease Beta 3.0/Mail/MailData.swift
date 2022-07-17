//
//  MailData.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 3/16/22.
//

import Foundation

struct AttachmentData {
    let data: Data
    let mimeType: String
    let fileName: String
}

struct ComposeMailData {
    let subject: String
    let recipients: [String]?
    let message: String
    let attachments: [AttachmentData]?
}
