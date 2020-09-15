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

public struct JeweledSimpleTableViewConfigurator {
    var separatorColor = UITableView().separatorColor
    var showTopSeparator = true
    var showBottomSeparator = true
    var leftSeparatorInset: CGFloat = 0
    var rightSeparatorInset: CGFloat = 0
    var rowHeight: CGFloat = UITableView.automaticDimension
    var estimatedRowHeight: CGFloat = 100
    var allowAnimations: Bool = true
}

public class JeweledSimpleTableViewController<Cell>: UIViewController, UITableViewDataSource, UITableViewDelegate
where Cell: UITableViewCell, Cell: JeweledConfigurableView {
    
    // Models
    public var dataSource: [Cell.ConfigurationModel] = [] {
        didSet {
            tableView?.reloadData()
        }
    }
    private var configurator = JeweledSimpleTableViewConfigurator()

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
        self.init(nibName: "SimpleTableViewContainer", bundle: nil)
    }

    deinit {
        tableView?.removeObserver(self, forKeyPath: Constants.contentSizeKey)
    }
    
    // MARK: - Life Cycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        updateSelecionEnabled()
        configure(with: self.configurator)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Public API
    
    public func configure(with configurator: JeweledSimpleTableViewConfigurator) {
        self.configurator = configurator
        
        tableView?.separatorColor = self.configurator.separatorColor
        viewWithSeparators?.showTopSeparator(show: configurator.showTopSeparator)
        viewWithSeparators?.showBottomSeparator(show: configurator.showBottomSeparator)
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
        tableView.configureAutomaticDimensions(estimatedRowHeight: configurator.estimatedRowHeight)
        
        tableView.dataSource = self
        tableView.delegate = self

        // Cells
        tableView.register(Cell.self)
        
        // Change content size with KVO
        tableView.addObserver(self, forKeyPath: Constants.contentSizeKey,
                              options: NSKeyValueObservingOptions.new, context: nil)
        
        // Hide bottom separator
        tableViewBottomConstraint?.constant = .pixelHeight
        
        tableView.separatorInset.left = configurator.leftSeparatorInset
        tableView.separatorInset.right = configurator.rightSeparatorInset
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
        cell.separatorInset = UIEdgeInsets(top: 0, left: configurator.leftSeparatorInset, bottom: 0, right: configurator.rightSeparatorInset)
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return configurator.rowHeight
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
