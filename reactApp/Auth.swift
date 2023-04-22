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
            
            HStack{
                VStack(spacing: 0){
                    if(page == "login"){
                        Text("Se connecter")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                    }else{
                        Text("S'enregistrer")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                    }
                    
                    TextField("Email",
                              text: $email,
                              prompt:
                                Text("Email").foregroundColor(.black)
                    )
                    .frame(height: 40)
                    .padding(.top, 50)
                    .foregroundColor(.black)
                    .onSubmit {
                        passwordFocus.toggle()
                    }
                    
                    Rectangle().frame(width: 350, height:1).padding(.bottom).foregroundColor(.black)
                    
                    HStack{
                        if(showPassword){
                            TextField("Password",
                                      text: $password,
                                      prompt:
                                        Text("Mot de passe")
                                .foregroundColor(.black)
                            )
                            .frame(height: 40)
                            .foregroundColor(.black)
                            .focused($passwordFocus)
                            .onSubmit {
                                handleSubmit()
                            }
                        }else{
                            SecureField("Password",
                                        text: $password,
                                        prompt:
                                            Text("Mot de passe")
                                .foregroundColor(.black)
                            )
                            .frame(height: 40)
                            .foregroundColor(.black)
                            .focused($passwordFocus)
                            .onSubmit {
                                handleSubmit()
                            }
                        }
                        
                       Image(systemName: showPassword ? "eye" : "eye.slash")
                                    .foregroundColor(.black)
                                    .padding(.trailing, 16)
                                    .onTapGesture {
                                        self.showPassword.toggle()
                                    }
                    }
                    
                    Rectangle().frame(width: 350, height:1).foregroundColor(.black)
                    
                    if(errorMessage != ""){
                        Text(errorMessage)
                    }
                    
                    Button(action: {
                        handleSubmit()
                    }, label: {
                        ZStack{
                            Circle()
                                .fill(.blue)
                            
                            if(!isLoading){
                                Image(systemName: "arrow.right")
                                    .resizable()
                                    .renderingMode(.template)
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.white)
                                    .frame(width: 20)
                            }else{
                                HStack{
                                    Circle()
                                        .fill(.white)
                                        .scaleEffect(isAnimatingLoading ? 1 : 0.5)
                                        .animation(Animation.easeInOut(duration: 0.5).repeatForever(), value: isAnimatingLoading)
                                    Circle()
                                        .fill(.white)
                                        .scaleEffect(isAnimatingLoading ? 1 : 0.5)
                                        .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.3), value: isAnimatingLoading)
                                    Circle()
                                        .fill(.white)
                                        .scaleEffect(isAnimatingLoading ? 1 : 0.5)
                                        .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.6), value: isAnimatingLoading)
                                }.onAppear {
                                    //withAnimation(Animation.easeInOut(duration: 0.5).repeatForever()) {
                                        self.isAnimatingLoading = true
                                    //}
                                }.padding(.horizontal, 8)
                            }
                        }.frame(width: 60)
                    }).padding(.vertical, 40)
                    
                    Text(page == "login"
                         ? "Vous n'avez pas de compte ?"
                         : "Vous avez déjà un compte ?")
                    .padding(.bottom)
                    .foregroundColor(.black)
                    
                    Text(page == "login"
                         ? "S'enregistrer"
                         : "Se conecter")
                    .underline()
                    .foregroundColor(.black)
                    .onTapGesture {
                        if(page == "login"){
                            self.page = "register"
                        }else{
                            self.page = "login"
                        }
                    }
                    
                }
                .frame(width: 350)
            }
            .padding()
        }
    }
    
    func handleSubmit(){
        //print(page)
        //print(email)
        //print(password)
        //isLoggedIn(true)
        isLoading = true
        register()
    }
    
    func register(){
        struct RegisterModel: Decodable{
            let response: String
            let errorMessage: Optional<String>
        }
        
        let url: URL = URL(string: "https://b89d-2a01-cb1d-4d7-3f00-85db-7ec1-5532-9a22.ngrok-free.app/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        
        URLSession.shared.dataTask(with: request){(data, res, err) in
            do {
                if let data = data {
                    let result = try JSONDecoder().decode(RegisterModel.self, from: data)
                    if(result.response == "no"){
                        errorMessage = result.errorMessage!
                    }else if(result.response == "ok"){
                        print("ok nice")
                        //isLoggedIn(true)
                    }
                    
                    //isLoading = false
                }
            } catch let error {
                print("error", error.localizedDescription)
            }
        }.resume()
    }
}
