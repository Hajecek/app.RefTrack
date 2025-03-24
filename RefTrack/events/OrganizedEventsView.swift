import SwiftUI

struct OrganizedEventsView: View {
    var body: some View {
        EventView(
            iconName: "crown",
            iconColor: .yellow,
            title: "Pořádané události",
            description: "Seznam událostí, které organizujete."
        )
    }
} 