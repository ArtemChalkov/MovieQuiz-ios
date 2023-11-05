//
//  MovieLoaderTests.swift
//  MovieQuizTests
//
//  Created by Artur Igberdin on 05.11.2023.
//

import XCTest
@testable import MovieQuiz

final class MovieLoaderTests: XCTestCase {
    
    func testSuccessLoading() throws {
        
        // Given
        //let loader = MoviesLoader()
        let stubNetworkClient = StubNetworkClient(emulateError: false) // говорим, что не хотим эмулировать ошибку
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        // When
        // так как функция загрузки фильмов — асинхронная, нужно ожидание
        let expectation = expectation(description: "Loading expectation")
        
        loader.loadMovies { result in
            
            // Then
            switch result {
            case .success(let movies):
                
                // давайте проверим, что пришло, например, два фильма — ведь в тестовых данных их всего два
                XCTAssertEqual(movies.items.count, 2)
                
                expectation.fulfill()
            case .failure(_):
                // мы не ожидаем, что пришла ошибка; если она появится, надо будет провалить тест
                XCTFail("Unexpected failure") // эта функция проваливает тест
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testFailureLoading() throws {
        // Given
        //let loader = MoviesLoader()
        let stubNetworkClient = StubNetworkClient(emulateError: true) // говорим, что не хотим эмулировать ошибку
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        // When
        // так как функция загрузки фильмов — асинхронная, нужно ожидание
        let expectation = expectation(description: "Loading expectation")
        
        loader.loadMovies { result in
            
            // Then
            switch result {
            case .success(let movies):
                
                XCTFail("Unexpected failure")
                
            case .failure(let error):
              
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    
    
}
