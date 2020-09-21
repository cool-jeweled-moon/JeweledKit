//
//  JeweledLockLoaderDisplayable.swift
//  JeweledKit
//
//  Created by Борис Анели on 15.09.2020.
//

import Foundation

public protocol JeweledLockLoaderDisplayable: class {
    func showLockActivityView()
    func showLockActivityView(in view: UIView)
    func showLockActivityView(text: String)
    func showLockActivityView(in view: UIView, text: String)
    func showLockActivityViewMessage(text: String)
    func showLockActivityViewMessage(in view: UIView, text: String)
    func hideLockActivityView()
}

private enum Constants {
    static let lockActivityViewTag = 104537
}

extension JeweledLockLoaderDisplayable where Self: UIViewController {

    public func showLockActivityView() {
        showLockActivityView(in: view)
    }
    
    public func showLockActivityView(in view: UIView) {
        showLockActivityView(in: view, text: nil)
    }
    
    public func showLockActivityView(text: String) {
        showLockActivityView(in: view, text: text, isMessage: false)
    }
    
    public func showLockActivityView(in view: UIView, text: String) {
        showLockActivityView(in: view, text: text, isMessage: false)
    }
    
    public func showLockActivityViewMessage(text: String) {
        showLockActivityView(in: view, text: text, isMessage: true)
    }
    
    public func showLockActivityViewMessage(in view: UIView, text: String) {
        showLockActivityView(in: view, text: text, isMessage: true)
    }
    
    public func hideLockActivityView() {
        guard let loader = view.subviews.first(where: { $0.tag == Constants.lockActivityViewTag }) else { return }
        
        if Thread.isMainThread {
            loader.removeFromSuperview()
        } else {
            DispatchQueue.main.async {
                loader.removeFromSuperview()
            }
        }
    }
    
    private func showLockActivityView(in view: UIView, text: String? = nil, isMessage: Bool = false) {
        let lockActivityView = JeweledLockActivityView.fromNib()
        lockActivityView.tag = Constants.lockActivityViewTag
        
        if Thread.isMainThread {
            lockActivityView.show(in: view, text: text, isMessage: isMessage)
        } else {
            DispatchQueue.main.async {
                lockActivityView.show(in: view, text: text, isMessage: isMessage)
            }
        }
    }
}
