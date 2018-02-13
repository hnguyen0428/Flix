//
//  Extensions.swift
//  Flix
//
//  Created by Hoang on 2/12/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    convenience public init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(r: r, g: g, b: b, a: 1)
    }
    
    convenience public init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: a)
    }
    
}


extension UIViewController {
    func hideViewWithAnimation(view: UIView, duration: Double, hidden: Bool = true) {
        UIView.transition(with: view, duration: duration, options: .transitionCrossDissolve,
                          animations:
            {
                view.isHidden = hidden
        }, completion: nil)
    }
}
