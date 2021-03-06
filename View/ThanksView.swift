//
//  ThanksView.swift
//  nextBookmark
//
//  Created by Kai on 24.02.20.
//  Copyright © 2020 Kai. All rights reserved.
//

import SwiftUI

extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}

struct LinkButton: View {
    let urlString: String
    let header: String
    
    var body: some View {
        Button(action: {
            guard let url = URL(string: urlString) else { return }
            UIApplication.shared.open(url)
        }) {
            Text(header)
        }
    }
}

struct ThanksView: View {
    var body: some View {
        Form {
            Section (header: Text("Feedback, Issues, Features, Code?...")) {
                LinkButton(urlString: "https://gitlab.com/altepizza/nextbookmark", header: "Visit me!")
            }
            Section (header: Text("Thanks")) {
                ForEach(Constants.CREDITS.sorted(by: <), id: \.key) { key, value in
                    LinkButton(urlString: value, header: key)
                }
            }
            Section {
                LinkButton(urlString: "https://gitlab.com/altepizza/nextbookmark/-/raw/master/privacy_policy.md", header: "Privacy Policy")
            }
            Section (header: Text("Version")) {
                Text(UIApplication.appVersion ?? "X.X.X")
            }
        }
        .navigationBarTitle("About", displayMode: .inline)
    }
}

struct ThanksView_Previews: PreviewProvider {
    static var previews: some View {
        ThanksView()
    }
}
