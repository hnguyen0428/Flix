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
    var tvShow: [String:Any]?
    var contentType: Int = 0
    
    var posterImage: UIImage?
    var backdropImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        posterImageView.isUserInteractionEnabled = true
        
        posterImageView.layer.borderWidth = 2.0
        posterImageView.layer.borderColor = UIColor.white.cgColor
        
        
        displayData()
    }
    
    func displayData() {
        if let movie = movie {
            if let title = movie["title"] as? String {
                titleLabel.text = title
            }
            
            if let overview = movie["overview"] as? String {
                overviewLabel.text = overview
                overviewLabel.sizeToFit()
            }
            
            if var releaseDate = movie["release_date"] as? String {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let date = formatter.date(from: releaseDate)
                formatter.dateFormat = "MMM d, yyyy"
                releaseDate = formatter.string(from: date!)
                releaseDateLabel.text = releaseDate
            }
            
            let group = DispatchGroup()
            if let posterPath = movie["poster_path"] as? String {
                group.enter()
                setImageView(imageView: posterImageView, path: posterPath) {
                    self.posterImage = self.posterImageView.image
                    group.leave()
                }
            }
            if let backdropPath = movie["backdrop_path"] as? String {
                group.enter()
                setImageView(imageView: backdropImageView, path: backdropPath) {
                    self.backdropImage = self.backdropImageView.image
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                self.repositionComponents()
            }
        }
        
        else if let show = tvShow {
            if let name = show["name"] as? String {
                titleLabel.text = name
            }
            
            if let overview = show["overview"] as? String {
                overviewLabel.text = overview
                overviewLabel.sizeToFit()
            }
            
            if var firstAirDate = show["first_air_date"] as? String {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let date = formatter.date(from: firstAirDate)
                formatter.dateFormat = "MMM d, yyyy"
                firstAirDate = formatter.string(from: date!)
                releaseDateLabel.text = firstAirDate
            }
            
            let group = DispatchGroup()
            if let posterPath = show["poster_path"] as? String {
                group.enter()
                setImageView(imageView: posterImageView, path: posterPath) {
                    self.posterImage = self.posterImageView.image
                    group.leave()
                }
            }
            
            if let backdropPath = show["backdrop_path"] as? String {
                group.enter()
                setImageView(imageView: backdropImageView, path: backdropPath) {
                    self.backdropImage = self.backdropImageView.image
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                self.repositionComponents()
            }
        }
    }
    
    // Return height of backdrop and poster
    func resizeImageViews() -> (CGFloat, CGFloat) {
        var heightBackdrop = backdropImageView.frame.height
        var heightPoster = posterImageView.frame.height

        if let img = backdropImage {
            let widthBackdrop = view.frame.width
            let heightToWidthBackdrop = img.size.height / img.size.width
            heightBackdrop = widthBackdrop * heightToWidthBackdrop
        }
        
        if let img = posterImage {
            let widthPoster = view.frame.width * DetailViewController.WIDTH_POSTER_RATIO
            let heightToWidthPoster = img.size.height / img.size.width
            heightPoster = widthPoster * heightToWidthPoster
        }
        
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
                let urlString = "https://api.themoviedb.org/3/movie/\(id)/videos?api_key=\(api_key)"
                self.getYoutubeKey(urlString: urlString) { key in
                    let url = URL(string:"youtube://\(key)")!
                    if !UIApplication.shared.canOpenURL(url) {
                        let videoURL = "https://www.youtube.com/watch?v=\(key)"
                        let trailerVC = TrailerViewController()
                        trailerVC.videoURL = videoURL
                        
                        self.present(trailerVC, animated: true, completion: nil)
                    }
                    else {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
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
