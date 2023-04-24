//
//  Conversations.swift
//  reactApp
//
//  Created by Mohamed Mataam on 24/04/2023.
//

import SwiftUI

struct Conversations: View {
    var body: some View {
        ZStack{
            Rectangle()
                .fill(Color(hex: 0x1c1c1c))
            VStack{
                HStack{
                    Text("Conversations")
                        .foregroundColor(.white)
                }.padding(.vertical, 32)
                
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
        }
    }
}

struct Conversations_Previews: PreviewProvider {
    static var previews: some View {
        Conversations()
    }
}
