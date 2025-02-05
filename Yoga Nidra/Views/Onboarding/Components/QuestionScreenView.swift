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
    let helperText: String?
    let options: [QuestionOption]
    @Binding var selectedOption: QuestionOption?
    let nextPage: () -> Void
    
    init(question: String, subtitle: String, helperText: String? = nil, options: [QuestionOption], selectedOption: Binding<QuestionOption?>, nextPage: @escaping () -> Void) {
        self.question = question
        self.subtitle = subtitle
        self.helperText = helperText
        self.options = options
        self._selectedOption = selectedOption
        self.nextPage = nextPage
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Question Section
            VStack(spacing: 16) {
                Text(question)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            Spacer()
                .frame(height: 20)
            
            // Options Section
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
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            if selectedOption?.id == option.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(Color(white: 0.2))
                        .cornerRadius(12)
                    }
                    .foregroundColor(.white)
                }
                
                if let helperText = helperText {
                    Text(helperText)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .background(
            ZStack {
                Image("northern-lights")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.3),
                        Color.black.opacity(0.5)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
        )
    }
}

#Preview {
    QuestionScreenView(
        question: "Sample Question",
        subtitle: "Sample subtitle",
        helperText: "Helper text",
        options: [
            QuestionOption(emoji: "😊", text: "Option 1"),
            QuestionOption(emoji: "😌", text: "Option 2")
        ],
        selectedOption: .constant(nil),
        nextPage: {}
    )
}
