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
            let record =  userDefaults.double(forKey: Keys.total.rawValue) != 0 ? userDefaults.double(forKey: Keys.total.rawValue) : Double(bestGame.correct) / Double(bestGame.total)
            
            return record
        }
        
        set {
            let totalAccuracyRecord = totalAccuracy + newValue
            userDefaults.set(totalAccuracyRecord, forKey: Keys.total.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue) ?? 1
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
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
