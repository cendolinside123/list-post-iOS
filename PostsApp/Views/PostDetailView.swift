import SwiftUI

struct PostDetailView: View {
    let post: Post

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(post.title.capitalized)
                    .font(.title2.bold())
                Text("Post #\(post.id) · User #\(post.userId)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(post.body)
                    .font(.body)
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle("Post Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
