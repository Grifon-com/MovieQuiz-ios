import Foundation

protocol StatisticService {
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get set }
    var gamesCount: Int { get set }
    var bestGame: GameRecord { get set }
}

final class StatisticServiceImplementation: StatisticService {
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    private let userDefaults = UserDefaults.standard
    
    var totalAccuracy: Double {
        get {
            guard let data = userDefaults.data(forKey: Keys.total.rawValue),
                  let record = try? JSONDecoder().decode(Double.self, from: data) else {
                return Double(bestGame.correct) / Double(bestGame.total)
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(totalAccuracy + newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.total.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.gamesCount.rawValue),
                  let recordGamesCount = try? JSONDecoder().decode(Int.self, from: data) else {
            return .init(1)
            }
            return recordGamesCount
        }
        set {
            guard let data = try? JSONEncoder().encode(gamesCount + newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0)
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        let currentGame = GameRecord(correct: count, total: amount)
        if currentGame > bestGame {
            bestGame = currentGame
        }
    }
}

// MARK: - GameRecord
struct GameRecord: Codable, Comparable {
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        lhs.correct < rhs.correct
    }
    
    var correct: Int
    var total: Int
    var date = Date().dateTimeString
}

}
