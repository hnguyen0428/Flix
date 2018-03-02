//
//  Actor.swift
//  Flix
//
//  Created by Hoang on 3/1/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Foundation

class Actor: APIObject {
    var name: String
    var birthday: String?
    var placeOfBirth: String?
    var biography: String?
    var profileUrl: URL?
    var knownFor: [[String:Any]]?
    
    override init(dictionary: [String: Any]) {
        name = dictionary["name"] as? String ?? "N/A"
        birthday = dictionary["birthday"] as? String
        placeOfBirth = dictionary["place_of_birth"] as? String
        biography = dictionary["biography"] as? String
        
        let profilePath = dictionary["profile_path"] as? String ?? ""
        if let url = URL(string: APIManager.imageTmdb + profilePath) {
            self.profileUrl = url
        }
        knownFor = dictionary["known_for"] as? [[String:Any]]
        super.init(dictionary: dictionary)
    }
}
