//
//  SessionCard.swift
//  Yoga Nidra
//
//  Created by Nishchal Visavadiya on 05/01/25.
//

import SwiftUI

struct SessionCard: View {
    
    let session: YogaNidraSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(session.thumbnailUrl)
                .frame(width: 160, height: 160)
                .cornerRadius(8)
                .overlay(alignment: .bottomLeading) {
                    Text("\(Int(session.duration / 60)) min")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(12)
                }
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "play.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Circle().fill(Color.white.opacity(0.2)))
                        .padding(12)
                }
        }
    }
}
