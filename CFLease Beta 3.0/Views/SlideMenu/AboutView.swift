//
//  AboutView.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 3/3/22.
//

import SwiftUI
import MessageUI

struct AboutView: View {
    @Binding var isDark: Bool
    @ScaledMetric var scale: CGFloat = 1
    
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false

    @State private var mailData: ComposeMailData = ComposeMailData(subject: "Suggestions", recipients: ["info@cfsoftwaresolutions.com"], message: "My suggestions are below:", attachments: [AttachmentData]())
    
    var body: some View {
       
            NavigationView{
                Form{
                    logoItem
                    thankYouItem
                    companyDetailsItem
                    sendSuggestionsItem
                }
                .navigationTitle("CF Lease")
                .navigationBarTitleDisplayMode(.inline)
                .navigationViewStyle(.stack)
            }
            .environment(\.colorScheme, isDark ? .dark : .light)
            .sheet(isPresented: $isShowingMailView) {
                MailView(isShowing: self.$isShowingMailView, result: self.$result, data: $mailData)
            }
    }
    
    var thankYouItem: some View {
        HStack{
            Spacer()
            Text("Thank you for subscribing to CFLease!")
                .font(.subheadline)
            Spacer()
    
        }
    }
    
    var logoItem: some View {
            VStack{
                HStack {
                    Spacer()
                    Image("cfLeaseLogo")
                        .resizable()
                        .frame(width: scale * 100, height: scale * 100 , alignment: .center)
                        .padding()
                    Spacer()
                }
                HStack{
                    Text("V1.01.2022.04")
                        .font(.footnote)
                }
            }
    }
    
    var companyDetailsItem: some View {
        VStack{
            HStack {
                Spacer()
                Text("CF Software Solutions, LLC")
                    .font(.subheadline)
                .padding()
                Spacer()
            }
            Link("Home Page", destination: URL(string: "https:/www.cfsoftwaresolutions.com")!)
                .font(.footnote)
        }
    }
    
    var sendSuggestionsItem: some View {
        VStack {
            if MFMailComposeViewController.canSendMail() {
                HStack {
                    Spacer()
                    Button {
                        self.isShowingMailView.toggle()
                    } label: {
                        Text("Send email")
                            .font(.subheadline)
                    }
                    Spacer()
                }
            } else {
                HStack {
                    Spacer()
                    Text("Can't send emails from this device")
                        .font(.subheadline)
                    Spacer()
                }
            }
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView(isDark: .constant(false))
    }
}
