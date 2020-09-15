//
//  UITableView.swift
//  JeweledKit
//
//  Created by Борис Анели on 06.09.2020.
//

import Foundation

public extension UITableView {
    
    /// Метод регистрирует nib для ячейки, если существует nib с названием соответствующим ячейке.
    /// В противном случае метод регистрирует класс ячейки для переиспользования.
    func register<T: UITableViewCell>(_ cellClass: T.Type) {
        let reuseIdentifier = String(describing: T.self)
        
        if let nib = obtainNibIfExists(in: Bundle(for: T.self), withName: T.nibName) {
            register(nib, forCellReuseIdentifier: reuseIdentifier)
        } else {
            register(cellClass, forCellReuseIdentifier: reuseIdentifier)
        }
    }
    
    /// Метод для переиспользования ячейки по nib или классу соответственно.
    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T {
        let reuseIdentifier = String(describing: T.self)
        guard let cell = dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(reuseIdentifier)")
        }
        
        return cell
    }
    
    // MARK: - Private
    
    /// Метод необходим, так как Nib из коробки не имеет failable initializer
    private func obtainNibIfExists(in bundle: Bundle, withName nibName: String) -> UINib? {
        return (bundle.path(forResource: nibName, ofType: "nib") != nil)
            ? UINib(nibName: nibName, bundle: bundle)
            : nil
    }
}

public extension UITableView {
    func configureAutomaticDimensions(estimatedRowHeight: CGFloat) {
        self.estimatedRowHeight = estimatedRowHeight
        rowHeight = UITableView.automaticDimension
    }
}

public extension CGFloat {
    static let pixelHeight: CGFloat = 1 / UIScreen.main.scale
}
