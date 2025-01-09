//
//  QuestionScreenView.swift
//  Yoga Nidra
//
//  Created by Shamanth Rao on 1/9/25.
//

import SwiftUI

struct QuestionOption: Identifiable {
    let id = UUID()
    let emoji: String
    let text: String
}

struct QuestionScreenView: View {
    let question: String
    let subtitle: String
    let options: [QuestionOption]
    @Binding var selectedOption: QuestionOption?
    let nextPage: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text(question)
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            VStack(spacing: 16) {
                ForEach(options) { option in
                    Button {
                        selectedOption = option
                        // Automatically advance after selection
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            nextPage()
                        }
                    } label: {
                        HStack {
                            Text(option.emoji)
                                .font(.title2)
                                .padding(.trailing, 8)
                            
                            Text(option.text)
                                .font(.headline)
                            
                            Spacer()
                            
                            if selectedOption?.id == option.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(uiColor: .systemGray6))
                        )
                    }
                    .foregroundColor(.primary)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

