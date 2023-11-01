//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Артем Чалков on 17.10.2023.
//

import UIKit

struct QuizQuestion {
    let id: Int
    let image: URL
    let rating: Double
    let question: String
    let answer: String
    
    func loadImage(completion: @escaping (UIImage)->()){
        var filmImage: UIImage = UIImage()
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: image) {
                filmImage = UIImage(data: data) ?? UIImage()
                DispatchQueue.main.async {
                    completion(filmImage)
                }
            }
        }
    }
}


