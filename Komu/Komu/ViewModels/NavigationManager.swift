import Foundation
import SwiftData
import SwiftUI

@Observable
class NavigationManager {
    var selectedList: ShoppingList?
    var modelContext: ModelContext?
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    func loadInitialList() {
        guard let context = modelContext else { return }
        
        // Fetch current user to get household
        var userDescriptor = FetchDescriptor<User>(predicate: #Predicate<User> { $0.isCurrentUser == true })
        
        do {
            let users = try context.fetch(userDescriptor)
            guard let user = users.first, let household = user.household else {
                // Fallback if no household (shouldn't happen with new flow)
                return
            }
            
            // Fetch lists for this household
            // Note: SwiftData predicates with relationships can be tricky.
            // We can fetch the household and access .lists, or query lists where household == ...
            // Let's try accessing via the household object if possible, or query.
            // Query is safer for updates.
            let householdId = household.id
            var listDescriptor = FetchDescriptor<ShoppingList>(
                predicate: #Predicate<ShoppingList> { $0.household?.id == householdId },
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            listDescriptor.fetchLimit = 1
            
            let lists = try context.fetch(listDescriptor)
            if let firstList = lists.first {
                self.selectedList = firstList
            } else {
                createDefaultList(for: household)
            }
            
        } catch {
            print("Failed to fetch lists: \(error)")
        }
    }
    
    func createDefaultList(for household: Household) {
        guard let context = modelContext else { return }
        let defaultList = ShoppingList(name: "Minha Lista", colorName: "PastelBlue")
        defaultList.household = household
        context.insert(defaultList)
        self.selectedList = defaultList
    }
    
    func createList(name: String, colorName: String) {
        guard let context = modelContext else { return }
        
        // Need to find the household again or store it
        // Let's fetch user again to be safe
        var userDescriptor = FetchDescriptor<User>(predicate: #Predicate<User> { $0.isCurrentUser == true })
        if let user = try? context.fetch(userDescriptor).first, let household = user.household {
            let newList = ShoppingList(name: name, colorName: colorName)
            newList.household = household
            context.insert(newList)
            self.selectedList = newList
        }
    }
    
    func selectList(_ list: ShoppingList?) {
        self.selectedList = list
    }
}
