//
//  Picker.swift
//  GenesisUIAppApp
//
//  Created by user246073 on 11/9/24.
//

import SwiftUI

struct PickerCustom: View {
    @Binding var selectedSegment: Int // Теперь это binding, чтобы хранить значение извне
    let titles = ["Male", "Female"]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sex")
                .font(.sansReg(18))
            
            HStack(spacing: 0) {
                ForEach(0..<titles.count, id: \.self) { index in
                    Text(titles[index])
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selectedSegment == index ? .white : Color.purpleLite)
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .background(selectedSegment == index ? Color.purpleLite : Color.orange.opacity(0.2))
                        .cornerRadius(8)
                        .onTapGesture {
                            withAnimation {
                                selectedSegment = index
                            }
                        }
                }
            }
        }
        .padding(.horizontal, 40)
    }
}

//#Preview {
//    PickerCustom(selectedSegment: <#Binding<Int>#>)
//}
