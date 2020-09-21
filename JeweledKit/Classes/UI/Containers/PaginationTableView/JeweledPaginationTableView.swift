//
//  JeweledPaginationTableView.swift
//  JeweledKit
//
//  Created by Борис Анели on 21.09.2020.
//

import UIKit

class JeweledPaginationTableView: UIView {
    
    let refreshControl = UIRefreshControl()
    let tableView = UITableView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        tableView.refreshControl = refreshControl
    }
}

