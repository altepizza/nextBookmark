//
//  ThanksView.swift
//  nextBookmark
//
//  Created by Kai on 24.02.20.
//  Copyright © 2020 Kai. All rights reserved.
//

import SwiftUI

struct ThanksView: View {
    var body: some View {
        NavigationView{
            VStack{
                Text("Feedback, Issues, Features, Code?...")
                Button(action: {
                    guard let url = URL(string: "https://gitlab.com/altepizza/nextbookmark") else { return }
                    UIApplication.shared.open(url)
                }) {
                    Text("Visit me!")
                }
                Spacer()
                Text("Also thanks to...")
                Button(action: {
                    guard let url = URL(string: "https://github.com/Alamofire/Alamofire") else { return }
                    UIApplication.shared.open(url)
                }) {
                    Text("Alamofire")
                }
                Button(action: {
                    guard let url = URL(string: "https://github.com/Daltron/NotificationBanner") else { return }
                    UIApplication.shared.open(url)
                }) {
                    Text("NotificationBanner")
                }
                Button(action: {
                    guard let url = URL(string: "https://github.com/siteline/SwiftUIRefresh") else { return }
                    UIApplication.shared.open(url)
                }) {
                    Text("SwiftUI-Refresh")
                }
                Button(action: {
                    guard let url = URL(string: "https://github.com/SwiftyJSON/SwiftyJSON") else { return }
                    UIApplication.shared.open(url)
                }) {
                    Text("SwiftyJSON")
                }
                
            }
        }.navigationBarTitle("About", displayMode: .inline)
    }
}

struct ThanksView_Previews: PreviewProvider {
    static var previews: some View {
        ThanksView()
    }
}
