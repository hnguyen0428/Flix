//
//  MoviesViewController.swift
//  Flix
//
//  Created by Hoang on 1/30/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import UIKit
import AlamofireImage

class MoviesViewController: UIViewController, UITableViewDataSource,
                            UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var movies: [Movie] = []
    var filteredMovies: [Movie] = []
    
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
        activityIndicator.startAnimating()
        self.shadeView(shaded: true)
        
        APIManager().nowPlayingMovies { (movies, error) in
            if let error = error {
                print(error.localizedDescription)
                self.displayRequestErrorAlert()
            }
            else if let movies = movies {
                self.movies = movies
                self.filteredMovies = movies
                self.tableView.reloadData()
                
                self.shadeView(shaded: false)
                self.activityIndicator.stopAnimating()
            }
            completion?()
        }
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
        
        movieCell.movie = movie
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = searchText.isEmpty ? movies : movies.filter
            { (movie: Movie) -> Bool in
                let title = movie.title
                return title.range(of: searchText, options: .caseInsensitive,
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

