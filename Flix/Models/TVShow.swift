//
//  TVShow.swift
//  Flix
//
//  Created by Hoang on 3/1/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Foundation

class TVShow: APIObject {
    var name: String
    var overview: String
    var posterUrl: URL?
    var firstAirDate: String?
    var backdropUrl: URL?
    
    override init(dictionary: [String: Any]) {
        name = dictionary["name"] as? String ?? "N/A"
        overview = dictionary["overview"] as? String ?? "N/A"
        
        let posterPath = dictionary["poster_path"] as? String ?? ""
        if let url = URL(string: APIManager.imageTmdb + posterPath) {
            self.posterUrl = url
        }
        
        if let date = dictionary["first_air_date"] as? String {
            self.firstAirDate = date
        }
        
        let backdropPath = dictionary["backdrop_path"] as? String ?? ""
        if let url = URL(string: APIManager.imageTmdb + backdropPath) {
            self.backdropUrl = url
        }
        
        super.init(dictionary: dictionary)
    }
}
