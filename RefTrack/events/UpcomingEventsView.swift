import SwiftUI

struct UpcomingEventsView: View {
    var body: some View {
        EventView(
            iconName: "calendar",
            iconColor: .blue,
            title: "Nadcházející události",
            description: "Zde uvidíte své plánované nadcházející události."
        )
    }
} 