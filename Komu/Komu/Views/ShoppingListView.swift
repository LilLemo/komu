import SwiftUI
import SwiftData

struct ShoppingListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(NavigationManager.self) private var navManager
    
    // Fetch all pending items and filter in memory for MVP simplicity
    @Query(filter: #Predicate<GroceryItem> { $0.statusRaw == "pending" }, sort: \GroceryItem.createdAt) private var allPendingItems: [GroceryItem]
    
    var items: [GroceryItem] {
        guard let selectedList = navManager.selectedList else { return [] }
        return allPendingItems.filter { $0.list == selectedList }
    }
    
    @State private var viewModel = ShoppingListViewModel()
    @State private var isShowingAddSheet = false
    @State private var isShowingListPicker = false
    
    @State private var isStartingSession = false
    
    // Add Item State
    @State private var newItemName = ""
    @State private var newItemQuantity = 1
    @State private var newItemCategory: GroceryCategory = .other
    
    @State private var createdSession: ShoppingSession?
    
    func startMarketSession() {
        let newSession = ShoppingSession()
        newSession.list = navManager.selectedList
        modelContext.insert(newSession)
        createdSession = newSession
        isStartingSession = true
    }
    
    var body: some View {
        mainContent
            .navigationTitle(navManager.selectedList?.name ?? "Lista")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isShowingListPicker = true }) {
                        Image(systemName: "list.bullet")
                    }
                }
                
                if let list = navManager.selectedList, list.isCompleted {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ShareLink(item: generateExportText(for: list)) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $isStartingSession) {
                if let session = createdSession {
                    ActiveSessionView(session: session, onFinish: {
                        // Mark list as completed when session finishes
                        if let list = navManager.selectedList {
                            list.isCompleted = true
                            // Also update items status to bought if they were in the session
                            // (Logic usually handled in ActiveSessionViewModel, but ensuring here)
                        }
                        isStartingSession = false
                    })
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                AddItemSheet(
                    name: $newItemName,
                    quantity: $newItemQuantity,
                    category: $newItemCategory,
                    onAdd: {
                        viewModel.modelContext = modelContext
                        viewModel.addItem(
                            name: newItemName,
                            quantity: newItemQuantity,
                            category: newItemCategory,
                            authorName: "Eu",
                            list: navManager.selectedList
                        )
                        newItemName = ""
                        newItemQuantity = 1
                        newItemCategory = .other
                        isShowingAddSheet = false
                    }
                )
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $isShowingListPicker) {
                ListPickerSheet(navManager: navManager)
            }
            .onAppear {
                viewModel.modelContext = modelContext
            }
    }
    
    var mainContent: some View {
        ZStack(alignment: .bottom) {
            Color.offWhite.ignoresSafeArea()
            
            if let list = navManager.selectedList, list.isCompleted {
                // Completed List View
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            Text("Compra Finalizada")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("Esta lista foi concluída.")
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 40)
                        
                        // Summary of items
                        VStack(alignment: .leading, spacing: 12) {
                            Text("RESUMO DA COMPRA")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            
                            ForEach(list.items) { item in
                                HStack {
                                    Text("\(item.quantity)x \(item.name)")
                                    Spacer()
                                    if let price = item.actualPrice {
                                        Text(String(format: "R$ %.2f", price * Double(item.quantity)))
                                            .fontWeight(.bold)
                                    } else {
                                        Text("-")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Divider()
                            }
                            
                            HStack {
                                Text("TOTAL")
                                    .fontWeight(.black)
                                Spacer()
                                let total = list.items.reduce(0.0) { $0 + ($1.actualPrice ?? 0) * Double($1.quantity) }
                                Text(String(format: "R$ %.2f", total))
                                    .fontWeight(.black)
                            }
                            .padding(.top, 8)
                        }
                        .notionCard()
                    }
                    .padding()
                }
            } else {
                // Active List View
                ScrollView {
                    VStack(spacing: 16) {
                        if items.isEmpty {
                            EmptyStateView()
                        } else {
                            ForEach(GroceryCategory.allCases) { category in
                                if let categoryItems = viewModel.itemsByCategory(items)[category], !categoryItems.isEmpty {
                                    CategorySection(category: category, items: categoryItems)
                                }
                            }
                        }
                        
                        Spacer().frame(height: 100) // Space for floating button
                    }
                    .padding()
                }
                
                VStack(spacing: 12) {
                    // Bottom Action Buttons
                    HStack(spacing: 12) {
                        // Add Item Button
                        Button(action: { isShowingAddSheet = true }) {
                            VStack {
                                Image(systemName: "plus")
                                    .font(.title2)
                                Text("Adicionar")
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 80)
                            .background(Color.white)
                            .foregroundColor(.blue)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        
                        // Start Market Button
                        if !items.isEmpty {
                            Button(action: {
                                startMarketSession()
                            }) {
                                VStack {
                                    Image(systemName: "cart.fill")
                                        .font(.title2)
                                    Text("Iniciar Compras")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 80)
                                .background(Color.green) // "Verde bonitinho"
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
        }
    }
    

    // Helper to generate text for sharing/export
    private func generateExportText(for list: ShoppingList) -> String {
        var text = "🛒 Lista: \(list.name)\n"
        text += "📅 Data: \(list.createdAt.formatted(date: .numeric, time: .shortened))\n"
        text += "--------------------------------------------------\n"
        text += "Item | Qtd | Preço Unit. | Total | Quem pediu\n"
        text += "--------------------------------------------------\n"
        
        let items = list.items
        var grandTotal = 0.0
        
        for item in items {
            let price = item.actualPrice ?? 0.0
            let total = price * Double(item.quantity)
            grandTotal += total
            
            let line = "\(item.name) | \(item.quantity) | R$ \(String(format: "%.2f", price)) | R$ \(String(format: "%.2f", total)) | \(item.authorName)\n"
            text += line
        }
        
        text += "--------------------------------------------------\n"
        text += "TOTAL GERAL: R$ \(String(format: "%.2f", grandTotal))\n"
        
        return text
    }
}

struct CategorySection: View {
    let category: GroceryCategory
    let items: [GroceryItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: category.icon)
                Text(category.rawValue)
                    .font(.headline)
            }
            .foregroundColor(.secondary)
            
            ForEach(items) { item in
                GroceryItemRow(item: item)
            }
        }
    }
}

struct GroceryItemRow: View {
    let item: GroceryItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.system(size: 18, weight: .medium))
                Text("\(item.quantity) un • \(item.authorName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "circle")
                .foregroundColor(.gray)
        }
        .notionCard()
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("Sua lista está vazia")
                .font(.title3)
                .fontWeight(.medium)
            Text("Adicione itens para começar a planejar suas compras.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }
}

struct AddItemSheet: View {
    @Binding var name: String
    @Binding var quantity: Int
    @Binding var category: GroceryCategory
    let onAdd: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nome do item (ex: Leite)", text: $name)
                    Stepper("Quantidade: \(quantity)", value: $quantity, in: 1...100)
                }
                
                Section("Categoria") {
                    Picker("Categoria", selection: $category) {
                        ForEach(GroceryCategory.allCases) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
            }
            .navigationTitle("Novo Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Adicionar") {
                        onAdd()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// Update ListPickerSheet to show completed status
struct ListPickerSheet: View {
    @Bindable var navManager: NavigationManager
    @Environment(\.dismiss) private var dismiss
    
    @Query private var allLists: [ShoppingList]
    @Query(filter: #Predicate<User> { $0.isCurrentUser == true }) private var currentUsers: [User]
    
    @Environment(\.modelContext) private var modelContext
    
    var householdLists: [ShoppingList] {
        guard let user = currentUsers.first, let household = user.household else { return [] }
        return allLists.filter { $0.household == household }
    }
    
    @State private var isCreatingList = false
    @State private var newListName = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section("Listas da Casa") {
                    ForEach(householdLists) { list in
                        Button(action: {
                            navManager.selectList(list)
                            dismiss()
                        }) {
                            HStack {
                                Text(list.name)
                                    .foregroundColor(list.isCompleted ? .secondary : .primary)
                                Spacer()
                                if list.isCompleted {
                                    Text("Concluída")
                                        .font(.caption)
                                        .padding(4)
                                        .background(Color.green.opacity(0.2))
                                        .foregroundColor(.green)
                                        .cornerRadius(4)
                                }
                                if navManager.selectedList == list {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .contextMenu {
                            // Share Button
                            ShareLink(item: generateExportText(for: list)) {
                                Label("Exportar", systemImage: "square.and.arrow.up")
                            }
                            
                            // Delete Button
                            Button(role: .destructive) {
                                deleteList(list)
                            } label: {
                                Label("Excluir", systemImage: "trash")
                            }
                        }
                    }
                }
                
                Section {
                    Button("Criar Nova Lista") {
                        isCreatingList = true
                    }
                }
            }
            .navigationTitle("Trocar Lista")
            // ... (rest of sheet logic)
        }
    }
    
    private func deleteList(_ list: ShoppingList) {
        if navManager.selectedList == list {
            navManager.selectList(nil)
        }
        modelContext.delete(list)
    }
    
    // Helper to generate text for sharing/export
    private func generateExportText(for list: ShoppingList) -> String {
        var text = "🛒 Lista: \(list.name)\n"
        text += "📅 Data: \(list.createdAt.formatted(date: .numeric, time: .shortened))\n"
        text += "--------------------------------------------------\n"
        text += "Item | Qtd | Preço Unit. | Total | Quem pediu\n"
        text += "--------------------------------------------------\n"
        
        let items = list.items
        var grandTotal = 0.0
        
        for item in items {
            let price = item.actualPrice ?? 0.0
            let total = price * Double(item.quantity)
            grandTotal += total
            
            let line = "\(item.name) | \(item.quantity) | R$ \(String(format: "%.2f", price)) | R$ \(String(format: "%.2f", total)) | \(item.authorName)\n"
            text += line
        }
        
        text += "--------------------------------------------------\n"
        text += "TOTAL GERAL: R$ \(String(format: "%.2f", grandTotal))\n"
        
        return text
    }
}
