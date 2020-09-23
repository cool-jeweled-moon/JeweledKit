//
//  JeweledPaginationTableViewController.swift
//  JeweledKit
//
//  Created by Борис Анели on 21.09.2020.
//

import UIKit

public enum PaginationTableCellType<Cell: JeweledConfigurableView,
                                    LoaderCell: JeweledConfigurableView> {
    case cell(model: Cell.ConfigurationModel)
    case loader(model: LoaderCell.ConfigurationModel)
}

public protocol JeweledPaginationTableViewDataSource {
    
    typealias CellType = PaginationTableCellType<Cell, LoaderCell>
    
    associatedtype Cell: UITableViewCell, JeweledConfigurableView
    associatedtype LoaderCell: UITableViewCell, JeweledConfigurableView
    associatedtype Model
    
    var cellModels: [CellType] { get }
    var models: [Model] { get }
    
    func loadData(searchText: String?,
                  updateUI: @escaping (Error?) -> Void)
    
    func refresh(searchText: String?,
                 updateUI: @escaping (Error?) -> Void)
}

public struct JeweledPaginationTableViewConfiguration {
    public var searchDebounce: TimeInterval
    public var estimatedRowHeight: CGFloat
    public var showTopSeparator: Bool
    public var showSeparatorsWhileEmpty: Bool
    public var emptySearchedDataMessage: String?
    public var emptyDataSourceMessage: String?
    
    public init(searchDebounce: TimeInterval = 0.2,
                estimatedRowHeight: CGFloat = 100.0,
                showTopSeparator: Bool = false,
                showSeparatorsWhileEmpty: Bool = false,
                emptyDataSourceMessage: String? = "No data",
                emptySearchedDataMessage: String? = "Not found") {
        self.searchDebounce = searchDebounce
        self.estimatedRowHeight = estimatedRowHeight
        self.showTopSeparator = showTopSeparator
        self.showSeparatorsWhileEmpty = showSeparatorsWhileEmpty
        self.emptyDataSourceMessage = emptyDataSourceMessage
        self.emptySearchedDataMessage = emptySearchedDataMessage
    }
}

public final class JeweledPaginationTableViewController<DataSource>: UIViewController,
UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate
where DataSource: JeweledPaginationTableViewDataSource {
    
    public var selectionActionBlock: ((_ model: DataSource.Model,
                                       _ configurationModel: DataSource.Cell.ConfigurationModel) -> Void)? {
        didSet {
            paginationTableView.tableView.allowsSelection = selectionActionBlock != nil
        }
    }
    
    public var tableView: UITableView {
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
    
    public required init(dataSource: DataSource,
                         configuration: JeweledPaginationTableViewConfiguration = JeweledPaginationTableViewConfiguration()) {
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
        tableView.register(DataSource.LoaderCell.self)
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
        dataSource.loadData(searchText: searchText) { [weak self] error in
            self?.updateUI(error)
        }
    }
    
    private func refresh() {
        dataSource.refresh(searchText: searchText) { [weak self] error in
            self?.updateUI(error)
        }
    }
    
    private func updateUI(_ error: Error?) {
        DispatchQueue.main.asyncIfNeeded { [weak self] in
            guard let self = self else { return }

            self.paginationTableView.refreshControl.endRefreshing()
            self.paginationTableView.tableView.reloadData()
            if let error = error {
                self.showAlert(error: error)
            }
        }
    }
    // MARK: — UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch dataSource.cellModels[indexPath.row] {
        case .cell(let model):
            let cell: DataSource.Cell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.configure(with: model)
            
            return cell
        case .loader(let model):
            let cell: DataSource.LoaderCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.configure(with: model)
            cell.selectionStyle = .none
            cell.separatorInset.left = CGFloat.greatestFiniteMagnitude
            
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.cellModels.count
    }
    
    // MARK: — UITableViewDelegate
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch dataSource.cellModels[indexPath.row] {
        case .cell(let configurationModel):
            let model = dataSource.models[indexPath.row]
            selectionActionBlock?(model, configurationModel)
        default: return
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let containsData = dataSource.cellModels.contains(where: {
            if case .cell = $0 {
                return true
            }
            
            return false
        })
        
        if containsData, indexPath.row == dataSource.cellModels.count - 1 {
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
