import SwiftUI
import Combine

struct OTPFieldView: View {
    @Binding var otpCode: String
    let otpLength: Int
    
    @FocusState private var fieldFocus: Int?
    @State private var isEditing: Bool = false
    
    var body: some View {
        HStack(spacing: 14) {
            ForEach(0..<otpLength, id: \.self) { index in
                OTPDigitField(
                    index: index,
                    text: $otpCode,
                    focusedField: $fieldFocus,
                    otpLength: otpLength
                )
                .frame(width: 50, height: 60)
            }
        }
        .onAppear {
            withAnimation(.spring()) {
                fieldFocus = 0
                isEditing = true
            }
        }
    }
}

struct OTPDigitField: View {
    let index: Int
    @Binding var text: String
    @FocusState.Binding var focusedField: Int?
    let otpLength: Int
    
    @State private var isFocused: Bool = false
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            if index < text.count {
                let startIndex = text.startIndex
                let charIndex = text.index(startIndex, offsetBy: index)
                let charToShow = text[charIndex]
                
                Text(String(charToShow))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(scale)
                    .onAppear {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            scale = 1.2
                        }
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.1)) {
                            scale = 1.0
                        }
                    }
            }
        }
        .frame(width: 50, height: 60)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            focusedField == index ? Color.white : Color.white.opacity(0.3),
                            lineWidth: focusedField == index ? 2.5 : 1.5
                        )
                        .animation(.easeInOut(duration: 0.2), value: focusedField == index)
                )
                .shadow(color: focusedField == index ? Color.white.opacity(0.1) : Color.clear, radius: 5)
        )
        .scaleEffect(focusedField == index ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: focusedField == index)
        .focused($focusedField, equals: index)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring()) {
                focusedField = index
            }
        }
        .overlay(
            TextField("", text: Binding(
                get: { return "" },
                set: { newValue in
                    let filtered = newValue.filter { $0.isNumber }
                    if !filtered.isEmpty {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                            scale = 1.2
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                                scale = 1.0
                            }
                        }
                        
                        if index == text.count {
                            text.append(filtered.last!)
                            if index < otpLength - 1 {
                                withAnimation(.spring()) {
                                    focusedField = index + 1
                                }
                            } else {
                                withAnimation {
                                    focusedField = nil
                                }
                            }
                        } else {
                            var currentText = text
                            if index < currentText.count {
                                let startIndex = currentText.startIndex
                                let charIndex = currentText.index(startIndex, offsetBy: index)
                                currentText.replaceSubrange(charIndex...charIndex, with: String(filtered.last!))
                                text = currentText
                                if index < otpLength - 1 {
                                    withAnimation(.spring()) {
                                        focusedField = index + 1
                                    }
                                } else {
                                    withAnimation {
                                        focusedField = nil
                                    }
                                }
                            }
                        }
                    }
                }
            ))
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
            .foregroundColor(.clear)
            .accentColor(.clear)
            .focused($focusedField, equals: index)
        )
        .onChange(of: focusedField) { newValue in
            isFocused = (newValue == index)
        }
    }
}

// Přidej tento náhled pro testování v designeru
struct OTPFieldView_Previews: PreviewProvider {
    @State static var code = ""
    
    static var previews: some View {
        ZStack {
            Color(red: 0.1, green: 0.15, blue: 0.25).ignoresSafeArea()
            OTPFieldView(otpCode: $code, otpLength: 5)
        }
    }
} 