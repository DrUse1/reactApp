//
//  ContentView.swift
//  reactApp
//
//  Created by Mohamed Mataam on 22/04/2023.
//

import SwiftUI

struct ContentView: View {
    var inPreview = false
    @State var isLogged = false
    
    var body: some View {
        // Si user logged, alors affiche l'app, sinon la page de connection
        if(isLogged){
            MainView(inPreview: inPreview)
        }else{
            Auth(isLoggedIn: { loggedIn in
                self.isLogged = loggedIn
            })
        }
    }
}

// Permet de preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(inPreview: true)
    }
}
