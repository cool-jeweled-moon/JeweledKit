//
//  JeweledCoordinator.swift
//  JeweledKit
//
//  Created by Борис Анели on 19.09.2020.
//

import Foundation

public protocol JeweledCoordinator {
    var childCoordinators: [JeweledCoordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start()
}
