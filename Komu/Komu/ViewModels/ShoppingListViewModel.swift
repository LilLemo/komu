import Foundation
import SwiftData
import SwiftUI

@Observable
class ShoppingListViewModel {
    var modelContext: ModelContext?
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    func addItem(name: String, quantity: Int, category: GroceryCategory, authorName: String, list: ShoppingList?) {
        let newItem = GroceryItem(name: name, quantity: quantity, category: category, authorName: authorName)
        newItem.list = list
        modelContext?.insert(newItem)
    }
    
    func deleteItems(at offsets: IndexSet, from items: [GroceryItem]) {
        for index in offsets {
            let item = items[index]
            modelContext?.delete(item)
        }
    }
    
    func toggleItemStatus(_ item: GroceryItem) {
        if item.status == .pending {
            item.status = .inCart
        } else {
            item.status = .pending
        }
    }
    
    // Helper to group items by category
    func itemsByCategory(_ items: [GroceryItem]) -> [GroceryCategory: [GroceryItem]] {
        Dictionary(grouping: items, by: { $0.category })
    }
}
