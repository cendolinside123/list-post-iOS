import SwiftUI

@main
struct PostsApp: App {
    var body: some Scene {
        WindowGroup {
            PostListView(
                factory: PostViewModelInjectionImpl.shared,
                listUserFactory: ListUserViewModelInjectionImpl.shared
            )
        }
    }
}
