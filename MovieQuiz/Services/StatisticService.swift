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
            if  userDefaults.double(forKey: Keys.total.rawValue) != 0 {
                let record = userDefaults.double(forKey: Keys.total.rawValue)
                return record
            }
            else {
                let beginTotalAccuracy = Double(bestGame.correct) / Double(bestGame.total)
                return beginTotalAccuracy
            }
        }
        
        set {
            let totalAccuracyRecord = totalAccuracy + newValue
            userDefaults.set(totalAccuracyRecord, forKey: Keys.total.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            if userDefaults.integer(forKey: Keys.gamesCount.rawValue) != 0 {
                let recordGamesCount = userDefaults.integer(forKey: Keys.gamesCount.rawValue)
                return recordGamesCount
        }  else {
                return .init(1)
            }
        }
        set {
            let gamesCountRecord = gamesCount + newValue
            userDefaults.set(gamesCountRecord, forKey: Keys.gamesCount.rawValue)
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
    /// метод протокола Comparable для сравнения типов GameRecord по свойству correct
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        lhs.correct < rhs.correct
    }
    
    var correct: Int
    var total: Int
    var date = Date().dateTimeString
}
