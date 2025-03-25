import SwiftUI

struct TestEvent: Identifiable {
    let id = UUID()
    let title: String
    let time: String
}

struct TestEventsView: View {
    let testEvents: [TestEvent] = [
        TestEvent(title: "Trénink A", time: "10:00"),
        TestEvent(title: "Zápas B", time: "14:30"),
        TestEvent(title: "Schůzka", time: "18:00")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(testEvents) { event in
                HStack {
                    Text(event.time)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    Text(event.title)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red.opacity(0.3))
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
    }
} 