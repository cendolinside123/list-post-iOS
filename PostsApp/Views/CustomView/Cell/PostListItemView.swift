//
//  PostListItemView.swift
//  PostsApp
//
//  Created by Jan on 02/11/26.
//

import SwiftUI

struct PostListItemView: View {
    
    private let post: Post
    
    init(post: Post) {
        self.post = post
    }
    
    var body: some View {
        NavigationLink {
            PostDetailView(post: post)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(post.title.capitalized)
                    .font(.headline)
                    .lineLimit(2)
                Text(post.body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text("User #\(post.userId)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 4)
        }.accessibilityLabel(
            "post.item.\(post.id)"
        )
    }
}

#Preview {
    PostListItemView(
        post: Post(
            userId: 1,
            id: 1,
            title: "asd",
            body: "asd"
        )
    )
}
