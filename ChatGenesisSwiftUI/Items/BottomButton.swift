//
//  BottomButton.swift
//  GenesisUIAppApp
//
//  Created by user246073 on 11/9/24.
//

import SwiftUI

struct BottomButton: View {
    let textSupport: String
    let textButton: String
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(textSupport)
                .font(.sansReg(18))
            Button(textButton, action: action)
                .font(.sansReg(18))
                .foregroundColor(.red)
            Spacer()
        }
        .padding(.leading, 45)
        .padding(.bottom, 35)
    }
}

#Preview {
    BottomButton(textSupport: "Already onboard?", textButton: "Login", action: {})
}
