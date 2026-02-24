import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(NavigationManager.self) private var navManager
    
    @Query(filter: #Predicate<User> { $0.isCurrentUser == true }) private var currentUsers: [User]
    @Query(sort: \ShoppingSession.startTime, order: .reverse) private var allSessions: [ShoppingSession]
    @Query(filter: #Predicate<GroceryItem> { $0.statusRaw == "bought" }) private var boughtItems: [GroceryItem]
    
    var currentUser: User? { currentUsers.first }
    var household: Household? { currentUser?.household }
    
    @State private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 1. User Profile Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(currentUser?.avatarColor ?? "PastelBlue") ?? .blue)
                                .frame(width: 100, height: 100)
                                .shadow(radius: 5)
                            Text(currentUser?.avatarEmoji ?? "🙂")
                                .font(.system(size: 50))
                        }
                        
                        VStack(spacing: 4) {
                            Text(currentUser?.name ?? "Usuário")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(household?.name ?? "Sem Casa")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top)
                    
                    // 2. Household Members
                    if let household = household {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Membros da Casa")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(household.members) { member in
                                        VStack {
                                            ZStack {
                                                Circle()
                                                    .fill(Color(member.avatarColor) ?? .gray)
                                                    .frame(width: 60, height: 60)
                                                Text(member.avatarEmoji)
                                                    .font(.title)
                                            }
                                            Text(member.name)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                        }
                                    }
                                    
                                    // Share Code Button
                                    ShareLink(item: household.joinCode) {
                                        VStack {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.gray.opacity(0.1))
                                                    .frame(width: 60, height: 60)
                                                Image(systemName: "plus")
                                                    .font(.title2)
                                                    .foregroundColor(.blue)
                                            }
                                            Text("Convidar")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // 3. Statistics Grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Estatísticas")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            // Most Expensive Item
                            StatBox(
                                icon: "tag.fill",
                                color: .orange,
                                title: "Item + Caro",
                                value: viewModel.mostExpensiveItem?.name ?? "--",
                                subValue: viewModel.mostExpensiveItem?.actualPrice.map { String(format: "R$ %.2f", $0) } ?? ""
                            )
                            
                            // Longest Session
                            StatBox(
                                icon: "clock.fill",
                                color: .purple,
                                title: "Sessão + Longa",
                                value: viewModel.longestSession.map { viewModel.formatDuration($0.duration) } ?? "--",
                                subValue: viewModel.longestSession?.startTime.formatted(date: .abbreviated, time: .omitted) ?? ""
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // 4. Monthly Spending
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Gastos Mensais")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            if viewModel.monthlySpendingHistory.isEmpty {
                                Text("Sem histórico de gastos ainda.")
                                    .padding()
                                    .foregroundColor(.secondary)
                            } else {
                                ForEach(viewModel.monthlySpendingHistory, id: \.month) { record in
                                    HStack {
                                        Text(viewModel.monthName(from: record.month))
                                            .fontWeight(.medium)
                                        Spacer()
                                        Text(String(format: "R$ %.2f", record.total))
                                            .fontWeight(.bold)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    
                                    if record.month != viewModel.monthlySpendingHistory.last?.month {
                                        Divider()
                                            .padding(.leading)
                                    }
                                }
                            }
                        }
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 50)
                }
            }
            .background(Color.offWhite)
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.modelContext = modelContext
                viewModel.calculateStats(sessions: allSessions, items: boughtItems)
            }
        }
    }
}

struct StatBox: View {
    let icon: String
    let color: Color
    let title: String
    let value: String
    let subValue: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline)
                    .lineLimit(1)
                if !subValue.isEmpty {
                    Text(subValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .notionCard()
    }
}
