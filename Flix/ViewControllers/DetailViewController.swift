//
//  DetailViewController.swift
//  Flix
//
//  Created by Hoang on 2/6/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Foundation
import UIKit

class DetailViewController: UIViewController, UICollectionViewDelegate,
                            UICollectionViewDataSource {
    
    static let WIDTH_POSTER_RATIO: CGFloat = 0.30
    static let LEFT_INSET: CGFloat = 0.04
    static let OFFSET: CGFloat = 10.0
    
    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var overviewTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    var movie: [String:Any]?
    var tvShow: [String:Any]?
    var similarContents: [[String:Any]] = []
    var contentType: Int = 0
    
    var posterImage: UIImage?
    var backdropImage: UIImage?
    
    let OVERVIEW = 0
    let SIMILAR = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isHidden = true
        collectionView.backgroundColor = .clear
        calculateCellSize()
        
        posterImageView.isUserInteractionEnabled = true
        
        posterImageView.layer.borderWidth = 2.0
        posterImageView.layer.borderColor = UIColor.white.cgColor
        
        fetchSimilarContents()
        displayData()
    }
    
    func displayData() {
        if let movie = movie {
            if let title = movie["title"] as? String {
                titleLabel.text = title
            }
            
            if let overview = movie["overview"] as? String {
                overviewTextView.text = overview
            }
            
            if var releaseDate = movie["release_date"] as? String {
                print(releaseDate)
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let date = formatter.date(from: releaseDate)
                if let date = date {
                    formatter.dateFormat = "MMM d, yyyy"
                    releaseDate = formatter.string(from: date)
                    releaseDateLabel.text = releaseDate
                }
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
                overviewTextView.text = overview
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
    
    
    func fetchSimilarContents() {
        var url: URL!
        if let movie = movie {
            let id = movie["id"] as! Int
            url = URL(string: "https://api.themoviedb.org/3/movie/\(id)/similar?api_key=\(api_key)&language=en-US")!
        }
        else if let tvShow = tvShow {
            let id = tvShow["id"] as! Int
            url = URL(string: "https://api.themoviedb.org/3/tv/\(id)/similar?api_key=\(api_key)&language=en-US")!
        }
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                if let contents = dataDictionary["results"] as? [[String:Any]] {
                    self.similarContents = contents
                    self.collectionView.reloadData()
                }
            }
        }
        task.resume()
    }
    
    
    func calculateCellSize() {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellsPerLine: CGFloat = 2
        layout.minimumInteritemSpacing = 10.0
        layout.minimumLineSpacing = 10.0
        let interItemSpacingTotal = layout.minimumInteritemSpacing * (cellsPerLine - 1)
        let width = collectionView.frame.size.width / cellsPerLine -
            interItemSpacingTotal / cellsPerLine
        layout.itemSize = CGSize(width: width, height: width * 3 / 2)
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
        
        let scWidth = segmentedControl.frame.width
        let scHeight = segmentedControl.frame.height
        let scX = (view.frame.width - scWidth) / 2
        let scY = posterImageView.frame.maxY + offset
        let scFrame = CGRect(x: scX, y: scY, width: scWidth, height: scHeight)
        
        let tabBarY = self.tabBarController!.tabBar.frame.origin.y
        let overviewY = scFrame.maxY + offset
        let overviewX = segmentedControl.frame.origin.x
        let overviewHeight = tabBarY - offset - overviewY
        let overviewWidth = overviewTextView.frame.width
        let overviewFrame = CGRect(x: overviewX, y: overviewY,
                                   width: overviewWidth, height: overviewHeight)
        
        titleLabel.frame = titleFrame
        releaseDateLabel.frame = releaseFrame
        segmentedControl.frame = scFrame
        overviewTextView.frame = overviewFrame
        collectionView.frame = overviewFrame
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return similarContents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath)
        let posterCell = cell as! PosterCell
        
        let content = similarContents[indexPath.row]
        if let path = content["poster_path"] as? String {
            posterCell.setPosterImage(path: path)
        }
        
        return posterCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let content = similarContents[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        if contentType == 0 {
            vc.movie = content
        }
        else if contentType == 1 {
            vc.tvShow = content
        }
        vc.contentType = contentType
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func toggledSegmentedControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == OVERVIEW {
            self.hideViewWithAnimation(view: collectionView, duration: 0.2, hidden: true)
            self.hideViewWithAnimation(view: overviewTextView, duration: 0.2, hidden: false)
        }
        else {
            self.hideViewWithAnimation(view: collectionView, duration: 0.2, hidden: false)
            self.hideViewWithAnimation(view: overviewTextView, duration: 0.2, hidden: true)
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