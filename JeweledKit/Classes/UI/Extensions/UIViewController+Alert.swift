//
//  UIViewController+Alert.swift
//  JeweledKit
//
//  Created by Борис Анели on 22.09.2020.
//

import UIKit

private enum Constants {
    static let okActionTitle = "OK"
}

extension UIViewController {
    
    func showAlert(error: Error, completion: (() -> (Void))? = nil) {
        showAlert(message: error.localizedDescription, completion: completion)
    }
    
    func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(createOKAction(completion: completion))
        present(alert, animated: true)
    }
    
    private func createOKAction(completion: (() -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: Constants.okActionTitle, style: .default) { _ in
            completion?()
        }
    }
}
