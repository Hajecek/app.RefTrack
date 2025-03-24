import SwiftUI

struct LiveEventsView: View {
    var body: some View {
        EventView(
            iconName: "pencil",
            iconColor: .orange,
            title: "Právě se děje",
            description: "Události, které jsou právě Live."
        )
    }
}