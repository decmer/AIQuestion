//
//  PreviewBook.swift
//  AIQuestion
//
//  Created by Jose Decena on 25/9/24.
//

import SwiftUI

struct PreviewStadistics: View {
    
    @State var points: [SIMD2<Float>] = [
        [0.0, 0.0], [0.7, 0.0], [1.0, 0.0],
        [0.0, 0.6], [0.7, 0.7], [1.0, 0.7],
        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
    ]
    
    var gradients: MeshGradient {
        MeshGradient(width: 3, height: 3, points: points, colors: [
            .green, .green, .teal,
            .cyan, .blue, .purple,
            .cyan, .purple, .indigo
        ])
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(gradients)
            VStack {
                HStack {
                    Text("Stadistics")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                }
                Image("EstadisticsPre")
                    .resizable()
                    .scaledToFit()
                Spacer()
            }
            .padding(8)
        }
    }
}

#Preview {
    PreviewStadistics()
        .frame(maxWidth: 200, maxHeight: 200)
}
