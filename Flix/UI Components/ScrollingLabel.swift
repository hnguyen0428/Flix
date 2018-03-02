//
//  ScrollingLabel.swift
//  Flix
//
//  Created by Hoang on 2/14/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Foundation
import UIKit

class ScrollingLabel: UIScrollView {
    
    @IBOutlet weak var label: UILabel!
    var dupLabel: UILabel?
    
    var duration: Double = 10.0
    var durationBeforeReset: Double = 2.0
    let OFFSET: CGFloat = 35.0
    
    var text: String? {
        didSet {
            if let text = text {
                setLabel(text: text)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    private func setLabel(text: String) {
        label.text = text
        label.sizeToFit()
        if label.frame.width > frame.width {
            let dupLabelFrame = CGRect(x: label.frame.maxX + OFFSET, y: label.frame.origin.y,
                                       width: label.frame.width, height: label.frame.height)
            dupLabel = UILabel(frame: dupLabelFrame)
            dupLabel!.textColor = label.textColor
            dupLabel!.font = label.font
            dupLabel!.text = text
            addSubview(dupLabel!)
            contentSize.width = label.frame.size.width * 2 + OFFSET
        }
        
        
        if contentSize.width > frame.width {
            scrollText()
        }
    }
    
    @objc private func scrollText(_ timer: Timer? = nil) {
        if let timer = timer {
            timer.invalidate()
        }
        
        let endX = dupLabel!.frame.origin.x
        let endY = contentOffset.y
        UIView.animate(withDuration: duration, delay: 0.0, options: [UIViewAnimationOptions.curveLinear],
                       animations:
            {
                self.contentOffset = CGPoint(x: endX, y: endY)
        }, completion:
            { _ in
                self.resetScroller()
        })
    }
    
    private func resetScroller() {
        contentOffset = CGPoint(x: 0, y: contentOffset.y)
        Timer.scheduledTimer(timeInterval: durationBeforeReset, target: self,
                             selector: #selector(scrollText),
                             userInfo: nil, repeats: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
