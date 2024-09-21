import SwiftUI

// MARK: - Subscription Model
struct Subscription: Identifiable, Codable {
    let id = UUID()
    let name: String
    let amount: Double
    let renewalDate: Date
}

// MARK: - Color Theme
struct AppColors {
    static let background = Color(.systemGray6)
    static let cardBackground = Color(.white)
    static let mintGreen = Color("MintGreen") // Define this in your asset catalog
    static let accentBlue = Color("LightBlue") // Define this in your asset catalog
    static let textGray = Color(.darkGray)
}

// MARK: - ContentView
struct ContentView: View {
    @State private var subscriptions: [Subscription] = []
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(subscriptions: $subscriptions)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            LogSubscriptionView(subscriptions: $subscriptions)
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Log")
                }
                .tag(1)
        }
        .accentColor(AppColors.mintGreen) // Set accent color to mint green
        .onAppear {
            loadSubscriptions()
        }
    }
    
    // MARK: - Data Persistence Methods
    private func saveSubscriptions() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(subscriptions) {
            UserDefaults.standard.set(encoded, forKey: "subscriptions")
        }
    }
    
    private func loadSubscriptions() {
        if let savedSubscriptions = UserDefaults.standard.data(forKey: "subscriptions") {
            let decoder = JSONDecoder()
            if let loadedSubscriptions = try? decoder.decode([Subscription].self, from: savedSubscriptions) {
                subscriptions = loadedSubscriptions
            }
        }
    }
}

// MARK: - HomeView
struct HomeView: View {
    @Binding var subscriptions: [Subscription]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(subscriptions) { subscription in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(subscription.name)
                            .font(.title3).bold()
                            .foregroundColor(AppColors.textGray)
                        Text("Amount: $\(subscription.amount, specifier: "%.2f")")
                            .foregroundColor(AppColors.textGray)
                        Text("Renewal Date: \(formattedDate(subscription.renewalDate))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                }
                .onDelete(perform: delete)
            }
            .background(AppColors.background)
            .navigationTitle("Subscriptions")
            .toolbar {
                EditButton()
            }
        }
    }
    
    private func delete(at offsets: IndexSet) {
        subscriptions.remove(atOffsets: offsets)
        saveSubscriptions()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func saveSubscriptions() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(subscriptions) {
            UserDefaults.standard.set(encoded, forKey: "subscriptions")
        }
    }
}

// MARK: - LogSubscriptionView
struct LogSubscriptionView: View {
    @Binding var subscriptions: [Subscription]
    
    @State private var name = ""
    @State private var amount = ""
    @State private var renewalDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Subscription Info")) {
                    TextField("Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    DatePicker("Renewal Date", selection: $renewalDate, displayedComponents: .date)
                }
                
                Button(action: {
                    if let amountValue = Double(amount) {
                        let newSubscription = Subscription(name: name, amount: amountValue, renewalDate: renewalDate)
                        subscriptions.append(newSubscription)
                        saveSubscriptions()
                        clearForm()
                    }
                }) {
                    Text("Submit")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.mintGreen)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Log Subscription")
        }
    }
    
    private func clearForm() {
        name = ""
        amount = ""
        renewalDate = Date()
    }
    
    private func saveSubscriptions() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(subscriptions) {
            UserDefaults.standard.set(encoded, forKey: "subscriptions")
        }
    }
}

@main
struct SubscriptionApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

