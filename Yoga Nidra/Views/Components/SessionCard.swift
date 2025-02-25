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
        VStack(alignment: .leading, spacing: 8) {
            // Thumbnail with overlays
            ZStack(alignment: .bottomLeading) {
                Image(session.thumbnailUrl)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, .black.opacity(0.6)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                
                // Duration and Premium overlay
                HStack {
                    Text("\(Int(session.duration / 60)) min")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    if session.isPremium {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.yellow)
                    }
                }
                .padding(12)
                
                // Play button overlay
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
            .frame(height: 160) // Fixed height for image container
            
            // Session info
            VStack(alignment: .leading, spacing: 0) {
                Text(session.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(session.instructor)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
