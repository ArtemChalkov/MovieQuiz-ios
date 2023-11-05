//
//  QuestionFactoryTests.swift
//  MovieQuizTests
//
//  Created by Artur Igberdin on 05.11.2023.
//

import XCTest
@testable import MovieQuiz

final class QuestionFactoryTests: XCTestCase {

    func testConvertMostPopularMovieToQuizQuestion() {
        
        // Given
        let questionFactory = QuestionFactory()
        
        guard let imageURL = URL(string: "https://m.media-amazon.com/images/M/MV5BMDBlMDYxMDktOTUxMS00MjcxLWE2YjQtNjNhMjNmN2Y3ZDA1XkEyXkFqcGdeQXVyMTM1MTE1NDMx._V1_Ratio0.6716_AL_.jpg") else { return }
        
        let mostPopularMovie = MostPopularMovie(
            title: "The Gray Man (2022)",
            rating: "7.2",
            imageURL:  imageURL)
        
        // When
        let quizQuestion = questionFactory.convert(model: mostPopularMovie)
        
        // Then
        print(quizQuestion)
        
        let testQuestion = QuizQuestion(
            id: 3117,
            image:imageURL,
            rating: 7.2,
            question: "Рейтинг этого фильма больше чем 6?",
            answer: "Да")
        
        XCTAssertTrue(mostPopularMovie.imageURL == testQuestion.image)
        XCTAssertTrue(mostPopularMovie.rating == String(testQuestion.rating))
    }
}
