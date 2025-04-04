import SwiftUI

struct Match: Codable, Identifiable {
    let id: String
    let competition: String
    let homeTeam: String
    let awayTeam: String
    let matchDate: String
    let location: String?
    let firstHalfDuration: String
    let secondHalfDuration: String
    let homeScore: String
    let awayScore: String
    let role: String
    let distanceRun: String
    let payment: String
    let yellowCards: String
    let redCards: String
    let delegateRating: String
    let matchReview: String?
    let headReferee: String?
    let assistantReferee1: String?
    let assistantReferee2: String?
    let fourthOfficial: String?
    let delegateName: String?
    let visibility: String
    let status: String
    let createdAt: String
    let createdBy: String
    
    var totalMatchTime: Int {
        let firstHalf = parseDuration(duration: firstHalfDuration)
        let secondHalf = parseDuration(duration: secondHalfDuration)
        return firstHalf + secondHalf
    }
    
    private func parseDuration(duration: String) -> Int {
        let components = duration.components(separatedBy: "+")
        let mainTime = Int(components[0]) ?? 0
        let addedTime = components.count > 1 ? (Int(components[1]) ?? 0) : 0
        return mainTime + addedTime
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case competition
        case homeTeam = "home_team"
        case awayTeam = "away_team"
        case matchDate = "match_date"
        case location
        case firstHalfDuration = "first_half_duration"
        case secondHalfDuration = "second_half_duration"
        case homeScore = "home_score"
        case awayScore = "away_score"
        case role
        case distanceRun = "distance_run"
        case payment
        case yellowCards = "yellow_cards"
        case redCards = "red_cards"
        case delegateRating = "delegate_rating"
        case matchReview = "match_review"
        case headReferee = "head_referee"
        case assistantReferee1 = "assistant_referee_1"
        case assistantReferee2 = "assistant_referee_2"
        case fourthOfficial = "fourth_official"
        case delegateName = "delegate_name"
        case visibility
        case status
        case createdAt = "created_at"
        case createdBy = "created_by"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Inicializace ostatních vlastností
        id = try container.decode(String.self, forKey: .id)
        competition = try container.decode(String.self, forKey: .competition)
        homeTeam = try container.decode(String.self, forKey: .homeTeam)
        awayTeam = try container.decode(String.self, forKey: .awayTeam)
        matchDate = try container.decode(String.self, forKey: .matchDate)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        firstHalfDuration = try container.decode(String.self, forKey: .firstHalfDuration)
        secondHalfDuration = try container.decode(String.self, forKey: .secondHalfDuration)
        homeScore = try container.decode(String.self, forKey: .homeScore)
        awayScore = try container.decode(String.self, forKey: .awayScore)
        role = try container.decode(String.self, forKey: .role)
        distanceRun = try container.decode(String.self, forKey: .distanceRun)
        payment = try container.decode(String.self, forKey: .payment)
        yellowCards = try container.decode(String.self, forKey: .yellowCards)
        redCards = try container.decode(String.self, forKey: .redCards)
        delegateRating = try container.decode(String.self, forKey: .delegateRating)
        matchReview = try container.decodeIfPresent(String.self, forKey: .matchReview)
        headReferee = try container.decodeIfPresent(String.self, forKey: .headReferee)
        assistantReferee1 = try container.decodeIfPresent(String.self, forKey: .assistantReferee1)
        assistantReferee2 = try container.decodeIfPresent(String.self, forKey: .assistantReferee2)
        fourthOfficial = try container.decodeIfPresent(String.self, forKey: .fourthOfficial)
        delegateName = try container.decodeIfPresent(String.self, forKey: .delegateName)
        visibility = try container.decode(String.self, forKey: .visibility)
        status = try container.decode(String.self, forKey: .status)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        createdBy = try container.decode(String.self, forKey: .createdBy)
    }
}

extension Match: Equatable {
    static func == (lhs: Match, rhs: Match) -> Bool {
        return lhs.id == rhs.id &&
               lhs.competition == rhs.competition &&
               lhs.homeTeam == rhs.homeTeam &&
               lhs.awayTeam == rhs.awayTeam &&
               lhs.matchDate == rhs.matchDate &&
               lhs.location == rhs.location &&
               lhs.firstHalfDuration == rhs.firstHalfDuration &&
               lhs.secondHalfDuration == rhs.secondHalfDuration &&
               lhs.homeScore == rhs.homeScore &&
               lhs.awayScore == rhs.awayScore &&
               lhs.role == rhs.role &&
               lhs.distanceRun == rhs.distanceRun &&
               lhs.payment == rhs.payment &&
               lhs.yellowCards == rhs.yellowCards &&
               lhs.redCards == rhs.redCards &&
               lhs.delegateRating == rhs.delegateRating &&
               lhs.matchReview == rhs.matchReview &&
               lhs.headReferee == rhs.headReferee &&
               lhs.assistantReferee1 == rhs.assistantReferee1 &&
               lhs.assistantReferee2 == rhs.assistantReferee2 &&
               lhs.fourthOfficial == rhs.fourthOfficial &&
               lhs.delegateName == rhs.delegateName &&
               lhs.visibility == rhs.visibility &&
               lhs.status == rhs.status &&
               lhs.createdAt == rhs.createdAt &&
               lhs.createdBy == rhs.createdBy
    }
}

extension Match {
    var totalMatchTimeInt: Int {
        return totalMatchTime
    }

    var paymentDouble: Double {
        return Double(payment) ?? 0.0
    }
} 
