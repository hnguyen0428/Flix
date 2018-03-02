//
//  ActorDetailViewController.swift
//  Flix
//
//  Created by Hoang on 2/12/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Foundation
import UIKit

class ActorDetailViewController: UIViewController, UICollectionViewDataSource,
                                UICollectionViewDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pobLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var biographyTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let BIOGRAPHY = 0
    let KNOWN_FOR = 1
    
    var id: Int?
    var knownFor: [[String:Any]] = []
    
    var actor: Actor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isHidden = true
        collectionView.backgroundColor = .clear
        
        profileImageView.layer.borderWidth = 1.0
        profileImageView.layer.borderColor = UIColor.white.cgColor
        
        calculateCellSize()
        
        fetchActorInfo { actor in
            if let actor = actor {
                self.nameLabel.text = actor.name
                if var birthday = actor.birthday {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    let date = formatter.date(from: birthday)
                    formatter.dateFormat = "MMM d, yyyy"
                    birthday = formatter.string(from: date!)
                    self.birthdayLabel.text = birthday
                }
                
                if let pob = actor.placeOfBirth {
                    self.pobLabel.text = pob
                    self.pobLabel.sizeToFit()
                }
                
                if let url = actor.profileUrl {
                    self.profileImageView.af_setImage(withURL: url)
                }
                
                if let biography = actor.biography {
                    self.biographyTextView.text = biography
                }
            }
        }
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
    
    func fetchActorInfo(completion: ((Actor?) -> Void)? = nil) {
        self.shadeView(shaded: true)
        APIManager().actorDetail(id: self.id!) { (actor, error) in
            if let error = error {
                print(error.localizedDescription)
                completion?(nil)
            }
            else if let actor = actor {
                self.actor = actor
                completion?(self.actor)
            }
            self.shadeView(shaded: false)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailViewController {
            let cell = sender as! UICollectionViewCell
            let indexPath = collectionView.indexPath(for: cell)!
            let content = knownFor[indexPath.row]
            
            if let type = content["media_type"] as? String {
                if type == "movie" {
                    vc.movie = Movie(dictionary: content)
                    vc.contentType = 0
                }
                else if type == "tv" {
                    vc.tvShow = TVShow(dictionary: content)
                    vc.contentType = 1
                }
            }
        }
    }
    
    
    @IBAction func toggledSegmentedControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == BIOGRAPHY {
            self.hideViewWithAnimation(view: collectionView, duration: 0.2, hidden: true)
            self.hideViewWithAnimation(view: biographyTextView, duration: 0.2, hidden: false)
        }
        else {
            self.hideViewWithAnimation(view: collectionView, duration: 0.2, hidden: false)
            self.hideViewWithAnimation(view: biographyTextView, duration: 0.2, hidden: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return knownFor.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath)
        let posterCell = cell as! PosterCell
        
        let content = knownFor[indexPath.row]
        if let path = content["poster_path"] as? String {
            posterCell.setPosterImage(path: path)
        }
        
        return posterCell
    }
    
}

