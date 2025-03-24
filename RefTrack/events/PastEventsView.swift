import SwiftUI

struct PastEventsView: View {
    var body: some View {
        EventView(
            iconName: "arrow.clockwise",
            iconColor: .purple,
            title: "Předchozí",
            description: "Přehled událostí, které už skončily."
        )
    }
} 