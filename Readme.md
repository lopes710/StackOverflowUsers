# StackOverflow Users

Small iOS application that fetches and displays the top 20 StackOverflow users by reputation.

The app shows each user's profile image, name and reputation, and allows the user to follow/unfollow users locally. Follow state is persisted between app sessions.

## Requirements

- iOS 15.6+
- Swift
- UIKit
- No third-party dependencies

## How to run

1. Clone the repository.
2. Open `StackOverflowUsers.xcodeproj` in Xcode.
3. Select the `StackOverflowUsers` scheme.
4. Run the app on a simulator or device.

## Architecture

The project uses MVVM architecture.

The project follows SOLID principles, mainly Single Responsibility and Dependency Inversion. The ViewModel handles presentation state, the repository combines remote data with local follow state, the network client handles requests, and the followed users store handles persistence. The project also depends on protocols for the repository, network client and local followed users store, which makes the unit tests easier to write with mocks.

- `UsersViewController` owns the UIKit view and renders the current view state.
- `UsersViewModel` deals with the presentation state and handles user actions such as loading users and toggling follow state.
- `UsersRepository` combines remote API data with local and persisted follow state.
- `URLSessionNetworkClient` performs network requests.
- `UserDefaultsFollowedUsersStore` persists followed user IDs locally.
- `ImageLoader` loads profile images and keeps an in-memory cache to avoid repeated downloads and reduce image flickering during cell reuse.

The repository maps API DTOs into domain `User` models. Since the StackOverflow API does not return follow state, the repository also checks the local followed users store when creating the domain models.

## Follow / Unfollow

Follow functionality is local only.

The app stores followed user IDs in `UserDefaults`. When users are fetched again, the repository applies the stored follow state to the returned users.

## Error Handling

If loading users fails, the app shows an empty state with an error message.

## Testing

The project includes unit tests for:

- `UsersViewModel`
- `UserDefaultsFollowedUsersStore`
- `UsersRepository`
