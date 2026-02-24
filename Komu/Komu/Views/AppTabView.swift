import SwiftUI
import SwiftData

struct AppTabView: View {
    @State private var navigationManager = NavigationManager()
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            HomeView()
                .environment(navigationManager)
                .tabItem {
                    Label("Início", systemImage: "house")
                }
            
            HistoryView()
                .environment(navigationManager)
                .tabItem {
                    Label("Histórico", systemImage: "clock.arrow.circlepath")
                }
            
            ProfileView()
                .environment(navigationManager)
                .tabItem {
                    Label("Perfil", systemImage: "person.crop.circle")
                }
        }
        .onAppear {
            navigationManager.modelContext = modelContext
            navigationManager.loadInitialList()
        }
    }
}
