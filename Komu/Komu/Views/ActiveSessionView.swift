import SwiftUI
import SwiftData

struct ActiveSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(NavigationManager.self) private var navManager
    
    var session: ShoppingSession
    var onFinish: () -> Void
    
    // Fetch ALL items for the list (pending and bought)
    // We filter by list in memory to avoid complex predicates
    @Query(sort: \GroceryItem.name) private var allItems: [GroceryItem]
    
    var itemsToBuy: [GroceryItem] {
        guard let selectedList = navManager.selectedList else { return [] }
        return allItems.filter { $0.list == selectedList }
    }
    
    @State private var viewModel: MarketSessionViewModel
    @State private var isShowingPickSheet = false
    @State private var isShowingSummary = false
    @State private var isShowingAddItem = false
    
    // Add Item State
    @State private var newItemName = ""
    @State private var newItemQuantity = 1
    @State private var newItemCategory: GroceryCategory = .other
    
    init(session: ShoppingSession, onFinish: @escaping () -> Void) {
        self.session = session
        self.onFinish = onFinish
        self._viewModel = State(initialValue: MarketSessionViewModel(session: session))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Header: Timer & Status
                HStack {
                    VStack(alignment: .leading) {
                        Text("MOMENTO MERCADO")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        // Show Timer OR Total Value
                        // User requested "Calculadora Inteligente" behavior
                        // Let's show both? Or toggle?
                        // "mostrando em cima quanto esta o valor total da compra atualmente"
                        // Let's show Total prominently, and Timer smaller or below.
                        
                        Text(viewModel.formattedTotal())
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.green)
                        
                        HStack {
                            Image(systemName: "clock")
                            Text(viewModel.formattedTime())
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                    }
                    Spacer()
                    Button(action: {
                        viewModel.endSession()
                        isShowingSummary = true
                    }) {
                        Text("Finalizar")
                            .fontWeight(.semibold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color.white)
                
                // List of items
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(itemsToBuy) { item in
                            Button(action: {
                                viewModel.selectItemForPicking(item)
                                isShowingPickSheet = true
                            }) {
                                HStack {
                                    Image(systemName: item.category.icon)
                                        .foregroundColor(.secondary)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading) {
                                        Text(item.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                            .strikethrough(item.status == .bought)
                                        
                                        HStack {
                                            Text("\(item.quantity) un")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            
                                            if item.status == .bought, let price = item.actualPrice {
                                                Text("•")
                                                    .foregroundColor(.secondary)
                                                    .font(.caption)
                                                Text(String(format: "R$ %.2f", price))
                                                    .font(.caption)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(item.isPromo ? .orange : .primary)
                                            }
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    if item.status == .bought {
                                        Image(systemName: "checkmark")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(item.isPromo ? .orange : .green)
                                            .padding(8)
                                            .background(item.isPromo ? Color.orange.opacity(0.1) : Color.green.opacity(0.1))
                                            .clipShape(Circle())
                                    } else {
                                        Image(systemName: "circle")
                                            .font(.title2)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .background(item.isPromo ? Color.orange.opacity(0.05) : Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(item.isPromo ? Color.orange.opacity(0.3) : Color.gray.opacity(0.1), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding()
                    
                    // Add Item Button (Floating in ScrollView or Overlay?)
                    // Let's put it at the bottom of the list for simplicity
                    Button(action: {
                        isShowingAddItem = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Adicionar Item")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.offWhite)
            .navigationBarHidden(true)
            .onAppear {
                // Defer timer start to avoid feedback loop during transition
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.startTimer()
                }
            }
            .sheet(isPresented: $isShowingAddItem) {
                AddItemSheet(
                    name: $newItemName,
                    quantity: $newItemQuantity,
                    category: $newItemCategory,
                    onAdd: {
                        let newItem = GroceryItem(
                            name: newItemName,
                            quantity: newItemQuantity,
                            category: newItemCategory,
                            authorName: "Eu"
                        )
                        newItem.list = navManager.selectedList
                        modelContext.insert(newItem)
                        
                        newItemName = ""
                        newItemQuantity = 1
                        newItemCategory = .other
                        isShowingAddItem = false
                    }
                )
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $isShowingPickSheet) {
                if let item = viewModel.selectedItem {
                    PickItemSheet(
                        item: item,
                        priceInput: $viewModel.priceInput,
                        quantityInput: $viewModel.quantityInput,
                        isPromo: $viewModel.isPromoInput,
                        onConfirm: {
                            // Support comma for Brazilian locale
                            let formattedInput = viewModel.priceInput.replacingOccurrences(of: ",", with: ".")
                            if let price = Double(formattedInput) {
                                viewModel.pickItem(item, price: price, quantity: viewModel.quantityInput, isPromo: viewModel.isPromoInput)
                                isShowingPickSheet = false
                            }
                        }
                    )
                    .presentationDetents([.fraction(0.6), .medium]) // Increased height for preview
                }
            }
            .navigationDestination(isPresented: $isShowingSummary) {
                if let session = viewModel.currentSession {
                    SummaryView(session: session, onFinish: {
                        onFinish()
                    })
                }
            }
        }
    }
}

struct PickItemSheet: View {
    let item: GroceryItem
    @Binding var priceInput: String
    @Binding var quantityInput: Int
    @Binding var isPromo: Bool
    let onConfirm: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Pegando: \(item.name)")
                .font(.headline)
                .padding(.top)
            
            // Price Input
            HStack {
                Text("R$")
                    .font(.title2)
                    .fontWeight(.bold)
                TextField("0,00", text: $priceInput)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 40, weight: .bold))
                    .multilineTextAlignment(.center)
            }
            
            // Quantity & Promo Row
            HStack(spacing: 20) {
                // Quantity Stepper
                HStack {
                    Stepper(value: $quantityInput, in: 1...100) {
                        EmptyView()
                    }
                    .labelsHidden()
                    
                    Text("\(quantityInput)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(minWidth: 40)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Promo Toggle
                Button(action: { isPromo.toggle() }) {
                    HStack {
                        Image(systemName: isPromo ? "tag.fill" : "tag")
                        Text("PROMO")
                            .fontWeight(.bold)
                    }
                    .padding()
                    .frame(minWidth: 100)
                    .background(isPromo ? Color.orange.opacity(0.2) : Color.gray.opacity(0.1))
                    .foregroundColor(isPromo ? .orange : .gray)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isPromo ? Color.orange : Color.clear, lineWidth: 1)
                    )
                }
            }
            
            // Total Preview
            if let price = Double(priceInput.replacingOccurrences(of: ",", with: ".")) {
                HStack {
                    Text("Total do Item:")
                        .foregroundColor(.secondary)
                    Text(String(format: "R$ %.2f", price * Double(quantityInput)))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .font(.subheadline)
                .padding(.vertical, 4)
            }
            
            Button(action: onConfirm) {
                Text("Confirmar")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}
