import SwiftUI
import SwiftData

@main
struct KomuApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            ShoppingList.self,
            GroceryItem.self,
            ShoppingSession.self,
        ])
        let modelConfiguration = ModelConfiguration("KomuV2", schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}

struct RootView: View {
    @Query(filter: #Predicate<User> { $0.isCurrentUser == true }) private var currentUsers: [User]
    
    var body: some View {
        Group {
            if let _ = currentUsers.first {
                AppTabView()
            } else {
                OnboardingView()
            }
        }
    }
}
