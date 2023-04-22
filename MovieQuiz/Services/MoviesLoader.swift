//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Григорий Машук on 21.04.23.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping(Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    //MARK: -NetworkClient
    private let networkClient = NetworkClient()
    
    //MARK: -URL
    
    private var mostPopularMoviesUrl: URL {
        // Если мы не смогли преобразовать строку в URL, то приложение упадёт с ошибкой
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_y7m73zfd") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    /*
     public enum Result<Success, Failure> where Failure : Error {
         case success(Success)
         case failure(Failure)
     }
     */
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fech(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovie = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovie))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
        }
}
