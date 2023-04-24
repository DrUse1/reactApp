//
//  Models.swift
//  reactApp
//
//  Created by Mohamed Mataam on 24/04/2023.
//

import Foundation

// Model de la réponse du serveur
struct AuthResponseModel: Decodable {
    let response: String
    let errorMessage: Optional<String>
    let userID: Optional<String>
}

struct UserModel: Decodable {
    let id: String
    let email: String
    let password: String
    let name: String
    let conversations: [String] // Conversations ID
    let friends: [String] // Users ID
}

struct ConversationModel: Decodable {
    let id: String
    let users: [String] // Users ID
    let messages: [String] // Messages ID
}

struct MessageModel: Decodable {
    let id: String
    let content: String
    let sender: String // User ID
    let date: Date
    let read: [String] // Users ID
}

struct PhotoModel: Decodable {
    let id: String
    let content: String // Actual Image, maybe binary or idk
    let sender: String // User ID
    let reactions: [String] // Photos ID
}
