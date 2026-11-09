import SwiftUI

struct PostListView: View {
    @StateObject private var viewModel: PostListViewModel
    @StateObject private var listUserViewModel: ListUserViewModel
    
    @State private var displayMenuUser: Bool = false

    @MainActor
    init(
        factory: PostViewModelInjection,
        listUserFactory: ListUserViewModelInjection
    ) {
        _viewModel = StateObject(
            wrappedValue: factory.makePostViewModel()
        )
        
        _listUserViewModel = StateObject(
            wrappedValue: listUserFactory.makeListUserViewModel()
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                HStack {
                    Text("Posts")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                }.padding(.horizontal)
                
                Spacer()
                
                if viewModel.isLoading && !viewModel.posts.isEmpty {
                    ProgressView("Loading posts...")
                }
                
                List(viewModel.visiblePosts) { post in
                    PostListItemView(post: post)
                }
                .emptyState(
                    error: viewModel.errorMessage,
                    isDataEmpty: viewModel.visiblePosts.isEmpty,
                    isLoading: viewModel.isLoading,
                    retry: {
                        Task {
                            await viewModel.loadPosts()
                        }
                    }
                )
                .refreshable {
                    await viewModel.loadPosts()
                }
                .overlay {
                    if viewModel.isLoading && viewModel.posts.isEmpty {
                        ProgressView("Loading posts...")
                    }
                }
                Spacer()
            }
            .task(id: viewModel.userId) {
                await viewModel.loadPosts()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup {
                    TextField(
                        "Search",
                        text: Binding(
                            get: {
                                viewModel.searchText ?? ""
                            }, set: { value ,_ in
                                viewModel.searchText = value
                            }
                        )
                    ).textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                        .padding(.leading, 10)
                        .accessibilityLabel("search.box")
                    
                    Button {
                        Task {
                            await viewModel.loadPosts()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    }
                    
                    Button {
                        displayMenuUser.toggle()
                    } label: {
                        Image(systemName: "person")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .background(
                                RoundedRectangle(
                                    cornerRadius: 5,
                                    style:.continuous
                                )
                                .fill(
                                    viewModel.userId != nil ? .blue : .white
                                )
                            )
                    }
                    .sheet(
                        isPresented: $displayMenuUser,
                        content: {
                            ListPersonView(
                                viewModel: listUserViewModel,
                                idUser: $viewModel.userId
                            )
                        }
                    )
                    .accessibilityLabel("open.user.menu")
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    PostListView(
        factory: PostViewModelInjectionImpl.shared,
        listUserFactory: ListUserViewModelInjectionImpl.shared
    )
}
#endif
