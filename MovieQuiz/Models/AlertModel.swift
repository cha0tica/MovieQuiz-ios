//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Agata on 09.05.2023.
//

import Foundation
import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    var completion: () -> Void?
    
}

