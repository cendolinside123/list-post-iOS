import Foundation

@MainActor
protocol PostListViewModelProtocol {
    var posts: [Post] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    
    var searchText: String? { get set }
    var userId: Int? { get set }
    
    var visiblePosts: [Post] { get }
    
    func loadPosts() async
}


final class PostListViewModel: ObservableObject, PostListViewModelProtocol {
    @Published private(set) var posts: [Post] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published var searchText: String?
    
    @Published var userId: Int?

    private let useCase: PostUseCase
    
    init(useCase: PostUseCase) {
        self.useCase = useCase
    }

    var visiblePosts: [Post] {
        
        if let keyword = searchText?.trimmingCharacters(in: .whitespacesAndNewlines),
            !keyword.isEmpty {
            return posts
                .filter({
                    $0.title.localizedCaseInsensitiveContains(keyword)
                })
        } else {
            return posts
        }
        
    }

    func loadPosts() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            posts = try await useCase.fetchPosts(
                userId: userId
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
