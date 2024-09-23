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
    static let mintGreen = Color("MintGreen") // Defined in asset catalog
    static let accentBlue = Color("LightBlue") // Defined in asset catalog
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
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear.circle.fill")
                    Text("WIP: Settings")
                }
                .tag(2)
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
                    //.padding()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .onDelete(perform: delete)
            }
            .background(AppColors.background)
            .navigationTitle("Subscriptions")
            
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
                        //.textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                        //.textFieldStyle(RoundedBorderTextFieldStyle())
                    DatePicker("Renewal Date", selection: $renewalDate, displayedComponents: .date)
                        //.padding()
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
                

                
            }.scrollDismissesKeyboard(.interactively)
            
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

// MARK: - SettingsView

struct SettingsView: View {
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Text("App Guide")
                    Text("Notifications")
                    Text("Setting 3")
                    Button(action: {
                        scheduleTestNotification() // Call the function to schedule the test notification
                    }) {
                        Text("Test Notification")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    
                }
                
                }
                
            .navigationTitle("Settings")
            }
        
        }
}

func scheduleTestNotification() {
    let content = UNMutableNotificationContent()
    content.title = "Test Notification"
    content.body = "This is a test notification to check if everything works!"
    content.sound = .default
    
    // Create a trigger that fires immediately (1 second delay)
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
    
    // Create the request
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    
    // Schedule the notification
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling test notification: \(error.localizedDescription)")
        } else {
            print("Test notification scheduled")
        }
    }
}

import UserNotifications

@main
struct SubscriptionApp: App {
    var body: some Scene {
            WindowGroup {
                ContentView()
                    .onAppear {
                        requestNotificationPermission()
                    }
            }
        }

        func requestNotificationPermission() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if granted {
                    print("Notification permission granted.")
                } else if let error = error {
                    print("Notification permission denied: \(error.localizedDescription)")
                }
            }
        }
}

// MARK: - Notifications



#Preview {
    // The view to preview.
    ContentView()
}
