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
                                Text("Email")
                        .foregroundColor(.black)
                    )
                    .frame(height: 40)
                        .padding(.top, 50)
                        .foregroundColor(.black)
                    
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
                        }else{
                            SecureField("Password",
                                        text: $password,
                                        prompt:
                                            Text("Mot de passe")
                                .foregroundColor(.black)
                            )
                            .frame(height: 40)
                            .foregroundColor(.black)
                        }
                        
                       Image(systemName: showPassword ? "eye" : "eye.slash")
                                    .foregroundColor(.black)
                                    .padding(.trailing, 16)
                                    .onTapGesture {
                                        self.showPassword.toggle()
                                    }
                    }
                    
                    Rectangle().frame(width: 350, height:1).foregroundColor(.black)
                    
                    Button(action: {
                        handleSubmit()
                    }, label: {
                        ZStack{
                            Circle()
                                .fill(.blue)
                                .frame(width: 60)
                            
                            Image(systemName: "arrow.right")
                                .resizable()
                                .renderingMode(.template)
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.white)
                                .frame(width: 20)
                        }
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
        print(page)
        print(email)
        print(password)
        isLoggedIn(true)
    }
}
