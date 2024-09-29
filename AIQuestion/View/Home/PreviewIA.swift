//
//  PreviewBook.swift
//  AIQuestion
//
//  Created by Jose Decena on 25/9/24.
//

import SwiftUI

struct PreviewIA: View {
    
    @State var points: [SIMD2<Float>] = [
        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
        [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
    ]
    
    var gradients: MeshGradient {
        MeshGradient(width: 3, height: 3, points: points, colors: [
            .orange, .purple, .purple,
            .red, .white, .purple,
            .pink, .red, .orange
        ])
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(gradients)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Label {
                        Text("AI")
                            .font(.title)
                            .fontWeight(.bold)
                    } icon: {
                        Image(systemName: "brain.head.profile")
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding(20)
        }
    }
}

#Preview {
    PreviewIA()
        .frame(maxWidth: 200, maxHeight: 200)
}
