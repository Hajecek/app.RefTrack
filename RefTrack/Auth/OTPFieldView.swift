import SwiftUI
import Combine

struct OTPFieldView: View {
    @Binding var otpCode: String
    let otpLength: Int
    
    @FocusState private var fieldFocus: Int?
    @State private var invalidInput: Bool = false
    @State private var shakeEffect: Bool = false
    
    var body: some View {
        HStack(spacing: 14) {
            ForEach(0..<otpLength, id: \.self) { index in
                OTPDigitField(
                    index: index,
                    text: $otpCode,
                    focusedField: $fieldFocus,
                    otpLength: otpLength,
                    invalidInput: $invalidInput,
                    onInvalidInput: handleInvalidInput
                )
                .frame(width: 50, height: 60)
                .modifier(ShakeEffect(animatableData: shakeEffect ? 1 : 0))
            }
        }
        .onAppear {
            withAnimation(.spring()) {
                fieldFocus = 0
            }
        }
    }
    
    private func handleInvalidInput(_ message: String) {
        invalidInput = true
        
        // Zobrazíme toast pomocí NotificationCenter
        NotificationCenter.default.post(
            name: Notification.Name("ShowToast"),
            object: nil,
            userInfo: ["message": message, "isSuccess": false]
        )
        
        // Spustit animaci zatřesení
        withAnimation(.default) {
            shakeEffect = true
        }
        
        // Reset stavů po určitém čase
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                shakeEffect = false
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            invalidInput = false
        }
    }
}

// Efekt zatřesení pro neplatný vstup
struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let shake = sin(animatableData * .pi * 8) * 5
        return ProjectionTransform(CGAffineTransform(translationX: shake, y: 0))
    }
}

struct OTPDigitField: View {
    let index: Int
    @Binding var text: String
    @FocusState.Binding var focusedField: Int?
    let otpLength: Int
    @Binding var invalidInput: Bool
    var onInvalidInput: (String) -> Void
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Pozadí s ohraničením
            backgroundView
            
            // Zobrazení číslice (pokud je zadaná)
            digitText
        }
        .frame(width: 50, height: 60)
        .scaleEffect(focusedField == index ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: focusedField == index)
        .focused($focusedField, equals: index)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring()) {
                focusedField = index
            }
        }
        .overlay(inputTextField)
    }
    
    // MARK: - Subviews
    
    private var digitText: some View {
        Group {
            if index < text.count {
                let startIndex = text.startIndex
                let charIndex = text.index(startIndex, offsetBy: index)
                let charToShow = text[charIndex]
                
                Text(String(charToShow))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(scale)
                    .onAppear {
                        animateDigitAppearance()
                    }
            }
        }
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(getBackgroundFill())
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(getBorderColor(), lineWidth: getBorderWidth())
            )
            .shadow(color: getShadowColor(), radius: 5)
    }
    
    private var inputTextField: some View {
        TextField("", text: Binding(
            get: { return "" },
            set: { handleTextInput($0) }
        ))
        .keyboardType(.numberPad)
        .textContentType(.oneTimeCode)
        .foregroundColor(.clear)
        .accentColor(.clear)
        .focused($focusedField, equals: index)
    }
    
    // MARK: - Helper Methods
    
    private func getBackgroundFill() -> Color {
        return invalidInput ? Color.red.opacity(0.15) : Color.white.opacity(0.08)
    }
    
    private func getBorderColor() -> Color {
        if invalidInput {
            return Color.red
        } else if focusedField == index {
            return Color.white
        } else {
            return Color.white.opacity(0.3)
        }
    }
    
    private func getBorderWidth() -> CGFloat {
        return focusedField == index ? 2.5 : 1.5
    }
    
    private func getShadowColor() -> Color {
        if invalidInput {
            return Color.red.opacity(0.2)
        } else if focusedField == index {
            return Color.white.opacity(0.1)
        } else {
            return Color.clear
        }
    }
    
    private func animateDigitAppearance() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            scale = 1.2
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.1)) {
            scale = 1.0
        }
    }
    
    private func handleTextInput(_ newValue: String) {
        // Validace vstupu - pouze číslice
        if newValue.isEmpty { return }
        
        let filtered = newValue.filter { $0.isNumber }
        
        if filtered.isEmpty {
            onInvalidInput("Zadejte prosím pouze číslice")
            return
        }
        
        animateDigitInput()
        
        if index == text.count {
            text.append(filtered.last!)
            moveFocusIfNeeded()
        } else if index < text.count {
            let startIndex = text.startIndex
            let charIndex = text.index(startIndex, offsetBy: index)
            text.replaceSubrange(charIndex...charIndex, with: String(filtered.last!))
            moveFocusIfNeeded()
        }
    }
    
    private func animateDigitInput() {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            scale = 1.2
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                scale = 1.0
            }
        }
    }
    
    private func moveFocusIfNeeded() {
        if index < otpLength - 1 {
            withAnimation(.spring()) {
                focusedField = index + 1
            }
        } else {
            withAnimation {
                focusedField = nil
            }
            
            // Verifikace po dokončení
            if text.count == otpLength {
                // Tady můžeme vyvolat akci přihlášení místo validace
                NotificationCenter.default.post(
                    name: Notification.Name("AutoSubmitOTP"),
                    object: nil
                )
            }
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