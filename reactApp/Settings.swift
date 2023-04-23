//
//  Settings.swift
//  reactApp
//
//  Created by Eric Bjarstal on 23/04/2023.
//

import SwiftUI

struct Settings: View {
    @State private var showPasswordChangeAlert = false
    @State private var isPushNotificationsEnabled = true
    @State private var isEditingUsername = false
    @State private var username = "johndoe123"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    HStack {
                        Text("Username")
                            .font(.headline)
                        Spacer()
                        if isEditingUsername {
                            TextField("Username", text: $username)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 120)
                            Button("Save") {
                                // save the new username
                                self.isEditingUsername = false
                            }
                            .transition(.move(edge: .trailing))
                        } else {
                            Text(username)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: 120)
                            Button("Edit") {
                                self.isEditingUsername = true
                            }
                            .transition(.move(edge: .trailing))
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Email")
                            .font(.headline)
                        Text("johndoe123@gmail.com")
                            .font(.subheadline)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Account Creation Date")
                            .font(.headline)
                        Text("April 20, 2022")
                            .font(.subheadline)
                    }
                }
                
                Section(header: Text("Security")) {
                    Button(action: {
                        self.showPasswordChangeAlert.toggle()
                    }) {
                        Text("Change Password")
                    }
                    .alert(isPresented: $showPasswordChangeAlert) {
                        Alert(title: Text("Change Password"), message: Text("Are you sure you want to change your password?"), primaryButton: .default(Text("Yes")), secondaryButton: .cancel())
                    }
                }
                
                Section(header: Text("Notifications")) {
                    Toggle(isOn: $isPushNotificationsEnabled) {
                        Text("Push Notifications")
                    }
                }
            }
            .navigationBarTitle(Text("Settings"), displayMode: .automatic)
        }
        .tabItem {
            Image(systemName: "gearshape")
            Text("Settings")
        }
    }
}
