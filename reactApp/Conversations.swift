//
//  Conversations.swift
//  reactApp
//
//  Created by Mohamed Mataam on 24/04/2023.
//

import SwiftUI

struct UserSearchModel: Decodable, Hashable {
    let id: String
    var email: String
}

struct Conversations: View {
    @State private var showFriends = false
    @State private var isLoading = false
    @State private var friendField = ""
    @State private var lastChangeField: Date? = nil
    
    @State private var queryResult: [UserSearchModel] = []
    
    var body: some View {
        GeometryReader { geo in
            ZStack{
                Rectangle()
                    .fill(Color(hex: 0x1c1c1c))
                
                VStack{
                    HStack{
                        Text("Conversations")
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button {
                            showFriends.toggle()
                        } label: {
                            Image(systemName: "plus")
                        }

                    }.padding(.vertical, 32)
                        .padding(.horizontal)
                        .padding(.top, 32)
                    
                    VStack{
                        // Conversations
                        ForEach([1,2,3,4,5], id: \.self) { element in
                            VStack{
                                
                                Rectangle().fill(.black).frame(height: 1)
                                
                                HStack{
                                    // Profile Picture
                                    Image(systemName: "person.circle")
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                        .padding(.horizontal, 8)
                                    
                                    // Information
                                    VStack{
                                        // Username
                                        HStack{
                                            Text("Mohamed")
                                            Spacer()
                                        }
                                        
                                        // Last activity
                                        HStack{
                                            Text("Reçu · 32m")
                                            Spacer()
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                
                                Rectangle().fill(.black).frame(height: 1)
                            }
                            
                        }
                        .frame(height: 64)
                    }
                    Spacer()
                }
                
                if(showFriends){
                    Rectangle()
                        .fill(Color(red: 0, green: 0, blue: 0, opacity: 0.5))
                        .onTapGesture {
                            showFriends.toggle()
                        }
                    
                    ZStack{
                        Rectangle()
                            .fill(.black)
                            
                        VStack {
                            TextField("Search...",
                                      text: $friendField,
                                      prompt: Text("lol")
                            )
                            .frame(width: geo.size.width * 0.8)
                                .padding(.vertical)
                            
                            if(!$queryResult.isEmpty){
                                ForEach(queryResult, id: \.self) { element in
                                    Text(element.email)
                                }
                            }else if(!isLoading){
                                Text("Aucun résultat")
                                if(friendField.count < 3){
                                    Text("Entrez au moins 3 lettres")
                                }
                            }else {
                                Text("Loading...")
                            }
                            
                            
                            Spacer()
                        }
                        .onChange(of: friendField) { newValue in
                            if(newValue.count >= 3){
                                isLoading = true
                                lastChangeField = Date()
                            }else {
                                isLoading = false
                            }
                        }
                        .onReceive(Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()) { _ in
                            if let lastDate = lastChangeField, Date().timeIntervalSince(lastDate) >= 1.0 {
                                submitQuery()
                                lastChangeField = nil
                            }
                        }
                        
                    }
                    .frame(width: geo.size.width * 0.8, height: 256)
                }
            }
        }
    }
    
    func submitQuery(){
        // URL du serveur
        let url: URL = URL(string: "https://26f0-2a01-cb1d-4d7-3f00-85db-7ec1-5532-9a22.ngrok-free.app/search")!
        // Initialisation de la requête http : methode, content-type, body
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "query": friendField,
        ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        
        // Envoie la requête
        URLSession.shared.dataTask(with: request){(data, res, err) in
            do {
                // Si la data n'est pas nul, on la traite
                if let data = data {
                    // On décode la data de la réponse au model définie (response, errorMessage...)
                    let result = try JSONDecoder().decode([UserSearchModel].self, from: data)
                    queryResult = result
                    isLoading = false
                }else{
                    print("error jsp")
                }
            } catch let error {
                print("error", error.localizedDescription)
            }
        }.resume()
    }
}

struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

struct Conversations_Previews: PreviewProvider {
    static var previews: some View {
        Conversations()
    }
}
