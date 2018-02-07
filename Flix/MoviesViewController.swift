//
//  MoviesViewController.swift
//  Flix
//
//  Created by Hoang on 1/30/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import UIKit
import AlamofireImage

let imageTmdb = "https://image.tmdb.org/t/p/w500"

class MoviesViewController: UIViewController, UITableViewDataSource,
                            UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var movies: [[String:Any]] = []
    var filteredMovies: [[String:Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMovies()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    @objc func didPullToRefresh(_ sender: UIRefreshControl) {
        fetchMovies {
            sender.endRefreshing()
        }
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
    
    func fetchMovies(completion: (() -> Void)? = nil) {
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        activityIndicator.startAnimating()
        self.shadeView(shaded: true)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let error = error {
                print(error.localizedDescription)
                self.displayRequestErrorAlert()
                completion?()
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                self.movies = dataDictionary["results"] as! [[String:Any]]
                self.shadeView(shaded: false)
                self.activityIndicator.stopAnimating()
                self.filteredMovies = self.movies
                completion?()
                self.tableView.reloadData()
            }
        }
        task.resume()
    }
    
    func displayRequestErrorAlert() {
        let title = "Cannot Get Movies"
        let message = "The internet connection appears to be offline"
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default,
                                      handler:
            { _ in
                self.fetchMovies()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 175
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
        let movieCell = cell as! MovieCell
        
        let movie = filteredMovies[indexPath.row]
        if let title = movie["title"] as? String,
            let overview = movie["overview"] as? String,
            let path = movie["poster_path"] as? String {
            movieCell.setTitle(title: title)
            movieCell.setOverview(overview: overview)
            movieCell.setPosterImage(path: path)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = searchText.isEmpty ? movies : movies.filter
            { (movie: [String:Any]) -> Bool in
                let title = movie["title"] as? String
                return title?.range(of: searchText, options: .caseInsensitive,
                                    range: nil, locale: nil) != nil
        }
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        if let indexPath = tableView.indexPath(for: cell) {
            let movie = movies[indexPath.row]
            let detailVC = segue.destination as! DetailViewController
            detailVC.movie = movie
        }        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

class MovieCell: UITableViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func setTitle(title: String) {
        titleLabel.text = title
    }
    
    func setOverview(overview: String) {
        overviewLabel.text = overview
    }
    
    func setPosterImage(path: String) {
        let urlS = imageTmdb + path
        let url = URL(string: urlS)
        posterImageView.af_setImage(withURL: url!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

