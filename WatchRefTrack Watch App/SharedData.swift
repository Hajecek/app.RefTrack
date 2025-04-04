import Foundation
import Combine

class SharedData: ObservableObject {
    @Published var distance: Double = 0.0
    @Published var homeGoals = 0
    @Published var awayGoals = 0
    @Published var homeYellowCards = 0
    @Published var awayYellowCards = 0
    @Published var homeRedCards = 0
    @Published var awayRedCards = 0
} 