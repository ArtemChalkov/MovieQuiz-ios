//
//  Codable.swift
//  MovieQuiz
//
//  Created by Артем Чалков on 26.10.2023.
//

import Foundation

import UIKit

//struct QuizQuestion {
//    let image: String
//    let text: String
//    let correctAnswer: Bool
//}


struct MostPopularMovies: Codable {
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

