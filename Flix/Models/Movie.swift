//
//  Movie.swift
//  Flix
//
//  Created by Hoang on 2/28/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Foundation

class Movie: APIObject {
    var title: String
    var overview: String
    var posterUrl: URL?
    var releaseDate: String?
    var backdropUrl: URL?
    
    override init(dictionary: [String: Any]) {
        title = dictionary["title"] as? String ?? "N/A"
        overview = dictionary["overview"] as? String ?? "N/A"
        
        let posterPath = dictionary["poster_path"] as? String ?? ""
        if let url = URL(string: APIManager.imageTmdb + posterPath) {
            self.posterUrl = url
        }
        
        if let date = dictionary["release_date"] as? String {
            self.releaseDate = date
        }
        
        let backdropPath = dictionary["backdrop_path"] as? String ?? ""
        if let url = URL(string: APIManager.imageTmdb + backdropPath) {
            self.backdropUrl = url
        }
        super.init(dictionary: dictionary)
    }
}
