//
//  NoConnection.swift
//  TestTaskSfUI
//
//  Created by user246073 on 11/7/24.
//

import SwiftUI

struct NoConnectionView: View {
    @ObservedObject var networkMonitor: NetworkMonitor // Passing the observer object
    
    var body: some View {
        VStack {
            Image("NoConnect")
                .resizable()
                .frame(width: 200, height: 200)
                .background(Color.white)
            Text("There is no internet connection")
                .font(.custom("NunitoSans-Regular", size: 20))
            PrimaryButton(title: "Try again", action: {
                networkMonitor.checkConnection()
            }, mod: false)
        }
    }
}


#Preview {
    NoConnectionView(networkMonitor: NetworkMonitor())
}
