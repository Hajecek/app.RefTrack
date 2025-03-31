import SwiftUI

struct MatchCardDesign: View {
    let match: Match
    var addedBy: String = "Uživatel"
    
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
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(getVisibilityBorderColor(), lineWidth: 2.5)
            )
            .frame(width: UIScreen.main.bounds.width - 40, height: 600)
            .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
    }
    
    // Hlavní obsah
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            bubblesRow
                .padding(.top, 25)
            
            teamsSection
                .padding(.top, 25)
            
            Spacer() // Automatické roztažení prostoru mezi týmy a datem
            
            // Přidaná testovací bublina
            testBubble
                .padding(.bottom, 10)
            
            dateTimeBottomSection
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
            
            // Spodní řádek pouze s payment
            HStack(spacing: 8) {
                paymentBubble
                    .padding(.leading, -5)
                
                locationBubble
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
    
    // Bublina pro lokaci (přidat před paymentBubble)
    private var locationBubble: some View {
        let location = match.location ?? "Neuvedeno"
        
        return bubbleView(
            icon: "mappin.circle.fill",
            text: location,
            backgroundColor: Color.purple.opacity(0.3),
            gradientColors: [Color.purple.opacity(0.7), Color.purple.opacity(0.2)]
        )
    }
    
    // Sekce s týmy
    private var teamsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Domácí tým - bílá barva
            HStack(alignment: .center, spacing: 10) {
                // Logo nebo ikona pro domácí tým
                teamLogoOrIcon(teamName: match.homeTeam, color: .white)
                
                Text(match.homeTeam)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)  // Čistě bílá barva
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            
            // Hostující tým - světle modrá barva
            HStack(alignment: .center, spacing: 10) {
                // Logo nebo ikona pro hostující tým
                teamLogoOrIcon(teamName: match.awayTeam, color: Color(red: 0.85, green: 0.9, blue: 1.0))
                
                Text(match.awayTeam)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color(red: 0.85, green: 0.9, blue: 1.0)) // Jasněji modrá barva pro lepší kontrast
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(.horizontal, 0)
    }
    
    /// Pomocná funkce pro zobrazení loga nebo ikony týmu
    private func teamLogoOrIcon(teamName: String, color: Color) -> some View {
        // Vytvoření URL pro logo týmu - odstranění diakritiky, mezer a "B" týmu
        let formattedTeamName = teamName
            .trimmingCharacters(in: .whitespaces) // Odstranění mezer na začátku a konci
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression) // Nahrazení více mezer jednou
            .replacingOccurrences(of: " B$", with: "", options: .regularExpression) // Odstranění "B" na konci
            .folding(options: .diacriticInsensitive, locale: .current) // Odstranění diakritiky
            .replacingOccurrences(of: " ", with: "_")
            .lowercased()
        
        let logoURL = URL(string: "https://reftrack.cz/config/img/teams/\(formattedTeamName).png")
        
        return AsyncImage(url: logoURL) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: 45, height: 45)
            case .success(let image):
                Circle()
                    .fill(.white)
                    .frame(width: 45, height: 45)
                    .overlay(
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                    )
            case .failure:
                // Pokud se nepodaří načíst obrázek z URL, zkusíme lokální asset
                if UIImage(named: formattedTeamName) != nil {
                    Circle()
                        .fill(.white)
                        .frame(width: 45, height: 45)
                        .overlay(
                            Image(formattedTeamName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                        )
                } else {
                    // Pokud není k dispozici ani lokální asset, použijeme výchozí ikonu štítu
                    Image(systemName: "shield.fill")
                        .font(.system(size: 34))
                        .foregroundColor(color)
                }
            @unknown default:
                Image(systemName: "shield.fill")
                    .font(.system(size: 34))
                    .foregroundColor(color)
            }
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
    
    // Přidaná testovací bublina s visibility vedle
    private var testBubble: some View {
        HStack(spacing: 8) {
            bubbleView(
                icon: "person.fill",
                text: match.created_by ?? "Uživatel",
                backgroundColor: Color.blue.opacity(0.3),
                gradientColors: [Color.blue.opacity(0.7), Color.blue.opacity(0.2)]
            )
            
            visibilityBubble
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
    
    // Pomocná funkce pro získání barvy ohraničení podle viditelnosti
    private func getVisibilityBorderColor() -> Color {
        let visibility = match.visibility ?? "private" // Výchozí hodnota, když je visibility nil
        let isPublic = visibility.lowercased() == "public"
        
        return isPublic ? Color.green.opacity(0.5) : Color.red.opacity(0.5)
    }
} 
