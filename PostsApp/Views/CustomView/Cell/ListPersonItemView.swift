//
//  ListPersonItemView.swift
//  PostsApp
//
//  Created by Jan on 02/11/26.
//

import SwiftUI

struct ListPersonItemView: View {
    private let item: User
    private let selectedId: Int?
    private let selectedUser: ((User) -> Void)
    
    init(
        item: User,
        selectedId: Int?,
        selectedUser: @escaping ((User) -> Void)
    ) {
        self.item = item
        self.selectedId = selectedId
        self.selectedUser = selectedUser
    }
    
    var body: some View {
        Button {
            selectedUser(item)
        } label: {
            HStack(spacing: 10) {
                
                Text("Id: \(item.id)")
                    .font(.headline)
                    .lineLimit(2)
                Text(item.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding([.vertical, .horizontal], 12)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(
                        item.id == selectedId ? Color.blue : Color.gray.opacity(0.2),
                        lineWidth: 2
                    )
            )
            .foregroundColor(.black)
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(
            EdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        )
    }
}

#Preview {
    ListPersonItemView(
        item: User(
            id: -1,
            name: "asd",
            username: "asd"
        ),
        selectedId: nil,
        selectedUser: { _ in
            
        }
    )
}
