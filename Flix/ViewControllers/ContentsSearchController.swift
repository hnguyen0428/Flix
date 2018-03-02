//
//  ContentsSearchController.swift
//  Flix
//
//  Created by Hoang on 2/12/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Foundation
import UIKit

class ContentsSearchController: UIViewController, UICollectionViewDataSource,
                            UICollectionViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var storedContents: [APIObject] = []
    var displayedContents: [APIObject] = []
    
    var query: String = ""
    var timer: Timer? = nil
    
    var includeAdult: String = "false"
    
    var showOptions: Bool = false
    var optionsView: OptionsView!
    var optionsViewClosedY: CGFloat = 0.0
    var contentType: Int = 0
    let MOVIES = 0
    let TV_SHOWS = 1
    let ACTORS = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettings()
        setupOptionsView()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self
        
        calculateCellSize()
        fetchContents()
    }
    
    func setupOptionsView() {
        let width = view.frame.width
        let height = searchBar.frame.height
        let frame = CGRect(x: 0, y: 0 - height, width: width, height: height)
        optionsView = OptionsView(frame: frame)
        view.addSubview(optionsView)
        
        optionsViewClosedY = 0 - height
        
        optionsView.segmentedControl.addTarget(self, action: #selector(changeContentType), for: .valueChanged)
        optionsView.segmentedControl.selectedSegmentIndex = contentType
    }
    
    func loadSettings() {
        let includeAdult = UserDefaults.standard.object(forKey: "include_adult") as? String
        if let str = includeAdult {
            self.includeAdult = str
        }
        
        let contentType = UserDefaults.standard.object(forKey: "search_content_type") as? Int
        if let i = contentType {
            self.contentType = i
        }
    }
    
    func fetchContents(completion: (() -> Void)? = nil) {
        self.shadeView(shaded: true)
        self.activityIndicator.startAnimating()
        if contentType == MOVIES {
            APIManager().popularMovies(completion: { (movies, error) in
                self.shadeView(shaded: false)
                self.activityIndicator.stopAnimating()
                if let movies = movies {
                    self.storedContents = movies
                    self.displayedContents = movies
                    self.collectionView.reloadData()
                }
                completion?()
            })
        }
        else if contentType == TV_SHOWS {
            APIManager().popularTVShows(completion: { (tvShows, error) in
                self.shadeView(shaded: false)
                self.activityIndicator.stopAnimating()
                if let tvShows = tvShows {
                    self.storedContents = tvShows
                    self.displayedContents = tvShows
                    self.collectionView.reloadData()
                }
                completion?()
            })
        }
        else if contentType == ACTORS {
            APIManager().popularActors(completion: { (actors, error) in
                self.shadeView(shaded: false)
                self.activityIndicator.stopAnimating()
                if let actors = actors {
                    self.storedContents = actors
                    self.displayedContents = actors
                    self.collectionView.reloadData()
                }
                completion?()
            })
        }
    }
    
    
    func calculateCellSize() {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellsPerLine: CGFloat = 2
        let interItemSpacingTotal = layout.minimumInteritemSpacing * (cellsPerLine - 1)
        let width = view.frame.width / cellsPerLine -
            interItemSpacingTotal / cellsPerLine
        layout.itemSize = CGSize(width: width, height: width * 3 / 2)
    }
    
    func shadeView(shaded: Bool) {
        if shaded {
            let mask = UIView(frame: self.view.frame)
            mask.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.view.mask = mask
            self.view.isUserInteractionEnabled = false
        }
        else {
            self.view.mask = nil
            self.view.isUserInteractionEnabled = true
        }
    }
    
    @objc func changeContentType(_ sc: UISegmentedControl) {
        contentType = sc.selectedSegmentIndex
        fetchContents()
        
        UserDefaults.standard.set(contentType, forKey: "search_content_type")
        UserDefaults.standard.synchronize()
    }
    
    
    func searchContents(query: String, completion: @escaping ([APIObject]) -> Void) {
        self.shadeView(shaded: true)
        self.activityIndicator.startAnimating()
        if contentType == MOVIES {
            APIManager().searchMovies(query: query, includeAdult: includeAdult, completion: { (movies, error) in
                self.shadeView(shaded: false)
                self.activityIndicator.stopAnimating()
                if let movies = movies {
                    completion(movies)
                }
            })
        }
        else if contentType == TV_SHOWS {
            APIManager().searchTvShows(query: query, includeAdult: includeAdult, completion: { (tvShows, error) in
                self.shadeView(shaded: false)
                self.activityIndicator.stopAnimating()
                if let tvShows = tvShows {
                    completion(tvShows)
                }
            })
        }
        else if contentType == ACTORS {
            APIManager().searchActors(query: query, includeAdult: includeAdult, completion: { (actors, error) in
                self.shadeView(shaded: false)
                self.activityIndicator.stopAnimating()
                if let actors = actors {
                    completion(actors)
                }
            })
        }
    }
    
    
    @objc func updateContents(_ timer: Timer) {
        if self.query.isEmpty {
            self.displayedContents = self.storedContents
            self.collectionView.reloadData()
            return
        }
        
        searchContents(query: self.query) { results in
            self.displayedContents = results.filter { (content: APIObject) -> Bool in
                if let movie = content as? Movie {
                    if let _ = movie.posterUrl {
                        return true
                    }
                }
                else if let tvShow = content as? TVShow {
                    if let _ = tvShow.posterUrl {
                        return true
                    }
                }
                else if let actor = content as? Actor {
                    if let _ = actor.profileUrl {
                        return true
                    }
                }
                return false
            }
            self.collectionView.reloadData()
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        
        var characterSet = CharacterSet.alphanumerics.inverted
        characterSet.remove(charactersIn: " ")
        let str = searchText.components(separatedBy: characterSet).joined(separator: "")
        let trimmed = str.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
        query = trimmed.replacingOccurrences(of: " ", with: "+")
        
        timer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(updateContents), userInfo: nil, repeats: false)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedContents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath)
        let posterCell = cell as! PosterCell
        
        let content = displayedContents[indexPath.row]        
        posterCell.content = content
        
        return posterCell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if contentType != ACTORS {
            let content = displayedContents[indexPath.row]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            if contentType == MOVIES {
                vc.movie = content as? Movie
            }
            else if contentType == TV_SHOWS {
                vc.tvShow = content as? TVShow
            }
            vc.contentType = contentType
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let content = displayedContents[indexPath.row] as! Actor
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ActorDetailViewController") as! ActorDetailViewController
            
            if let knownFor = content.knownFor {
                let kf = knownFor.filter { (content: [String:Any]) in
                    if let _ = content["poster_path"] as? String {
                        return true
                    }
                    return false
                }
                vc.knownFor = kf
            }
            vc.id = content.id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    @IBAction func tappedOptions(_ sender: Any) {
        if showOptions {
            // Close options view
            UIView.animate(withDuration: 0.5, animations:
                {
                    self.optionsView.frame.origin.y = self.optionsViewClosedY
            })
        }
        else {
            // Show options view
            UIView.animate(withDuration: 0.5, animations:
                {
                    self.optionsView.frame.origin.y = self.searchBar.frame.origin.y
            })
        }
        showOptions = !showOptions
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let includeAdult = UserDefaults.standard.object(forKey: "include_adult") as? String
        if let str = includeAdult {
            self.includeAdult = str
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
    }
    
}

class OptionsView: UIView {
    
    var segmentedControl: UISegmentedControl!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.layer.cornerRadius = 15.0
        self.layer.isOpaque = false
        let width = 0.90 * self.frame.width
        let height = 0.65 * self.frame.height
        let x = (self.frame.width - width) / 2
        let y = (self.frame.height - height) / 2
        let frame = CGRect(x: x, y: y, width: width, height: height)
        
        let items = ["Movies", "TV Shows", "Actors/Actresses"]
        segmentedControl = UISegmentedControl(items: items)
        segmentedControl.tintColor = .white
        segmentedControl.frame = frame
        
        segmentedControl.selectedSegmentIndex = 0
        self.addSubview(segmentedControl)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}


