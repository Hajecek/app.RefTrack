import Foundation

// Třída pro centrální správu nastavení časovače zápasu
class MatchTimerSettings {
    // Singleton instance
    static let shared = MatchTimerSettings()
    
    // Délka prvního poločasu v minutách
    var firstHalfMinutes: Double = 0.1667 // 10 sekund
    
    // Délka přestávky v minutách
    var halfTimePauseMinutes: Double = 0.1667 // 10 sekund
    
    // Délka druhého poločasu v minutách
    var secondHalfMinutes: Double = 0.1667 // 10 sekund
    
    // Privátní inicializátor zabraňuje přímé tvorbě instancí
    private init() {}
    
    // Vrací délku prvního poločasu v sekundách
    var firstHalfTimeInSeconds: TimeInterval {
        return firstHalfMinutes * 60
    }
    
    // Vrací délku přestávky v sekundách
    var halfTimePauseInSeconds: TimeInterval {
        return halfTimePauseMinutes * 60
    }
    
    // Vrací délku druhého poločasu v sekundách
    var secondHalfTimeInSeconds: TimeInterval {
        return secondHalfMinutes * 60
    }
} 
