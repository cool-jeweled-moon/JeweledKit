//
//  JeweledViewWithSeparators.swift
//  JeweledKit
//
//  Created by Борис Анели on 15.09.2020.
//

import UIKit

public final class JeweledViewWithSeparators: UIView, JeweledNibAwakable {
    
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet private weak var topSeparator: UIView!
    @IBOutlet private weak var bottomSeparator: UIView!
    @IBOutlet private weak var topSeparatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomSeparatorHeightConstraint: NSLayoutConstraint!
    
    public override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        super.awakeAfter(using: aDecoder)
        
        return awakeAfterCoder()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        topSeparatorHeightConstraint.constant = .pixelHeight
        bottomSeparatorHeightConstraint.constant = .pixelHeight
    }
    
    public func showTopSeparator(show: Bool) {
        topSeparator.isHidden = !show
    }

    public func showBottomSeparator(show: Bool) {
        bottomSeparator.isHidden = !show
    }
}
