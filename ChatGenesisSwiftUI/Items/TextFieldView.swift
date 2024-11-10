//
//  TextField.swift
//  TestTaskSfUI
//
//  Created by user246073 on 11/7/24.
//
  
import SwiftUI

enum TextFieldState {
    case enabled
    case focused
    case error
}

struct TextFieldView: View {
    @Binding var text: String // Binding for text input
    @Binding var isValid: Bool // Binding for validator to activate error state
        
    var placeholder: String
    var supportingText: String?
    var errorText: String
    var padding: CGFloat?
    let customColor = Color(.purpleLite)
    @FocusState private var isFocused: Bool
    @State private var state: TextFieldState = .enabled

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .frame(height: 65)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor, lineWidth: 1)
                    )
                VStack(alignment: .leading) {
                    Text(placeholder)
                        .font(.sansReg(13))
                        .foregroundColor(borderColor)
                        .opacity((isFocused || !text.isEmpty) ? 1 : 0)
                        .offset(y: (isFocused || !text.isEmpty) ? 0 : 20)
                        .animation(.easeInOut(duration: 0.2), value: isFocused || !text.isEmpty)
                        .offset(x: 15, y: 5)
                    
                    TextField(isFocused || !text.isEmpty ? "" : placeholder, text: $text)
                        .font(.sansReg(18))
                        .padding(.horizontal, 16)
                        .focused($isFocused)
                        .onChange(of: isFocused) { _, _ in
                            updateState()
                        }
                        .onChange(of: isValid) { _, _ in
                            updateState()
                        }
                        .onChange(of: text) { _, _ in
                            updateState()
                        }
                }
                .offset(y: -5)
            }
            
            Text(supportingTextForState)
                .font(.footnote)
                .foregroundColor(supportingTextColor)
                .padding(.horizontal, 16)
        }
        .padding(.horizontal, padding ?? 35 )
    }

    private func updateState() {
        if !isValid {
            state = .error
        } else if isFocused {
            state = .focused
        } else {
            state = .enabled
        }
    }

    // Computed properties for colors and text
    private var borderColor: Color {
        switch state {
        case .enabled:
            return customColor
        case .focused:
            return .orange
        case .error:
            return .red
        }
    }
    
    private var supportingTextForState: String {
        switch state {
        case .enabled, .focused:
            return supportingText ?? ""
        case .error:
            return errorText
        }
    }
    
    private var supportingTextColor: Color {
        state == .error ? .red : .gray
    }
}

struct StatefulPreviewWrapper<Value: Equatable, Content: View>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> Content

    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: value)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
