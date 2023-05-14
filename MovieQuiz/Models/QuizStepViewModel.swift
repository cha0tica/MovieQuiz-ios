//
//  QuizStepViewModel.swift
//  MovieQuiz
//
//  Created by Agata on 07.05.2023.
//

import Foundation
import UIKit 

struct QuizStepViewModel { // модель для  "вопрос показан"
  // картинка с афишей
  let image: UIImage
  // вопрос о рейтинге квиза
  let question: String
  // порядковый номер вопроса
  let questionNumber: String
}
