//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Артем Чалков on 05.11.2023.
//

import XCTest

final class MovieQuizUITests: XCTestCase {

    var app: XCUIApplication!

    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testYesButton_ScoreLabelChanged() {
        let firstScore = app.staticTexts["Score"]
        let firstPoster = app.images["Poster"]
        
        app.buttons["Yes"].tap() // находим кнопку `Да` и нажимаем её
        
        let secondScore = app.staticTexts["Score"]
        let secondPoster = app.images["Poster"]
        
        XCTAssertFalse(firstPoster == secondPoster)
        XCTAssertFalse(firstScore == secondScore) // проверяем, что номер вопроса разный
    }
    
    func testNoButton_ScoreLabelChanged() {
        
        let firstScore = app.staticTexts["Score"]
        let firstPoster = app.images["Poster"]
 
        app.buttons["No"].tap() // находим кнопку `Да` и нажимаем её

        let secondScore = app.staticTexts["Score"]
        let secondPoster = app.images["Poster"]
        
        XCTAssertFalse(firstPoster == secondPoster)
        XCTAssertFalse(firstScore == secondScore) // проверяем, что номер вопроса разный
    }
    
    func testGameFinish() {
        
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }

        let alert = app.alerts["GameResults"]
        
        XCTAssertTrue(alert.exists)
        
        print(alert.label)
        print(alert.buttons.firstMatch.label)
        
        XCTAssertTrue(alert.label == "Раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз")
    }
    
    func testAlertDismiss() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["GameResults"]
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        
        let indexLabel = app.staticTexts["Score"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
}
