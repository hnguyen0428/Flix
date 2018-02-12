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
    
    static let WIDTH_POSTER_RATIO: CGFloat = 0.30
    static let LEFT_INSET: CGFloat = 0.04
    static let OFFSET: CGFloat = 10.0
    
    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    var movie: [String:Any]?
    
    var posterImage: UIImage?
    var backdropImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        posterImageView.isUserInteractionEnabled = true
        
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
                
                let group = DispatchGroup()
                group.enter()
                setImageView(imageView: backdropImageView, path: backdropPath) {
                    self.backdropImage = self.backdropImageView.image
                    group.leave()
                }
                group.enter()
                setImageView(imageView: posterImageView, path: posterPath) {
                    self.posterImage = self.posterImageView.image
                    group.leave()
                }
                group.notify(queue: .main) {
                    self.repositionComponents()
                }
                titleLabel.text = title
                overviewLabel.text = overview
                
                // Resize the label to text length
                overviewLabel.sizeToFit()
                releaseDateLabel.text = releaseDate
            }
        }
    }
    
    // Return height of backdrop and poster
    func resizeImageViews() -> (CGFloat, CGFloat) {
        let widthBackdrop = view.frame.width
        let heightToWidthBackdrop = backdropImage!.size.height / backdropImage!.size.width
        let heightBackdrop = widthBackdrop * heightToWidthBackdrop
        
        let widthPoster = view.frame.width * DetailViewController.WIDTH_POSTER_RATIO
        let heightToWidthPoster = posterImage!.size.height / posterImage!.size.width
        let heightPoster = widthPoster * heightToWidthPoster
        
        return (heightBackdrop, heightPoster)
    }
    
    func repositionComponents() {
        let heights = resizeImageViews()
        let heightBackdrop = heights.0
        let backdropInset = self.navigationController!.navigationBar.frame.maxY
        let backdropFrame = CGRect(x: 0, y: backdropInset, width: view.frame.width, height: heightBackdrop)
        self.backdropImageView.frame = backdropFrame
        
        let heightPoster = heights.1
        let widthPoster = view.frame.width * DetailViewController.WIDTH_POSTER_RATIO
        let leftInset = view.frame.width * DetailViewController.LEFT_INSET
        let posterFrame = CGRect(x: leftInset, y: 0, width: widthPoster, height: heightPoster)
        self.posterImageView.frame = posterFrame
        self.posterImageView.center.y = backdropImageView.frame.maxY
        
        let offset = DetailViewController.OFFSET
        
        let originalTitleWidth = titleLabel.frame.width
        let originalTitleHeight = titleLabel.frame.height
        let titleFrame = CGRect(x: posterFrame.maxX + offset, y: backdropFrame.maxY + offset,
                                width: originalTitleWidth, height: originalTitleHeight)
        let originalReleaseWidth = releaseDateLabel.frame.width
        let originalReleaseHeight = releaseDateLabel.frame.height
        let releaseFrame = CGRect(x: posterFrame.maxX + offset, y: titleFrame.maxY + offset,
                                  width: originalReleaseWidth, height: originalReleaseHeight)
        
        let tabBarY = self.tabBarController!.tabBar.frame.origin.y
        let overviewY = posterImageView.frame.maxY + offset
        let overviewX = posterImageView.frame.origin.x
        let overviewHeight = tabBarY - 10 - overviewY
        let overviewWidth = overviewLabel.frame.width
        let overviewFrame = CGRect(x: overviewX, y: overviewY,
                                   width: overviewWidth, height: overviewHeight)
        
        titleLabel.frame = titleFrame
        releaseDateLabel.frame = releaseFrame
        overviewLabel.frame = overviewFrame
        overviewLabel.sizeToFit()
    }
    
    func getYoutubeKey(urlString: String, completion: @escaping (String) -> Void) {
        let url = URL(string: urlString)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let result = dataDictionary["results"] as! [[String:Any]]
                
                if let res = result.first {
                    let key = res["key"] as! String
                    completion(key)
                }
                
            }
        }
        task.resume()
    }
    
    @IBAction func tappedPoster(_ sender: Any) {
        if let movie = movie {
            if let id = movie["id"] as? Int {
                let urlString = "https://api.themoviedb.org/3/movie/\(id)/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"
                self.getYoutubeKey(urlString: urlString) { key in
                    let videoURL = "https://www.youtube.com/watch?v=\(key)"
                    let trailerVC = TrailerViewController()
                    trailerVC.videoURL = videoURL
                    
                    self.present(trailerVC, animated: true, completion: nil)
                }
                
            }
        }
        
    }
    
    func setImageView(imageView: UIImageView, path: String, completion: (() -> Void)? = nil) {
        let urlS = imageTmdb + path
        let url = URL(string: urlS)!
        imageView.af_setImage(withURL: url, completion:
            { data in
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                completion?()
        })
    }
    
}
