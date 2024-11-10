//
//  SearchControllerBar.swift
//  ChatGenesisSwiftUI
//
//  Created by user246073 on 11/9/24.
//

import SwiftUI

struct SearchControllerBar: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            TextField("Search...", text: $searchText)
                .padding(8)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.purpleLite)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.orange)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal, 10)
        }
        .padding(.top, 10)    }
}

//#Preview {
//    SearchControllerBar(searchText: <#Binding<String>#>)
//}
