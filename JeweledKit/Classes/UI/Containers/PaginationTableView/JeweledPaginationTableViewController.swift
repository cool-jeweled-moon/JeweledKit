//
//  JeweledPaginationTableViewController.swift
//  JeweledKit
//
//  Created by Борис Анели on 21.09.2020.
//

import UIKit

public protocol JeweledPaginationTableViewDataSource {
    
    associatedtype Cell: UITableViewCell, JeweledConfigurableView
    
    var configurationModels: [Cell.ConfigurationModel] { get }
    
    func loadData(searchText: String?,
                  completion: @escaping (Error?) -> Void)
    
    func refresh(searchText: String?,
                 completion: @escaping (Error?) -> Void)
}

public struct JeweledPaginationTableViewConfiguration {
    public var searchDebounce: TimeInterval = 0.2
    public var estimatedRowHeight:CGFloat = 100.0
    public var showTopSeparator: Bool = false
    public var showSeparatorsWhileEmpty: Bool = false
    public var emptyDataSourceMessage = "Not found"
}

public final class JeweledPaginationTableViewController<DataSource>: UIViewController,
UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate
where DataSource: JeweledPaginationTableViewDataSource {
    
    var selectionActionBlock: ((_ model: DataSource.Cell.ConfigurationModel) -> Void)? {
        didSet {
            paginationTableView.tableView.allowsSelection = selectionActionBlock != nil
        }
    }
    
    var tableView: UITableView {
        paginationTableView.tableView
    }
    
    private let paginationTableView = JeweledPaginationTableView()
    private lazy var debouncer = JeweledDebouncer(delay: configuration.searchDebounce)
    
    private let dataSource: DataSource
    private let configuration: JeweledPaginationTableViewConfiguration
    private var searchText: String? {
        didSet {
            loadData()
        }
    }
    
    public init(dataSource: DataSource,
                configuration: JeweledPaginationTableViewConfiguration) {
        self.dataSource = dataSource
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func loadView() {
        view = paginationTableView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        loadData()
    }
    
    private func configureUI() {
        tableView.register(DataSource.Cell.self)
        tableView.configureAutomaticDimensions(estimatedRowHeight: configuration.estimatedRowHeight)
        tableView.tableHeaderView = configuration.showTopSeparator ? nil : UIView()
        tableView.tableFooterView = configuration.showSeparatorsWhileEmpty ? nil : UIView()
        tableView.delegate = self
        tableView.dataSource = self
        paginationTableView.refreshControl.addTarget(self,
                                                     action: #selector(refreshControlValueChanged),
                                                     for: .valueChanged)
    }
    
    // MARK: - Public
    
    public func beginUpdates() {
        paginationTableView.tableView.beginUpdates()
    }
    
    public func endUpdates() {
        paginationTableView.tableView.endUpdates()
    }
    
    public func reloadData() {
        paginationTableView.tableView.reloadData()
    }
    
    public func reloadRows(at indexPaths: [IndexPath]) {
        paginationTableView.tableView.reloadRows(at: indexPaths,
                                                 with: .none)
    }
    
    // MARK: — Data fetching
    
    private func loadData() {
        if dataSource.configurationModels.isEmpty {
            showLockActivityView(in: tableView)
        }

        dataSource.loadData(searchText: searchText) { [weak self] error in
            self?.handleResult(error)
        }
    }
    
    private func refresh() {
        dataSource.refresh(searchText: searchText) { [weak self] error in
            self?.handleResult(error)
        }
    }
    
    private func handleResult(_ error: Error?) {
        DispatchQueue.main.asyncIfNeeded { [weak self] in
            guard let self = self else { return }
            
            self.paginationTableView.refreshControl.endRefreshing()
            
            if let error = error {
                if self.dataSource.configurationModels.isEmpty {
                    self.showLockActivityViewMessage(text: error.localizedDescription)
                } else {
                    self.showAlert(error: error)
                    self.hideLockActivityView()
                }
            } else {
                if self.dataSource.configurationModels.isEmpty {
                    self.showLockActivityViewMessage(text: self.configuration.emptyDataSourceMessage)
                } else {
                    self.hideLockActivityView()
                }
                self.paginationTableView.tableView.reloadData()
            }
        }
    }
    
    // MARK: — UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DataSource.Cell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.configure(with: dataSource.configurationModels[indexPath.row])
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.configurationModels.count
    }
    
    // MARK: — UITableViewDelegate
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectionActionBlock?(dataSource.configurationModels[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == dataSource.configurationModels.count - 1 {
            loadData()
        }
    }
    
    // MARK: - UISearchBarDelegate

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        debouncer.run { [weak self] in
            self?.searchText = searchText
        }
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Actions

    @objc private func refreshControlValueChanged() {
        refresh()
    }
}
