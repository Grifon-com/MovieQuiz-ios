import Foundation

protocol StatisticService {
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get set }
    var gamesCount: Int { get set }
    var bestGame: GameRecord { get set }
}

final class StatisticServiceImplementation: StatisticService {
    func store(correct count: Int, total amount: Int) {
        <#code#>
    }
    
    var totalAccuracy: Double
    
    var gamesCount: Int 
    
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
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
}
