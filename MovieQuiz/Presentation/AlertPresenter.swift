//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Agata on 09.05.2023.
//

import Foundation
import UIKit

protocol AlertPresenterProtocol {
    func show(alertModel: AlertModel)
}

final class AlertPresenterImplementation {
    private weak var viewController: UIViewController?
    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }
    
}

extension AlertPresenterImplementation: AlertPresenterProtocol {
    func show(alertModel: AlertModel) {
            let alert = UIAlertController(
                title: alertModel.title,
                message: alertModel.message,
                preferredStyle: .alert)
            
            let action = UIAlertAction(title: alertModel.buttonText, style: .default, handler: alertModel.completion)
            
            alert.addAction(action)
            viewController?.present(alert, animated: true, completion: nil)
        
    }
    }

