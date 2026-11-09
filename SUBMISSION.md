# PostsApp — Project Overview & Documentation

**PostsApp** is an iOS application built with **SwiftUI**, **Swift Concurrency (`async/await`)**, and **Clean Architecture + MVVM**. It fetches posts and users from the JSONPlaceholder REST API, providing real-time keyword search, server-side user filtering, resilient error handling, and full unit test coverage via dependency injection.

---

## 1. Architecture & Data Flow

### Networking & Data Layer
- **Generic Data Source (`RemoteDataSource` / `DataSourceProtocol`):**
  - Low-level HTTP request construction (`URLComponents`, query parameters, headers, HTTP status code validation `200...299`, and generic `JSONDecoder` decoding) is centralized in `RemoteDataSource.fetch(...)` (`PostsApp/Utils/Data/RemoteDataSource.swift`) conforming to `DataSourceProtocol`.
- **Services & DTOs:**
  - `PostService` (`GET /posts`) and `UserServiceImpl` (`GET /users`) depend on `DataSourceProtocol`, decode API responses (`PostResponse`, `UsersResponse`), and convert them into domain models (`[Post]`, `[User]`) using `PostMapper` and `UserMapper`.

### Domain & UseCase Layer
- **UseCases (`PostUseCaseImpl` & `UserUseCaseImpl`):**
  - Encapsulate business logic and request parameters (such as `PostQuery` for filtering posts by `userId`) between the ViewModels and Data Services.
- **Domain Models (`Post` & `User`):**
  - Lightweight, `Identifiable` and `Equatable` value types decoupled from network DTO representations.

### Presentation & State Management (MVVM + DI)
- **`PostListViewModel` (`PostsApp/ViewModels/Post/PostListViewModel.swift`):**
  - An `@MainActor` `ObservableObject` owned by `PostListView` via `@StateObject`.
  - Manages `@Published private(set) var posts: [Post]`, `@Published private(set) var isLoading: Bool`, `@Published private(set) var errorMessage: String?`, `@Published var searchText: String?`, `@Published var userId: Int?`, and the computed property `visiblePosts: [Post]`.
- **`ListUserViewModel` (`PostsApp/ViewModels/User/ListUserViewModel.swift`):**
  - Manages the user directory state (`@Published private(set) var user: [User]`, `isLoading`, and `errorMessage`) for the user filter sheet.
- **Dependency Injection (`PostViewModelInjection` & `ListUserViewModelInjection`):**
  - Factory protocols and implementations (`PostViewModelInjectionImpl`, `ListUserViewModelInjectionImpl`) assemble the Data Source, Services, UseCases, and ViewModels cleanly for both production and unit test environments.

### Reactive UI Updates
- `PostListView` triggers `await viewModel.loadPosts()` inside `.task(id: viewModel.userId)` on initial appearance and whenever the selected `userId` filter changes (as well as via pull-to-refresh, the toolbar reload button, or the empty-state Retry button).
- Because `PostListViewModel` runs on `@MainActor` and conforms to `ObservableObject`, updates to `@Published` properties automatically re-evaluate `PostListView.body` and update `List(viewModel.visiblePosts)`, loading indicators, empty states, and toast banners.

---

## 2. Key Features & Design Decisions

1. **Real-Time Keyword Search (`visiblePosts`):**
   - Filters loaded posts case-insensitively by `title` (with whitespace trimming) for immediate, zero-latency feedback as the user types in the toolbar search bar.
2. **Filter by User (`ListPersonView`):**
   - Presents a modal sheet fetching the user directory from `/users` so users can browse names alongside IDs, select a user (or tap **Reset**), and reload `/posts?userId=<id>`.
3. **Non-Destructive Reloads & Context-Aware Error Handling:**
   - **Preserved state on failed refresh:** If a reload or pull-to-refresh fails when posts or users are already loaded, existing items remain visible on screen instead of being cleared.
   - **Empty & Error State Modifier (`EmptyState.swift`):**
     - **Error when list is empty (`error != nil && isDataEmpty`):** Displays a full-screen `EmptyStateView` with the error description and a **Retry** action.
     - **Empty data / no matching results (`error == nil && isDataEmpty`):** Displays `EmptyStateView` without the Retry button when a search keyword or user filter returns no matches.
     - **Error when data is already displayed (`error != nil && !isDataEmpty`):** Keeps the existing list visible and presents a queued, non-intrusive bottom toast banner via `ToastManager` and `ToastView`.
4. **Modular Reusable Views:**
   - List row cells are extracted into dedicated, previewable components (`PostListItemView` and `ListPersonItemView` under `PostsApp/Views/CustomView/Cell/`).

---

## 3. Verification & Testing

### Manual Usage Flow
1. Launch the app and type a keyword (e.g., `"qui"` or `"sunt"`) into the top toolbar **Search** field to filter post titles in real time. Clear the text to restore all posts.
2. Tap the **Person (`person`)** icon in the top-right toolbar to open the **List User** sheet (`ListPersonView`).
3. Select a user and tap **Ok**; the toolbar icon highlights in blue and `PostListView` loads posts for that `userId`.
4. Re-open the sheet and tap **Reset** to clear the user filter and load all posts again.

### Unit Tests (`PostsAppTests`)
- Uses `MockDataSource` (conforming to `DataSourceProtocol`) and mock injection factories (`MockPostServiceInjection`, `MockUserServiceInjection`) to test the full stack (`DataSourceProtocol` $\rightarrow$ `Service` $\rightarrow$ `UseCase` $\rightarrow$ `ViewModel`) without network calls:
  - **`PostListViewModelTests`:** Covers successful post loading, HTTP/network error handling, preserving existing posts on failed reload, `userId` query filtering, case-insensitive title search, toast notifications, and `reloadData()`.
  - **`ListUserViewModelTests`:** Covers user list loading, error state handling, preserving existing users on failed reload, and `reloadData()`.

---

## 4. Future Roadmap & Potential Enhancements

1. **Extended Search & Debouncing:**
   - Expand search matching to include `post.body` in addition to `post.title`, and add debouncing for server-side search queries.
2. **User Filter Sheet Enhancements (`ListPersonView`):**
   - Add a search bar inside `ListPersonView` to filter users by `name`.
   - Pin the currently active/selected `User` (`id == idUser`) to the top of the list for quick visibility.
3. **Dedicated Preview Dependency Injection:**
   - Provide `PreviewPostViewModelInjection` and `PreviewListUserViewModelInjection` backed by static mock data so Xcode `#Preview` canvases render populated, empty, and error states offline.
4. **Offline Caching & Favorites:**
   - Persist posts, users, and bookmarked favorite posts locally using `SwiftData` or `UserDefaults` for offline reading.
5. **Automated UI & Snapshot Tests:**
   - Add `XCUITest` suites leveraging the existing accessibility identifiers (`search.box`, `open.user.menu`, `post.item.<id>`).
