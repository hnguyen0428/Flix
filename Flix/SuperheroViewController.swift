//
//  SuperheroViewController.swift
//  Flix
//
//  Created by Hoang on 2/6/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Foundation
import UIKit

class SuperheroViewController: UIViewController, UICollectionViewDelegate,
                                UICollectionViewDataSource {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var movies: [[String:Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calculateCellSize()
        fetchMovies()
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func calculateCellSize() {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellsPerLine: CGFloat = 3
        let interItemSpacingTotal = layout.minimumInteritemSpacing * (cellsPerLine - 1)
        let width = collectionView.frame.size.width / cellsPerLine -
            interItemSpacingTotal / cellsPerLine
        layout.itemSize = CGSize(width: width, height: width * 3 / 2)
    }
    
    
    func fetchMovies() {
        let url = URL(string: "https://api.themoviedb.org/3/movie/284053/similar?api_key=\(api_key)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                self.movies = dataDictionary["results"] as! [[String:Any]]
                self.collectionView.reloadData()
            }
        }
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UICollectionViewCell
        if let indexPath = collectionView.indexPath(for: cell) {
            let movie = movies[indexPath.row]
            let detailVC = segue.destination as! DetailViewController
            detailVC.movie = movie
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath)
        let posterCell = cell as! PosterCell
        let movie = movies[indexPath.row]
        
        if let posterPath = movie["poster_path"] as? String {
            posterCell.setPosterImage(path: posterPath)
        }
        
        return posterCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
}
