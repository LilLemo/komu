import Foundation
import SwiftData
import SwiftUI

@Observable
class MarketSessionViewModel {
    var currentSession: ShoppingSession?
    var timer: Timer?
    var elapsedTime: TimeInterval = 0
    
    // Temporary state for the "Picking" sheet
    var selectedItem: GroceryItem?
    var priceInput: String = ""
    var quantityInput: Int = 1
    var isPromoInput: Bool = false
    
    init(session: ShoppingSession? = nil) {
        self.currentSession = session
    }
    
    func startTimer() {
        self.elapsedTime = 0
        
        // Start Timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.elapsedTime += 1
        }
    }
    
    func endSession() {
        timer?.invalidate()
        timer = nil
        currentSession?.endTime = Date()
        
        // Calculate totals
        if let session = currentSession {
            let total = session.items.reduce(0.0) { $0 + ($1.actualPrice ?? 0) * Double($1.quantity) }
            session.totalCost = total
        }
    }
    
    func pickItem(_ item: GroceryItem, price: Double, quantity: Int, isPromo: Bool) {
        item.status = .bought
        item.actualPrice = price
        item.quantity = quantity
        item.isPromo = isPromo
        
        // Link to session
        if let session = currentSession {
            if !session.items.contains(item) {
                session.items.append(item)
            }
        }
        
        // Reset inputs
        selectedItem = nil
        priceInput = ""
        quantityInput = 1
    }
    
    func selectItemForPicking(_ item: GroceryItem) {
        selectedItem = item
        priceInput = item.estimatedPrice.map { String($0) } ?? ""
        quantityInput = item.quantity
        isPromoInput = item.isPromo
    }
    
    func formattedTime() -> String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func formattedTotal() -> String {
        guard let session = currentSession else { return "R$ 0,00" }
        // Calculate total on the fly based on bought items
        // Since we are in an observable class, this might not auto-update if we don't observe items.
        // However, SwiftData objects are observable.
        // But `currentSession.items` is a relationship.
        // A safer bet for real-time updates in the View is to let the View calculate it or use a computed property that depends on observed properties.
        // But here in ViewModel, we can access it.
        // Note: For the View to update when items change, the View needs to observe the items.
        // The View has `@Query itemsToBuy`.
        // So the View should pass the total or we rely on SwiftData observation.
        // Let's try calculating here.
        let total = session.items.reduce(0.0) { $0 + ($1.actualPrice ?? 0) * Double($1.quantity) }
        return String(format: "R$ %.2f", total)
    }
}
