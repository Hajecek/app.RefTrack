import SwiftUI

struct PublicEventsView: View {
    var body: some View {
        EventView(
            iconName: "checkmark.circle",
            iconColor: .green,
            title: "Veřejné události",
            description: "Události, které ostatní uživatelé označili za veřejné."
        )
    }
} 