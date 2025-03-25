import SwiftUI

struct MatchCardDesign: View {
    let match: Match
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            contentView
        }
    }
    
    // Pozadí s gradientem
    private var backgroundGradient: some View {
        RoundedRectangle(cornerRadius: 30)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.0, green: 0.44, blue: 0.8),  // Světlejší modrá
                        Color(red: 0.0, green: 0.22, blue: 0.55)   // Tmavší modrá
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: UIScreen.main.bounds.width - 40, height: 600)
            .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
    }
    
    // Hlavní obsah
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            bubblesRow
                .padding(.top, 30)
            
            teamsSection
                .padding(.top, 25)
            
            mainContent
                .padding(.top, 10)
        }
        .padding(30)
    }
    
    // Řada bublin nahoře
    private var bubblesRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Horní řádek s role a competition vedle sebe
            HStack(spacing: 8) {
                roleBubble
                    .padding(.leading, -5)
                
                competitionBubble
            }
            
            // Spodní řádek s visibility a payment vedle sebe
            HStack(spacing: 8) {
                visibilityBubble
                    .padding(.leading, -5)
                
                paymentBubble
            }
        }
    }
    
    // Bublina pro roli
    private var roleBubble: some View {
        bubbleView(
            icon: "sharedwithyou",
            text: match.role ?? "",
            backgroundColor: Color.white.opacity(0.15),
            gradientColors: [Color.white.opacity(0.6), Color.white.opacity(0.1)]
        )
    }
    
    // Bublina pro soutěž
    private var competitionBubble: some View {
        bubbleView(
            icon: "trophy.fill",
            text: match.competition,
            backgroundColor: Color.white.opacity(0.15),
            gradientColors: [Color.white.opacity(0.6), Color.white.opacity(0.1)]
        )
    }
    
    // Bublina pro viditelnost
    private var visibilityBubble: some View {
        let visibility = match.visibility ?? "private" // Výchozí hodnota, když je visibility nil
        let isPublic = visibility.lowercased() == "public"
        
        // České překlady
        let visibilityText = isPublic ? "Veřejný" : "Soukromé"
        let icon = isPublic ? "eye.fill" : "eye.slash.fill"
        let backgroundColor = isPublic ? Color.green.opacity(0.3) : Color.red.opacity(0.3)
        let gradientColors = isPublic 
            ? [Color.green.opacity(0.7), Color.green.opacity(0.2)]
            : [Color.red.opacity(0.7), Color.red.opacity(0.2)]
        
        return Group {
            VStack(spacing: 2) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                        .shadow(color: .white.opacity(0.3), radius: 1)
                    
                    Text(visibilityText)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 1)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: gradientColors),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            )
        }
    }
    
    // Bublina pro platbu
    private var paymentBubble: some View {
        let paymentAmount = match.payment ?? "0"
        
        // Převod na číslo a zpět bez desetinných míst
        let formattedAmount: String
        if let doubleValue = Double(paymentAmount) {
            if doubleValue == 0 {
                formattedAmount = "Nezaplaceno"
            } else {
                // Převedení na celé číslo (odstranění desetinných míst)
                formattedAmount = "\(Int(doubleValue)) Kč"
            }
        } else {
            formattedAmount = "\(paymentAmount) Kč"
        }
        
        let isZero = (paymentAmount == "0") || (paymentAmount == "0.0") || (paymentAmount == "0.00")
        let icon = isZero ? "creditcard.fill" : "banknote.fill"
        let backgroundColor = isZero ? Color.orange.opacity(0.3) : Color.yellow.opacity(0.3)
        let gradientColors = isZero 
            ? [Color.orange.opacity(0.7), Color.orange.opacity(0.2)]
            : [Color.yellow.opacity(0.7), Color.yellow.opacity(0.2)]
        
        return bubbleView(
            icon: icon,
            text: formattedAmount,
            backgroundColor: backgroundColor,
            gradientColors: gradientColors
        )
    }
    
    // Sekce s týmy
    private var teamsSection: some View {
        HStack {
            VStack(alignment: .center, spacing: 10) {
                Text(match.homeTeam)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("vs")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(match.awayTeam)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // Hlavní obsah
    private var mainContent: some View {
        VStack(spacing: 25) {
            Spacer()
            
            Spacer()
            
            dateTimeBottomSection
        }
    }
    
    // Střední sekce s datem a časem - ponechávám definici, ale nepoužívám ji
    private var dateTimeMiddleSection: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Text(formatDate(match.matchDate))
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            Spacer()
        }
    }
    
    // Spodní sekce s datem a časem
    private var dateTimeBottomSection: some View {
        HStack {
            let (dateText, timeText) = splitDateTime(match.matchDate)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(dateText)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                
                Text(timeText)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.bottom, 35)
            }
            
            Spacer()
        }
    }
    
    // Pomocná funkce pro vytvoření bubliny
    private func bubbleView(
        icon: String, 
        text: String, 
        backgroundColor: Color, 
        gradientColors: [Color]
    ) -> some View {
        Group {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                    .shadow(color: .white.opacity(0.3), radius: 1)
                
                Text(text)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: gradientColors),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            )
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "d.M.yyyy 'a' HH:mm"
            return dateFormatter.string(from: date)
        }
        
        return dateString
    }
    
    private func splitDateTime(_ dateString: String) -> (String, String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = dateFormatter.date(from: dateString) {
            // Formát pro datum
            let dateOnlyFormatter = DateFormatter()
            dateOnlyFormatter.dateFormat = "d.M.yyyy"
            let dateText = dateOnlyFormatter.string(from: date)
            
            // Formát pro čas
            let timeOnlyFormatter = DateFormatter()
            timeOnlyFormatter.dateFormat = "HH:mm"
            let timeText = timeOnlyFormatter.string(from: date)
            
            return (dateText, timeText)
        }
        
        return (dateString, "")
    }
} 
