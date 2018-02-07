//
//  DetailViewController.swift
//  Flix
//
//  Created by Hoang on 2/6/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var movie: [String:Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        posterImageView.layer.borderWidth = 2.0
        posterImageView.layer.borderColor = UIColor.white.cgColor
        displayData()
    }
    
    func displayData() {
        if let movie = movie {
            if let title = movie["title"] as? String,
                let overview = movie["overview"] as? String,
                let posterPath = movie["poster_path"] as? String,
                let backdropPath = movie["backdrop_path"] as? String,
                let releaseDate = movie["release_date"] as? String {
                
                setImageView(imageView: backdropImageView, path: backdropPath)
                setImageView(imageView: posterImageView, path: posterPath)
                titleLabel.text = title
                overviewLabel.text = overview
                
                // Resize the label to text length
                overviewLabel.sizeToFit()
                releaseDateLabel.text = releaseDate
            }
        }
    }
    
    func setImageView(imageView: UIImageView, path: String) {
        let urlS = imageTmdb + path
        let url = URL(string: urlS)
        imageView.af_setImage(withURL: url!)
    }
    
    
}
