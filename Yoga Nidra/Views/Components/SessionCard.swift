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
            // Thumbnail with overlays
            Image(session.thumbnailUrl)
                .resizable()
                .scaledToFill()
                .frame(height: 160)
                .clipped()
                .cornerRadius(12)
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
            
            // Fixed padding between image and text
            Spacer().frame(height: 12)
            
            // Title and instructor in fixed height container
            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 50, alignment: .top)
                
                Text(session.instructor)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 4)
        }
    }
}
