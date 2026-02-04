import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var isFaceIDLockOn = UserDefaults.standard.bool(forKey: "isAppLocked")
    @State private var selectedTheme = "System"
    @State private var showSignOutAlert = false
    
    let themes = ["System", "Light", "Dark"]
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Profile Section
                Section(header: Text("Profile")) {
                    HStack(spacing: 16) {
                        AsyncImage(url: URL(string: authManager.currentUser?.photoURL?.absoluteString ?? "")) { image in
                            image.resizable()
                                .scaledToFill()
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .foregroundColor(.gray)
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                        
                        VStack(alignment: .leading) {
                            Text(authManager.currentUser?.displayName ?? "User")
                                .font(.headline)
                            Text(authManager.currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // MARK: - Security Section
                Section(header: Text("Security")) {
                    Toggle(isOn: $isFaceIDLockOn) {
                        Label("Enable Face ID Lock", systemImage: "faceid")
                    }
                    .onChange(of: isFaceIDLockOn) { newValue in
                        UserDefaults.standard.set(newValue, forKey: "isAppLocked")
                    }
                }
                
                // MARK: - Appearance Section
                Section(header: Text("Appearance")) {
                    Picker("App Theme", selection: $selectedTheme) {
                        ForEach(themes, id: \.self) { theme in
                            Text(theme)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedTheme) { value in
                        applyTheme(value)
                    }
                }
                
                // MARK: - About Section
                Section(header: Text("About")) {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundColor(.secondary)
                    }
                }
                
                // MARK: - Sign Out Section
                Section {
                    Button(action: { showSignOutAlert = true }) {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                    .alert("Sign Out", isPresented: $showSignOutAlert) {
                        Button("Yes", role: .destructive) {
                            authManager.signOutImmediately()
                        }
                        Button("No", role: .cancel) { }
                    } message: {
                        Text("Are you sure you want to sign out?")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private func applyTheme(_ theme: String) {
        switch theme {
        case "Light":
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
        case "Dark":
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
        default:
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .unspecified
        }
    }
}

