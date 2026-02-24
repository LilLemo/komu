import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var userManager = UserManager()
    
    // Steps: 0 = Persona, 1 = Household Choice, 2 = Create Household, 3 = Join Household, 4 = Success
    @State private var currentStep = 0
    
    // Persona State
    @State private var name: String = ""
    @State private var selectedColor: String = "PastelBlue"
    @State private var selectedEmoji: String = "🦊"
    
    // Household State
    @State private var householdName: String = ""
    @State private var joinCode: String = ""
    
    // Temporary user created during flow
    @State private var createdUser: User?
    
    let colors = ["PastelBlue", "PastelRed", "PastelGreen", "PastelYellow", "PastelPurple", "PastelOrange"]
    let emojis = ["🦊", "🐼", "🦁", "🐨", "🐯", "🐸", "🐙", "🦄", "👽", "🤖", "🤠", "😎"]
    
    var body: some View {
        VStack {
            if currentStep == 0 {
                personaStep
            } else if currentStep == 1 {
                householdChoiceStep
            } else if currentStep == 2 {
                createHouseholdStep
            } else if currentStep == 3 {
                joinHouseholdStep
            } else if currentStep == 4 {
                successStep
            }
        }
        .padding()
        .background(Color.offWhite)
        .animation(.easeInOut, value: currentStep)
        .onAppear {
            userManager.modelContext = modelContext
        }
    }
    
    // MARK: - Steps
    
    var personaStep: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 8) {
                Text("Bem-vindo ao Komu")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Crie sua persona")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            // Avatar Preview
            ZStack {
                Circle()
                    .fill(Color(selectedColor) ?? .gray)
                    .frame(width: 100, height: 100)
                    .shadow(radius: 5)
                Text(selectedEmoji)
                    .font(.system(size: 50))
            }
            
            // Name Input
            TextField("Seu Nome", text: $name)
                .font(.title3)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
            
            // Emoji Grid
            VStack(alignment: .leading) {
                Text("Escolha um avatar")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                    ForEach(emojis, id: \.self) { emoji in
                        Button(action: { selectedEmoji = emoji }) {
                            Text(emoji)
                                .font(.title)
                                .padding(8)
                                .background(selectedEmoji == emoji ? Color.black.opacity(0.1) : Color.clear)
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Color Picker
            VStack(alignment: .leading) {
                Text("Escolha uma cor")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                HStack {
                    ForEach(colors, id: \.self) { colorName in
                        Circle()
                            .fill(Color(colorName) ?? .gray)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: selectedColor == colorName ? 2 : 0)
                            )
                            .onTapGesture {
                                selectedColor = colorName
                            }
                        Spacer()
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            Button(action: {
                // userManager.createUser(...) -> REMOVED, just advance step
                currentStep = 1
            }) {
                Text("Continuar")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(name.isEmpty ? Color.gray : Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .disabled(name.isEmpty)
            .padding(.bottom, 20)
        }
    }
    
    var householdChoiceStep: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("Onde você mora?")
                .font(.title)
                .fontWeight(.bold)
            
            Button(action: { currentStep = 2 }) {
                VStack(spacing: 12) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 40))
                    Text("Criar uma nova Casa")
                        .font(.headline)
                    Text("Para você e sua família")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(radius: 5)
            }
            .foregroundColor(.black)
            
            Button(action: { currentStep = 3 }) {
                VStack(spacing: 12) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 40))
                    Text("Entrar em uma Casa")
                        .font(.headline)
                    Text("Usando um código de convite")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(radius: 5)
            }
            .foregroundColor(.black)
            
            Spacer()
        }
        .padding()
    }
    
    var createHouseholdStep: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("Nome da sua Casa")
                .font(.title)
                .fontWeight(.bold)
            
            TextField("Ex: Casa de Praia", text: $householdName)
                .font(.title2)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button(action: {
                // Create User (Inactive) AND Household
                userManager.createUser(name: name, avatarColor: selectedColor, avatarEmoji: selectedEmoji, isActive: false)
                // We need to fetch the user we just created to assign household
                // Ideally createUser returns it, but for now let's assume we can find it or modify createUser.
                // Create Inactive User
                if let user = userManager.createUser(name: name, avatarColor: selectedColor, avatarEmoji: selectedEmoji, isActive: false) {
                    self.createdUser = user
                    userManager.createHousehold(name: householdName, for: user)
                    currentStep = 4
                }
            }) {
                Text("Criar Casa")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(householdName.isEmpty ? Color.gray : Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .disabled(householdName.isEmpty)
            .padding(.bottom, 20)
        }
    }
    
    var joinHouseholdStep: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("Código da Casa")
                .font(.title)
                .fontWeight(.bold)
            
            TextField("Ex: A1B2C3", text: $joinCode)
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.characters)
            
            Spacer()
            
            Button(action: {
                if let user = userManager.createUser(name: name, avatarColor: selectedColor, avatarEmoji: selectedEmoji, isActive: false) {
                    self.createdUser = user
                    userManager.joinHousehold(code: joinCode.uppercased(), for: user)
                    currentStep = 4
                }
            }) {
                Text("Entrar")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(joinCode.count < 6 ? Color.gray : Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .disabled(joinCode.count < 6)
            .padding(.bottom, 20)
        }
    }
    
    var successStep: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Tudo pronto!")
                .font(.title)
                .fontWeight(.bold)
            
            if let household = createdUser?.household {
                VStack(spacing: 8) {
                    Text("Código de convite:")
                        .foregroundColor(.secondary)
                    Text(household.joinCode)
                        .font(.system(size: 30, weight: .bold, design: .monospaced))
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    Text("Compartilhe com quem mora com você")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ShareLink(item: household.joinCode) {
                        Label("Compartilhar Código", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .padding(.top, 8)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
            }
            
            Spacer()
            
            Button(action: {
                if let user = createdUser {
                    userManager.activateUser(user)
                }
            }) {
                Text("Ir para as Compras")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding(.bottom, 20)
        }
    }
}
