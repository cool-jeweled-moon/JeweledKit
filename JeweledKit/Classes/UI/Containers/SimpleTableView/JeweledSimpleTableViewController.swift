//
//  JeweledSimpleTableViewController.swift
//  JeweledKit
//
//  Created by Борис Анели on 15.09.2020.
//

import UIKit

private struct Constants {
    static let contentSizeKey = "contentSize"
}

public struct JeweledSimpleTableViewConfiguration {
    public var separatorColor = UITableView().separatorColor
    public var showTopSeparator = true
    public var showBottomSeparator = true
    public var leftSeparatorInset: CGFloat = 0
    public var rightSeparatorInset: CGFloat = 0
    public var rowHeight: CGFloat = UITableView.automaticDimension
    public var estimatedRowHeight: CGFloat = 100
    public var allowAnimations: Bool = true
}

public class JeweledSimpleTableViewController<Cell>: UIViewController, UITableViewDataSource, UITableViewDelegate
where Cell: UITableViewCell, Cell: JeweledConfigurableView {
    
    // Models
    public var dataSource: [Cell.ConfigurationModel] = [] {
        didSet {
            tableView?.reloadData()
        }
    }
    private var configuration = JeweledSimpleTableViewConfiguration()

    public var selectActionBlock: ((_ datasourceIndex: Int) -> Void)? {
        didSet {
            updateSelecionEnabled()
        }
    }

    // UI
    @IBOutlet public weak var tableView: UITableView!
    @IBOutlet private weak var viewWithSeparators: JeweledViewWithSeparators!
    @IBOutlet private weak var viewHeightConstraint: NSLayoutConstraint?
    @IBOutlet private weak var tableViewBottomConstraint: NSLayoutConstraint?

    // MARK: - Initialization
    
    convenience init() {
        self.init(nibName: "JeweledSimpleTableViewController", bundle: Bundle(for: Self.self))
    }

    deinit {
        tableView?.removeObserver(self, forKeyPath: Constants.contentSizeKey)
    }
    
    // MARK: - Life Cycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        updateSelecionEnabled()
        configure(with: configuration)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Public API
    
    public func configure(with configuration: JeweledSimpleTableViewConfiguration) {
        self.configuration = configuration
        
        tableView?.separatorColor = self.configuration.separatorColor
        viewWithSeparators?.showTopSeparator(show: configuration.showTopSeparator)
        viewWithSeparators?.showBottomSeparator(show: configuration.showBottomSeparator)
    }
    
    func setup(dataSource: [Cell.ConfigurationModel]) {
        self.dataSource = dataSource
    }
    
    // MARK: - KVO
    
    public override func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey: Any]?,
                                      context: UnsafeMutableRawPointer?) {
        guard let obj = object as? NSObject, let path = keyPath else {
            return
        }
        
        if obj == tableView && path == "contentSize" {
            let newHeight = tableView.contentSize.height
            viewHeightConstraint?.constant = newHeight
        }
    }
    
    // MARK: - Private API
    
    private func configureTableView() {
        // Auto-layout
        tableView.configureAutomaticDimensions(estimatedRowHeight: configuration.estimatedRowHeight)
        
        tableView.dataSource = self
        tableView.delegate = self

        // Cells
        tableView.register(Cell.self)
        
        // Change content size with KVO
        tableView.addObserver(self, forKeyPath: Constants.contentSizeKey,
                              options: NSKeyValueObservingOptions.new, context: nil)
        
        // Hide bottom separator
        tableViewBottomConstraint?.constant = .pixelHeight
        
        tableView.separatorInset.left = configuration.leftSeparatorInset
        tableView.separatorInset.right = configuration.rightSeparatorInset
    }
    
    private func updateSelecionEnabled() {
        tableView?.allowsSelection = (selectActionBlock != nil)
    }
    
    // MARK: - UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: Cell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        
        cell.configure(with: dataSource[indexPath.row])
        cell.separatorInset.left = configuration.leftSeparatorInset
        cell.separatorInset.right = configuration.rightSeparatorInset
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return configuration.rowHeight
    }
    
    // MARK: - UITableViewDelegate
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectActionBlock?(indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

final class JeweledNoAnimationsSimpleTableViewController<Cell>: JeweledSimpleTableViewController<Cell>
where Cell: UITableViewCell, Cell: JeweledConfigurableView {
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        UIView.performWithoutAnimation {
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        return cell ?? UITableViewCell()
    }
}
