//
//  APIObject.swift
//  Flix
//
//  Created by Hoang on 3/1/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Foundation

class APIObject {
    var id: Int
    
    init(dictionary: [String:Any]) {
        id = dictionary["id"] as! Int
    }
}
