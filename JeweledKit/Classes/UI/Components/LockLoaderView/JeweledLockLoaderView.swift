//
//  JeweledLockLoaderView.swift
//  JeweledKit
//
//  Created by Борис Анели on 15.09.2020.
//

import UIKit

public final class JeweledLockLoaderView: UIView, JeweledConfigurableView, JeweledReusableView {
    
    public struct ConfigurationModel {
        public let message: String?
        public let isMessage: Bool
        
        public init(message: String? = nil,
                    isMessage: Bool = false) {
            self.message = message
            self.isMessage = isMessage
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var label: UILabel!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        isHidden = true
        if #available(iOS 13.0, *) {
            activityIndicator.style = .large
        }
    }
    
    public func configure(with model: ConfigurationModel) {
        show(message: model.message, isMessage: model.isMessage)
    }
    
    public func show(message: String? = nil) {
        show(message: message, isMessage: false)
    }
    
    public func showMessage(_ message: String) {
        show(message: message, isMessage: true)
    }
    
    public func hide() {
        assert(Thread.isMainThread, "Expect this method to be performed on main thread")
        
        isHidden = true
        activityIndicator.stopAnimating()
        label.isHidden = true
    }
    
    private func show(message: String?, isMessage: Bool) {
        assert(Thread.isMainThread, "Expect this method to be performed on main thread")
        
        isHidden = false
        if isMessage {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
        label.isHidden = message == nil
        label.text = message
    }
}

public typealias JeweledLockLoaderTableViewCell = JeweledTableViewContainerCell<JeweledLockLoaderView>
