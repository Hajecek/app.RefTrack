import SwiftUI

struct Match: Codable, Identifiable {
    let id: String
    let competition: String
    let homeTeam: String
    let awayTeam: String
    let matchDate: String
    let location: String
    let homeScore: String
    let awayScore: String
    let role: String?
    let visibility: String?
    let payment: String?
    let created_by: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case competition
        case homeTeam = "home_team"
        case awayTeam = "away_team"
        case matchDate = "match_date"
        case location
        case homeScore = "home_score"
        case awayScore = "away_score"
        case role
        case visibility
        case payment
        case created_by = "created_by"
    }
}

extension Match: Equatable {
    static func == (lhs: Match, rhs: Match) -> Bool {
        return lhs.id == rhs.id &&
               lhs.competition == rhs.competition &&
               lhs.homeTeam == rhs.homeTeam &&
               lhs.awayTeam == rhs.awayTeam &&
               lhs.matchDate == rhs.matchDate &&
               lhs.homeScore == rhs.homeScore &&
               lhs.awayScore == rhs.awayScore &&
               lhs.role == rhs.role &&
               lhs.visibility == rhs.visibility &&
               lhs.payment == rhs.payment &&
               lhs.location == rhs.location &&
               lhs.created_by == rhs.created_by
    }
} 
