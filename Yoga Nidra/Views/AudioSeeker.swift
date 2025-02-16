//
//  AudioSeeker.swift
//  Yoga Nidra
//
//  Created by Nishchal Visavadiya on 16/02/25.
//

import SwiftUI

struct AudioSeeker: View {
    
    @State var isEditing = false
    @State var progress = 0.0
    @EnvironmentObject private var audioManager: AudioManager
    
    var body: some View {
        Slider(
            value: .init(
                get: { progress },
                set: { progress in
                    guard isEditing else { return }
                    self.progress = progress
                }
            ),
            in: 0...1,
            onEditingChanged: { isEditing in
                if !isEditing {
                    audioManager.onScrubberSeek(progress: progress)
                }
                self.isEditing = isEditing
            }
        )
        .accentColor(.white)
        .onChange(of: audioManager.progress) { oldValue, newValue in
            guard !isEditing else { return }
            progress = newValue
        }
    }
}

#Preview {
    AudioSeeker()
}
