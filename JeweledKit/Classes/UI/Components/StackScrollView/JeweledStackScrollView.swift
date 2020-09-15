//
//  JeweledStackScrollView.swift
//  JeweledKit
//
//  Created by Борис Анели on 15.09.2020.
//

import UIKit

final public class JeweledStackScrollView: UIScrollView {
    
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet var placeholderView: UIView!
    @IBOutlet private weak var additionalSpaceHeighEqualConstraint: NSLayoutConstraint!
    
    public var shouldAvoidContentInsetTouches = false
    public var shouldFillRemainingSpace: Bool {
        set {
            guard shouldFillRemainingSpace != newValue else { return }
            if newValue {
                stackView.insertArrangedSubview(placeholderView, at: numberOfViews)
            } else {
                placeholderView.removeFromSuperview()
            }
        }
        get {
            return placeholderView.superview != nil
        }
    }
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var checkPoint = point
        if shouldAvoidContentInsetTouches {
            checkPoint.y += min(0, contentOffset.y)
        }
        return super.point(inside: checkPoint, with: event)
    }
    
    public func placeController(_ controller: UIViewController, isHidden: Bool = false) {
        guard let parentViewController = firstAvailableUIViewController() else { assert(false); return }
        
        parentViewController.addChild(controller)
        addView(controller.view)
        controller.didMove(toParent: controller.parent)
        controller.view.isHidden = isHidden
    }
    
    public func addView(_ view: UIView) {
        stackView.insertArrangedSubview(view, at: numberOfViews)
    }
    
    public func removeView(_ view: UIView) {
        view.removeFromSuperview()
    }

    public func removeAllViews() {
        for view in stackView.arrangedSubviews where view != placeholderView {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    
    public func insertView(_ view: UIView, at index: Int) {
        guard index <= numberOfViews else {
            assertionFailure("⚠️ Trying to replace blank view")
            return
        }
        stackView.insertArrangedSubview(view, at: index)
    }
    
    public func replaceView(_ oldView: UIView, with newView: UIView) {
        guard let indexOfOld = stackView.arrangedSubviews.firstIndex(of: oldView) else {
            assertionFailure("⚠️ View to replace is not present in StackView")
            return
        }
        if let indexOfNew = stackView.arrangedSubviews.firstIndex(of: newView) {
            stackView.exchangeSubview(at: indexOfOld, withSubviewAt: indexOfNew)
        } else {
            stackView.insertArrangedSubview(newView, at: indexOfOld)
            oldView.removeFromSuperview()
        }
        
    }
    
    public static func emptyView(withHeight height: CGFloat) -> UIView {
        return emptyView(withHeight: height, heightPriority: UILayoutPriority.defaultHigh)
    }
    
    public static func emptyView(withHeight height: CGFloat, heightPriority: UILayoutPriority) -> UIView {
        let emptyView = UIView()
        emptyView.backgroundColor = .clear
        emptyView.frame.size.height = height
        emptyView.translatesAutoresizingMaskIntoConstraints = false
//        emptyView.heightAnchor(constraint)
        assertionFailure()
        return emptyView
    }

    public var numberOfViews: Int {
        if shouldFillRemainingSpace {
            return stackView.arrangedSubviews.count - 1
        }
        return stackView.arrangedSubviews.count
    }
    
//    override public func awakeAfter(using aDecoder: NSCoder) -> Any? {
//        super.awakeAfter(using: aDecoder)
//        return awakeAfterCoder()
//    }
    
    override public var contentInset: UIEdgeInsets {
        didSet {
            additionalSpaceHeighEqualConstraint.constant = 1 - contentInset.top
            scrollIndicatorInsets.top = contentInset.top
        }
    }
    
}
