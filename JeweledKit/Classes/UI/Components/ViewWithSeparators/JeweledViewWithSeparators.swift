//
//  JeweledViewWithSeparators.swift
//  JeweledKit
//
//  Created by Борис Анели on 15.09.2020.
//

import UIKit

final class JeweledViewWithSeparators: UIView, JeweledNibAwakable {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet private weak var topSeparator: UIView!
    @IBOutlet private weak var bottomSeparator: UIView!
    
    override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        super.awakeAfter(using: aDecoder)
        
        return awakeAfterCoder()
    }
    
    @objc public func showTopSeparator(show: Bool) {
        topSeparator.isHidden = !show
    }

    @objc public func showBottomSeparator(show: Bool) {
        bottomSeparator.isHidden = !show
    }
}
