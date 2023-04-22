//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Марина Машук on 21.04.23.
//

import Foundation

struct MostPopularMovies: Codable{
    let errorMessage: String
    let items: [MostPopularMovie]
}

struct MostPopularMovie: Codable {
    let title: String
    let rating: String
    let imageURL: URL
    
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }
}
