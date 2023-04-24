//
//  Auth.swift
//  reactApp
//
//  Created by Mohamed Mataam on 22/04/2023.
//

import SwiftUI

struct Auth : View{
    var isLoggedIn: (Bool) -> Void
    
    @State private var page = "login"
    
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    
    @State private var isLoading = false
    @State private var isAnimatingLoading = false
    
    @State private var errorMessage: String = ""
    
    @FocusState private var passwordFocus;
    
    var body: some View{
        ZStack{
            // Background
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient:
                            Gradient(colors:
                                        [Color.purple,
                                         Color.red]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing))
                .ignoresSafeArea()
            
            // Foreground
            VStack(spacing: 0){
                //Affiche login si c'est la page de login ou register si ce n'est pas le cas
                if(page == "login"){
                    Text(LocalizedStringKey("login"))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                }else{
                    Text(LocalizedStringKey("register"))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                }
                
                // Champ pour le mail
                TextField("Email",
                          text: $email,
                          prompt:
                            Text("Email").foregroundColor(.black)
                )
                .textInputAutocapitalization(.never)
                .frame(height: 40)
                .padding(.top, 50)
                .foregroundColor(.black)
                .onSubmit {
                    // Lorsqu'on appuie sur Entrée, switch au champ du mot de passe (1000IQ)
                    passwordFocus.toggle()
                }
                
                // Bar noir en dessous du champ mail
                Rectangle().frame(width: 350, height:1).padding(.bottom).foregroundColor(.black)
                
                HStack{
                    // Affiche un textfield normal si on montre le mot de passe sinon affiche un SecureField (qui cache le mdp)
                    if(showPassword){
                        TextField(LocalizedStringKey("password"),
                                  text: $password,
                                  prompt:
                                    Text(LocalizedStringKey("password"))
                            .foregroundColor(.black)
                        )
                        .frame(height: 40)
                        .foregroundColor(.black)
                        .focused($passwordFocus)
                        .onSubmit {
                            // Lorsqu'on appuie sur entrée, submit le formulaire
                            handleSubmit()
                        }
                    }else{
                        SecureField(LocalizedStringKey("password"),
                                    text: $password,
                                    prompt:
                                        Text(LocalizedStringKey("password"))
                            .foregroundColor(.black)
                        )
                        .frame(height: 40)
                        .foregroundColor(.black)
                        .focused($passwordFocus)
                        .onSubmit {
                            // Lorsqu'on appuie sur entrée, submit le formulaire
                            handleSubmit()
                        }
                    }
                    
                    // Affiche l'icon de l'oeil pour afficher/masquer le mdp
                    Image(systemName: showPassword ? "eye" : "eye.slash")
                        .foregroundColor(.black)
                        .padding(.trailing, 16)
                        .onTapGesture {
                            self.showPassword.toggle()
                        }
                }
                
                // Bar noir en dessous du champ password
                Rectangle().frame(width: 350, height:1).foregroundColor(.black)
                
                // Affiche le message d'erreur d'il y en a un
                if(errorMessage != ""){
                    Text(LocalizedStringKey(errorMessage))
                }
                
                // Bouton de connection
                Button(action: {
                    handleSubmit()
                }, label: {
                    ZStack{
                        Circle()
                            .fill(.blue)
                        
                        // Affiche une fleche par default, ou une animation de chargement quand appuyer
                        if(!isLoading){
                            Image(systemName: "arrow.right")
                                .resizable()
                                .renderingMode(.template)
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.white)
                                .frame(width: 20)
                        }else{
                            //Affiche l'animation
                            HStack{
                                // Affiche 3 cercles ayant un delay d'animation décaler
                                ForEach([0, 1, 2], id: \.self) { element in
                                    Circle()
                                        .fill(.white)
                                        .scaleEffect(isAnimatingLoading ? 1 : 0.5)
                                        .animation(
                                            Animation
                                                .easeInOut(duration: 0.5)
                                                .repeatForever()
                                                .delay(element*0.3)
                                            ,value: isAnimatingLoading)
                                }
                            }.onAppear {
                                self.isAnimatingLoading = true
                            }.padding(.horizontal, 8)
                        }
                    }.frame(width: 60)
                }).padding(.vertical, 40)
                
                // Change le texte en fonction de si c'est la page de login ou de register
                Text(page == "login"
                     ? LocalizedStringKey("auth_have_no_account")
                     : LocalizedStringKey("auth_have_account"))
                .padding(.bottom)
                .foregroundColor(.black)
                
                Text(page == "login"
                     ? LocalizedStringKey("register")
                     : LocalizedStringKey("login"))
                .underline()
                .foregroundColor(.black)
                .onTapGesture {
                    // Switch entre page de login/register
                    if(page == "login"){
                        self.page = "register"
                    }else{
                        self.page = "login"
                    }
                }
                
            }
            .frame(width: 350)
            .padding()
        }
    }
    
    func handleSubmit(){
        // Lance le chargement et efface le message d'erreur
        isLoading = true
        errorMessage = ""
        if(page == "register"){
            register()
        }else{
            //login() //TODO
        }
    }
    
    func register(){
        // URL du serveur
        let url: URL = URL(string: "https://26f0-2a01-cb1d-4d7-3f00-85db-7ec1-5532-9a22.ngrok-free.app/register")!
        // Initialisation de la requête http : methode, content-type, body
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        
        // Envoie la requête
        URLSession.shared.dataTask(with: request){(data, res, err) in
            do {
                // Si la data n'est pas nul, on la traite
                if let data = data {
                    // On décode la data de la réponse au model définie (response, errorMessage...)
                    let result = try JSONDecoder().decode(AuthResponseModel.self, from: data)
                    if(result.response == "no"){
                        // Si une erreur, alors l'afficher
                        errorMessage = result.errorMessage!
                    }else if(result.response == "ok"){
                        // Bien enregistrer
                        print(result.userID!)
                        //isLoggedIn(true)
                    }
                }else{
                    errorMessage = "unknown_erreur"
                }
            } catch let error {
                errorMessage = "unknown_erreur"
                print("error", error.localizedDescription)
            }
            isLoading = false
        }.resume()
    }
}
