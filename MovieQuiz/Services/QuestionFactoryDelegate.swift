//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Agata on 09.05.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    
}
