//
//  MovieCell.swift
//  Flix
//
//  Created by Hoang on 3/1/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Foundation
import UIKit

class MovieCell: UITableViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var movie: Movie! {
        didSet {
            self.setTitle(title: movie.title)
            self.setOverview(overview: movie.overview)
            if let url = self.movie.posterUrl {
                self.setPosterImage(url: url)
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func setTitle(title: String) {
        titleLabel.text = title
    }
    
    func setOverview(overview: String) {
        overviewLabel.text = overview
    }
    
    func setPosterImage(url: URL) {
        posterImageView.af_setImage(withURL: url)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
