//
//  DetailedCharacterView.swift
//  MarvelHeroes
//
//  Created by Gustavo Amaral on 10/04/20.
//  Copyright © 2020 Gustavo Almeida Amaral. All rights reserved.
//

import SwiftUI

struct DetailedCharacterView: View {
    
    let character: Character
    
    var body: some View {
        ContainerOrientation { orientation in
            ScrollView {
                VStack(alignment: .leading) {
                    URLImage(url: self.character.thumbnail.sized(orientation == .portrait ? .portraitUncanny : .landscapeIncredible))
                        .frame(maxWidth: .infinity)
                    Text(self.character.description)
                        .font(.body)
                        .lineLimit(3)
                        .padding(.top)
                        .multilineTextAlignment(.leading)
                    MostExpensiveHQButton(character: self.character)
                    
                }.padding(.horizontal)
            }
        }
        .navigationBarTitle(character.name)
        
    }
}

struct DetailedCharacterView_Previews: PreviewProvider {
    static var previews: some View {
        DetailedCharacterView(character: testCharacter1)
    }
}

#if DEBUG
fileprivate let testCharacter1 = Character(id: 1, name: "Spider-Man", description: "A hero", thumbnail: .init(baseURL: URL(string: "http://i.annihil.us/u/prod/marvel/i/mg/3/20/5232158de5b16")!, extension: "jpg"))
#endif
