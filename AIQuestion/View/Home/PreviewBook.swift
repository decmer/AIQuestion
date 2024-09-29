//
//  PreviewBook.swift
//  AIQuestion
//
//  Created by Jose Decena on 25/9/24.
//

import SwiftUI

struct PreviewBook: View {
    
    @State var points: [SIMD2<Float>] = [
        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
        [0.0, 0.5], [0.7, 0.3], [1.0, 0.5],
        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
    ]
    
    var gradients: MeshGradient {
        MeshGradient(width: 3, height: 3, points: points, colors: [
            .yellow, .yellow, .yellow,
            .red, .red, .red,
            .blue, .blue, .blue
        ])
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(gradients)
            VStack {
                HStack {
                    Text("Books")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                }
                Image("BooksPre")
                    
                    .resizable()
                    .scaledToFit()
                Spacer()
            }
            .padding(20)
        }
    }
}

#Preview {
    PreviewBook()
        .frame(maxWidth: 200, maxHeight: 200)
}
