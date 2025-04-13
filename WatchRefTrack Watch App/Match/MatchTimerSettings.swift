import Foundation

// Třída pro centrální správu nastavení časovače zápasu
class MatchTimerSettings {
    // Singleton instance
    static let shared = MatchTimerSettings()
    
    // Délka prvního poločasu v minutách
    var firstHalfMinutes: Double = 45
    
    // Délka přestávky v minutách
    var halfTimePauseMinutes: Double = 15
    
    // Délka druhého poločasu v minutách
    var secondHalfMinutes: Double = 45
    
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
