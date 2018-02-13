//
//  PosterCell.swift
//  Flix
//
//  Created by Hoang on 2/12/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage

class PosterCell: UICollectionViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setPosterImage(path: String) {
        let urlS = imageTmdb + path
        let url = URL(string: urlS)
        if let url = url {
            posterImageView.af_setImage(withURL: url)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
