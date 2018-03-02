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
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    static let WIDTH_POSTER_RATIO: CGFloat = 0.30
    static let LEFT_INSET: CGFloat = 0.04
    static let OFFSET: CGFloat = 10.0
    
    @IBOutlet weak var backdropHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var overviewTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var scrollingLabel: ScrollingLabel!
    
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    var movie: Movie?
    var tvShow: TVShow?
    var similarMovies: [Movie] = []
    var similarTvShows: [TVShow] = []
    var contentType: Int = 0
    
    var posterImage: UIImage?
    var backdropImage: UIImage?
    
    let OVERVIEW = 0
    let SIMILAR = 1
    let OFFSET: CGFloat = 10.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        AppUtility.lockOrientation(.portrait)
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
            scrollingLabel.text = movie.title
            overviewTextView.text = movie.overview
            
            
            if var releaseDate = movie.releaseDate {
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
            if let posterUrl = movie.posterUrl {
                group.enter()
                setImageView(imageView: posterImageView, url: posterUrl) {
                    self.posterImage = self.posterImageView.image
                    group.leave()
                }
            }
            if let backdropUrl = movie.backdropUrl {
                group.enter()
                setImageView(imageView: backdropImageView, url: backdropUrl) {
                    self.backdropImage = self.backdropImageView.image
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                self.repositionComponents()
            }
        }
        
        else if let show = tvShow {
            scrollingLabel.text = show.name
            overviewTextView.text = show.overview
            
            if var firstAirDate = show.firstAirDate {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let date = formatter.date(from: firstAirDate)
                formatter.dateFormat = "MMM d, yyyy"
                if let date = date {
                    formatter.dateFormat = "MMM d, yyyy"
                    firstAirDate = formatter.string(from: date)
                    releaseDateLabel.text = firstAirDate
                }
            }
            
            let group = DispatchGroup()
            if let posterPath = show.posterUrl {
                group.enter()
                setImageView(imageView: posterImageView, url: posterPath) {
                    self.posterImage = self.posterImageView.image
                    group.leave()
                }
            }
            
            if let backdropPath = show.backdropUrl {
                group.enter()
                setImageView(imageView: backdropImageView, url: backdropPath) {
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
        if let movie = movie {
            let id = movie.id
            APIManager().similarMovies(id: id, completion: { (movies, error) in
                if let movies = movies {
                    self.similarMovies = movies
                    self.collectionView.reloadData()
                }
            })
        }
        else if let tvShow = tvShow {
            let id = tvShow.id
            APIManager().similarTVShows(id: id, completion: { (tvShows, error) in
                if let tvShows = tvShows {
                    self.similarTvShows = tvShows
                    self.collectionView.reloadData()
                }
            })
        }
    }
    
    
    func calculateCellSize() {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellsPerLine: CGFloat = 2
        layout.minimumInteritemSpacing = 10.0
        layout.minimumLineSpacing = 10.0
        let interItemSpacingTotal = layout.minimumInteritemSpacing * (cellsPerLine - 1)
        
        let width = (collectionView.frame.size.width - interItemSpacingTotal) / 2
        layout.itemSize = CGSize(width: width, height: width * 3 / 2)
    }
    
    // Return height of backdrop and poster
    func resizeImageViews() -> CGFloat {
        var heightBackdrop = backdropImageView.frame.height

        if let img = backdropImage {
            let widthBackdrop = view.frame.width
            let heightToWidthBackdrop = img.size.height / img.size.width
            heightBackdrop = widthBackdrop * heightToWidthBackdrop
        }
        
        return heightBackdrop
    }
    
    func repositionComponents() {
        let heightBackdrop = resizeImageViews()
        backdropHeightConstraint.constant = heightBackdrop
    }
    
    
    @IBAction func tappedPoster(_ sender: Any) {
        if let movie = movie {
            let id = movie.id
            APIManager().getYouTubeKey(id: id, completion: { (key, error) in
                if let key = key {
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
            })
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let _ = movie {
            return similarMovies.count
        }
        else if let _ = tvShow {
            return similarTvShows.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath)
        let posterCell = cell as! PosterCell
        
        if let _ = movie {
            posterCell.content = similarMovies[indexPath.row]
        }
        else if let _ = tvShow {
            posterCell.content = similarTvShows[indexPath.row]
        }
        
        return posterCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        if contentType == 0 {
            vc.movie = similarMovies[indexPath.row]
        }
        else if contentType == 1 {
            vc.tvShow = similarTvShows[indexPath.row]
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
    
    
    func setImageView(imageView: UIImageView, url: URL, completion: (() -> Void)? = nil) {
        imageView.af_setImage(withURL: url, completion:
            { data in
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                completion?()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AppUtility.lockOrientation(.all)
    }
    
}
