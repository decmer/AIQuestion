//
//  MainView.swift
//  AIQuestion
//
//  Created by Jose Decena on 24/9/24.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                LazyVGrid(columns: [GridItem(), GridItem()], spacing: 20) {
                    NavigationLink {
                        MainViewBooks()
                    } label: {
                        PreviewBook()
                            .frame(width: geometry.size.width / 2.5, height: geometry.size.width / 2.5) // Igual altura para ambas
                            .aspectRatio(1, contentMode: .fit)
                    }
                    
                    NavigationLink {
                        Text("The magic is near")
                    } label: {
                        PreviewIA()
                            .frame(width: geometry.size.width / 2.5, height: geometry.size.width / 2.5) // Igual altura para ambas
                            .aspectRatio(1, contentMode: .fit)
                    }
                    
                    NavigationLink {
                        Text("The charts will go up very soon")
                    } label: {
                        PreviewStadistics()
                            .frame(width: geometry.size.width / 2.5, height: geometry.size.width / 2.5) // Igual altura para ambas
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
                .padding(20)
                .navigationTitle("AI Question")
            }
        }
    }
}
