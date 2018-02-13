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
    
    var storedContents: [[String:Any]] = []
    var displayedContents: [[String:Any]] = []
    
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
        var url: URL!
        if contentType == MOVIES {
            url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=\(api_key)")!
        }
        else if contentType == TV_SHOWS {
            url = URL(string: "https://api.themoviedb.org/3/tv/popular?api_key=\(api_key)&language=en-US&page=1")!
        }
        else if contentType == ACTORS {
            url = URL(string: "https://api.themoviedb.org/3/person/popular?api_key=\(api_key)&language=en-US&page=1")
        }
        
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
                self.storedContents = dataDictionary["results"] as! [[String:Any]]
                self.displayedContents = self.storedContents
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
    
    
    func searchContents(query: String, completion: @escaping ([[String:Any]]) -> Void) {
        var url: URL!
        
        if contentType == MOVIES {
            url = URL(string: "https://api.themoviedb.org/3/search/movie?api_key=\(api_key)&language=en-US&query=\(query)&page=1&include_adult=\(self.includeAdult)")!
        }
        else if contentType == TV_SHOWS {
            url = URL(string: "https://api.themoviedb.org/3/search/tv?api_key=\(api_key)&language=en-US&query=\(query)&page=1")
        }
        else if contentType == ACTORS {
            url = URL(string: "https://api.themoviedb.org/3/search/person?api_key=\(api_key)&language=en-US&query=\(query)&page=1&include_adult=\(includeAdult)")
        }
        
        
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
                let results = dataDictionary["results"] as! [[String:Any]]
                self.shadeView(shaded: false)
                self.activityIndicator.stopAnimating()
                completion(results)
            }
        }
        task.resume()
    }
    
    
    @objc func updateContents(_ timer: Timer) {
        if self.query.isEmpty {
            self.displayedContents = self.storedContents
            self.collectionView.reloadData()
            return
        }
        
        searchContents(query: self.query) { results in
            self.displayedContents = results.filter { (content:[String:Any]) -> Bool in
                let key = self.contentType == self.ACTORS ? "profile_path" : "poster_path"
                if let _ = content[key] as? String {
                    return true
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
        
        let trimmed = searchText.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
        
        query = trimmed.replacingOccurrences(of: " ", with: "+")
        timer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(updateContents), userInfo: nil, repeats: false)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedContents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath)
        let posterCell = cell as! PosterCell
        
        let movie = displayedContents[indexPath.row]
        let key = contentType == ACTORS ? "profile_path" : "poster_path"
        
        if let path = movie[key] as? String {
            posterCell.setPosterImage(path: path)
        }
        else {
            print("Doesn't have image")
        }
        
        return posterCell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if contentType != ACTORS {
            let content = displayedContents[indexPath.row]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            if contentType == MOVIES {
                vc.movie = content
            }
            else if contentType == TV_SHOWS {
                vc.tvShow = content
            }
            vc.contentType = contentType
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let content = displayedContents[indexPath.row]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ActorDetailViewController") as! ActorDetailViewController
            
            if let knownFor = content["known_for"] as? [[String:Any]] {
                let kf = knownFor.filter { (content: [String:Any]) in
                    if let _ = content["poster_path"] as? String {
                        return true
                    }
                    return false
                }
                vc.knownFor = kf
            }
            if let id = content["id"] as? Int {
                vc.id = id
            }
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


