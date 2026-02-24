import Foundation
import SwiftData

// MARK: - Enums

enum GroceryCategory: String, Codable, CaseIterable, Identifiable {
    case bakery = "Padaria"
    case produce = "Hortifruti"
    case meat = "Açougue"
    case dairy = "Laticínios"
    case pantry = "Despensa"
    case cleaning = "Limpeza"
    case drinks = "Bebidas"
    case other = "Outros"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .bakery: return "birthday.cake"
        case .produce: return "carrot"
        case .meat: return "fork.knife"
        case .dairy: return "cup.and.saucer"
        case .pantry: return "cabinet"
        case .cleaning: return "spray.bottle"
        case .drinks: return "wineglass"
        case .other: return "tag"
        }
    }
    
    var colorName: String {
        switch self {
        case .bakery: return "PastelYellow"
        case .produce: return "PastelGreen"
        case .meat: return "PastelRed"
        case .dairy: return "PastelBlue"
        case .pantry: return "PastelOrange"
        case .cleaning: return "PastelCyan"
        case .drinks: return "PastelPurple"
        case .other: return "PastelGray"
        }
    }
}

enum ItemStatus: String, Codable {
    case pending
    case inCart
    case bought
}

// MARK: - Models

@Model
final class User {
    var id: UUID
    var name: String
    var avatarColor: String // Hex string or asset name
    var avatarEmoji: String
    var isCurrentUser: Bool
    
    var household: Household?
    
    init(name: String, avatarColor: String = "Black", avatarEmoji: String = "🙂", isCurrentUser: Bool = false) {
        self.id = UUID()
        self.name = name
        self.avatarColor = avatarColor
        self.avatarEmoji = avatarEmoji
        self.isCurrentUser = isCurrentUser
    }
}

@Model
final class Household {
    var id: UUID
    var name: String
    var joinCode: String
    var createdAt: Date
    
    @Relationship(deleteRule: .nullify)
    var members: [User] = []
    
    @Relationship(deleteRule: .cascade)
    var lists: [ShoppingList] = []
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.joinCode = String(UUID().uuidString.prefix(6)).uppercased() // Simple 6-char code
        self.createdAt = Date()
    }
}

@Model
final class ShoppingList {
    var id: UUID
    var name: String
    var colorName: String
    var createdAt: Date
    
    var household: Household?
    
    var isCompleted: Bool = false
    
    @Relationship(deleteRule: .cascade)
    var items: [GroceryItem] = []
    
    @Relationship(deleteRule: .cascade)
    var sessions: [ShoppingSession] = []
    
    init(name: String, colorName: String = "PastelBlue") {
        self.id = UUID()
        self.name = name
        self.colorName = colorName
        self.createdAt = Date()
        self.isCompleted = false
    }
}

@Model
final class GroceryItem {
    var id: UUID
    var name: String
    var quantity: Int
    var category: GroceryCategory
    var authorName: String // Simplified for now, could link to User
    var statusRaw: String
    
    var status: ItemStatus {
        get { ItemStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }
    
    var estimatedPrice: Double?
    var actualPrice: Double?
    var isPromo: Bool = false
    var createdAt: Date
    
    // Relationship to a list
    var list: ShoppingList?
    
    // Relationship to a session if it was bought in one
    var session: ShoppingSession?
    
    init(name: String, quantity: Int = 1, category: GroceryCategory = .other, authorName: String) {
        self.id = UUID()
        self.name = name
        self.quantity = quantity
        self.category = category
        self.authorName = authorName
        self.statusRaw = ItemStatus.pending.rawValue
        self.createdAt = Date()
    }
}

@Model
final class ShoppingSession {
    var id: UUID
    var startTime: Date
    var endTime: Date?
    var totalCost: Double
    
    var list: ShoppingList?
    
    @Relationship(deleteRule: .cascade)
    var items: [GroceryItem] = []
    
    init(startTime: Date = Date()) {
        self.id = UUID()
        self.startTime = startTime
        self.totalCost = 0.0
    }
    
    var duration: TimeInterval {
        guard let end = endTime else { return Date().timeIntervalSince(startTime) }
        return end.timeIntervalSince(startTime)
    }
}
