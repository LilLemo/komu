import Foundation
import SwiftData
import SwiftUI

@Observable
class UserManager {
    var currentUser: User?
    var modelContext: ModelContext?
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    func fetchCurrentUser() {
        guard let context = modelContext else { return }
        
        // Fetch user marked as current
        let descriptor = FetchDescriptor<User>(predicate: #Predicate<User> { $0.isCurrentUser == true })
        
        do {
            let users = try context.fetch(descriptor)
            self.currentUser = users.first
        } catch {
            print("Failed to fetch current user: \(error)")
        }
    }
    
    @discardableResult
    func createUser(name: String, avatarColor: String, avatarEmoji: String, isActive: Bool = true) -> User? {
        guard let context = modelContext else { return nil }
        
        // Deactivate any existing current user (just in case)
        if isActive, let existing = currentUser {
            existing.isCurrentUser = false
        }
        
        let newUser = User(name: name, avatarColor: avatarColor, avatarEmoji: avatarEmoji, isCurrentUser: isActive)
        context.insert(newUser)
        
        // Explicitly save to trigger UI updates immediately
        try? context.save()
        
        if isActive {
            self.currentUser = newUser
        }
        
        return newUser
    }
    
    func activateUser(_ user: User) {
        user.isCurrentUser = true
        try? modelContext?.save()
        self.currentUser = user
    }
    
    func createHousehold(name: String, for user: User) {
        guard let context = modelContext else { return }
        
        let newHousehold = Household(name: name)
        context.insert(newHousehold)
        
        user.household = newHousehold
        newHousehold.members.append(user)
        
        try? context.save()
    }
    
    func joinHousehold(code: String, for user: User) {
        guard let context = modelContext else { return }
        
        // Find household by code (Case insensitive)
        let descriptor = FetchDescriptor<Household>(predicate: #Predicate<Household> { $0.joinCode == code })
        
        do {
            let households = try context.fetch(descriptor)
            if let household = households.first {
                user.household = household
                household.members.append(user)
                try? context.save()
            } else {
                print("Household not found with code: \(code)")
            }
        } catch {
            print("Failed to join household: \(error)")
        }
    }
    
    func signOut() {
        currentUser?.isCurrentUser = false
        currentUser = nil
    }
}
