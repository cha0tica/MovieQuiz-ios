//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Agata on 07.05.2023.
//

import Foundation

struct QuizQuestion { // модель-конструктор экрана
  // строка с названием фильма,
  let image: String
  // строка с вопросом о рейтинге фильма
  let text: String
  // правильный ответ на вопрос
  let correctAnswer: Bool
}
