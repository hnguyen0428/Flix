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
    
    var content: APIObject! {
        didSet {
            if let movie = content as? Movie {
                if let url = movie.posterUrl {
                    self.setPosterImage(url: url)
                }
            }
            else if let tvShow = content as? TVShow {
                if let url = tvShow.posterUrl {
                    self.setPosterImage(url: url)
                }
            }
            else if let actor = content as? Actor {
                if let url = actor.profileUrl {
                    self.setPosterImage(url: url)
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setPosterImage(path: String) {
        let urlS = APIManager.imageTmdb + path
        let url = URL(string: urlS)
        if let url = url {
            posterImageView.af_setImage(withURL: url)
        }
    }
    
    func setPosterImage(url: URL) {
        posterImageView.af_setImage(withURL: url)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
