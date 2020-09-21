//
//  JeweledLockActivityView.swift
//  JeweledKit
//
//  Created by Борис Анели on 15.09.2020.
//

import UIKit

public final class JeweledLockActivityView: UIView {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var label: UILabel!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        if #available(iOS 13.0, *) {
            activityIndicator.style = .large
        }
    }
    
    public func show(in view: UIView, text: String? = nil, isMessage: Bool = false) {
        assert(Thread.isMainThread, "Expect this method to be performed on main thread")
        
        isHidden = false
        if isMessage {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
        label.isHidden = text == nil
        label.text = text
        
        view.addSubview(self)
        view.bringSubviewToFront(self)
        frame = view.bounds
        center = view.center
    }
    
    public func hide() {
        isHidden = true
        activityIndicator.stopAnimating()
        removeFromSuperview()
    }
}
