//
//  TableViewContainerCell.swift
//  JeweledKit
//
//  Created by Борис Анели on 15.09.2020.
//

import UIKit

public final class JeweledTableViewContainerCell<T: UIView>: UITableViewCell,
JeweledConfigurableView where T: JeweledConfigurableView, T: JeweledReusableView {
    
    public var containedView: T = T.isLoadableFromNib() ? T.fromNib() : T(frame: .zero)
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(containedView)
        containedView.translatesAutoresizingMaskIntoConstraints = false
        containedView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        containedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        containedView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        containedView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        containedView.prepareForReuse()
    }

    public func configure(with model: T.ConfigurationModel) {
        containedView.configure(with: model)
    }
}

