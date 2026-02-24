import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(NavigationManager.self) private var navManager
    
    @Query(filter: #Predicate<User> { $0.isCurrentUser == true }) private var currentUsers: [User]
    
    var currentUser: User? { currentUsers.first }
    var household: Household? { currentUser?.household }
    
    // We can't easily query lists by household relationship in @Query in all SwiftData versions yet without complex predicates.
    // So we'll fetch all lists and filter, OR rely on the household object.
    // Relying on household.lists is easier but requires the household to be refreshed.
    // Let's use a Query for lists and filter in memory for MVP stability.
    @Query(sort: \ShoppingList.createdAt, order: .reverse) private var allLists: [ShoppingList]
    
    var myLists: [ShoppingList] {
        guard let household = household else { return [] }
        return allLists.filter { $0.household == household }
    }
    
    @State private var isCreatingList = false
    @State private var newListName = ""
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Olá, \(currentUser?.name ?? "Usuário")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(household?.name ?? "Minha Casa")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: { isCreatingList = true }) {
                        Label("Nova Lista", systemImage: "plus")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    if let firstList = myLists.first {
                        NavigationLink(destination: {
                            // Navigate to the most recent list
                            ShoppingListView()
                                .onAppear { navManager.selectList(firstList) }
                        }) {
                            Label("Ir às Compras", systemImage: "cart")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Lists Grid/List
                Text("Minhas Listas")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                if myLists.isEmpty {
                    ContentUnavailableView("Nenhuma lista", systemImage: "list.bullet.clipboard", description: Text("Crie uma lista para começar."))
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(myLists) { list in
                                NavigationLink(destination: {
                                    ShoppingListView()
                                        .onAppear { navManager.selectList(list) }
                                }) {
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Circle()
                                                .fill(Color(list.colorName) ?? .blue)
                                                .frame(width: 12, height: 12)
                                            Spacer()
                                            Text("\(list.items.count)")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .padding(6)
                                                .background(Color.gray.opacity(0.1))
                                                .clipShape(Circle())
                                        }
                                        
                                        Text(list.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                            .lineLimit(2)
                                        
                                        Text(list.createdAt.formatted(date: .abbreviated, time: .omitted))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .notionCard()
                                    .contextMenu {
                                        ShareLink(item: generateShareText(for: list)) {
                                            Label("Compartilhar", systemImage: "square.and.arrow.up")
                                        }
                                        
                                        Button(role: .destructive) {
                                            deleteList(list)
                                        } label: {
                                            Label("Excluir", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .background(Color.offWhite)
            .navigationBarHidden(true)
            .sheet(isPresented: $isCreatingList) {
                NavigationStack {
                    Form {
                        TextField("Nome da Lista", text: $newListName)
                    }
                    .navigationTitle("Nova Lista")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancelar") { isCreatingList = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Criar") {
                                navManager.createList(name: newListName, colorName: "PastelBlue")
                                newListName = ""
                                isCreatingList = false
                            }
                            .disabled(newListName.isEmpty)
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
    
    private func deleteList(_ list: ShoppingList) {
        if navManager.selectedList == list {
            navManager.selectList(nil)
        }
        modelContext.delete(list)
    }
    
    private func generateShareText(for list: ShoppingList) -> String {
        var text = "🛒 Lista: \(list.name)\n\n"
        
        let items = list.items
        if !items.isEmpty {
            let pendingItems = items.filter { $0.statusRaw == "pending" }
            if !pendingItems.isEmpty {
                text += "📝 A Comprar:\n"
                for item in pendingItems {
                    text += "- \(item.name) (\(item.quantity)x)\n"
                }
                text += "\n"
            }
            
            let boughtItems = items.filter { $0.statusRaw == "inCart" || $0.statusRaw == "bought" }
            if !boughtItems.isEmpty {
                text += "✅ Comprados:\n"
                for item in boughtItems {
                    text += "- \(item.name)\n"
                }
            }
        } else {
            text += "(Lista vazia)"
        }
        
        return text
    }
}
