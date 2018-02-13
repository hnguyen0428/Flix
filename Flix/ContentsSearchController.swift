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
    
    var nowPlayingMovies: [[String:Any]] = []
    var displayedMovies: [[String:Any]] = []
    
    var query: String = ""
    var timer: Timer? = nil
    
    var includeAdult: String = "false"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettings()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self
        
        calculateCellSize()
        fetchNowPlayingMovies()
    }
    
    func loadSettings() {
        let includeAdult = UserDefaults.standard.object(forKey: "include_adult") as? String
        if let str = includeAdult {
            self.includeAdult = str
        }
    }
    
    func fetchNowPlayingMovies(completion: (() -> Void)? = nil) {
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        self.shadeView(shaded: true)
        self.activityIndicator.startAnimating()
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let error = error {
                print(error.localizedDescription)
                completion?()
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                self.nowPlayingMovies = dataDictionary["results"] as! [[String:Any]]
                self.displayedMovies = self.nowPlayingMovies
                self.shadeView(shaded: false)
                self.activityIndicator.stopAnimating()
                completion?()
                self.collectionView.reloadData()
            }
        }
        task.resume()
    }
    
    func calculateCellSize() {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellsPerLine: CGFloat = 2
        let interItemSpacingTotal = layout.minimumInteritemSpacing * (cellsPerLine - 1)
        let width = collectionView.frame.size.width / cellsPerLine -
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
    
    
    func searchContents(query: String, completion: @escaping ([[String:Any]]) -> Void) {
        let url = URL(string: "https://api.themoviedb.org/3/search/movie?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US&query=\(query)&page=1&include_adult=\(self.includeAdult)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        self.shadeView(shaded: true)
        self.activityIndicator.startAnimating()
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let error = error {
                print(error.localizedDescription)
                self.shadeView(shaded: false)
                self.activityIndicator.stopAnimating()
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let movies = dataDictionary["results"] as! [[String:Any]]
                self.shadeView(shaded: false)
                self.activityIndicator.stopAnimating()
                completion(movies)
            }
        }
        task.resume()
    }
    
    
    @objc func updateContents(_ timer: Timer) {
        if self.query.isEmpty {
            self.displayedMovies = self.nowPlayingMovies
            self.collectionView.reloadData()
            return
        }
        
        searchContents(query: self.query) { movies in
            self.displayedMovies = movies
            self.collectionView.reloadData()
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        
        let trimmed = searchText.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
        query = trimmed
        timer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(updateContents), userInfo: nil, repeats: false)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath)
        let posterCell = cell as! PosterCell
        
        let movie = displayedMovies[indexPath.row]
        if let path = movie["poster_path"] as? String {
            posterCell.setPosterImage(path: path)
        }
        
        return posterCell
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
    }
    
}
