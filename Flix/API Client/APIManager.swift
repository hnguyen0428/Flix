//
//  APIManager.swift
//  Flix
//
//  Created by Hoang on 3/1/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Foundation

class APIManager {
    static let baseUrl = "https://api.themoviedb.org/3"
    static let api_key = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    static let imageTmdb = "https://image.tmdb.org/t/p/w500"
    
    var session: URLSession
    init() {
        session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
    }
    
    func makeRequest(url: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let url = URL(string: url)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            completion(data, response, error)
        }
        task.resume()
    }
    
    func nowPlayingMovies(completion: @escaping ([Movie]?, Error?) -> Void) {
        var urlString = "\(APIManager.baseUrl)/movie/now_playing"
        setApiKey(url: &urlString)
        
        makeRequest(url: urlString) { (data, response, error) in
            if let error = error {
                print(error)
                completion(nil, error)
            }
            else if let data = data {
                var movies: [Movie] = []
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let dict = dataDictionary["results"] as! [[String:Any]]
                for item in dict {
                    movies.append(Movie(dictionary: item))
                }
                completion(movies, nil)
            }
        }
    }
    
    func similarMovies(id: Int, completion: @escaping ([Movie]?, Error?) -> Void) {
        var urlString = "\(APIManager.baseUrl)/movie/\(id)/similar"
        setApiKey(url: &urlString)
        setLanguage(url: &urlString)
        
        makeRequest(url: urlString) { (data, response, error) in
            if let error = error {
                print(error)
                completion(nil, error)
            }
            else if let data = data {
                var movies: [Movie] = []
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let dict = dataDictionary["results"] as! [[String:Any]]
                for item in dict {
                    movies.append(Movie(dictionary: item))
                }
                completion(movies, nil)
            }
        }
    }
    
    func similarTVShows(id: Int, completion: @escaping ([TVShow]?, Error?) -> Void) {
        var urlString = "\(APIManager.baseUrl)/tv/\(id)/similar"
        setApiKey(url: &urlString)
        setLanguage(url: &urlString)
        
        makeRequest(url: urlString) { (data, response, error) in
            if let error = error {
                print(error)
                completion(nil, error)
            }
            else if let data = data {
                var tvShows: [TVShow] = []
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let dict = dataDictionary["results"] as! [[String:Any]]
                for item in dict {
                    tvShows.append(TVShow(dictionary: item))
                }
                completion(tvShows, nil)
            }
        }
    }
    
    func popularMovies(completion: @escaping ([Movie]?, Error?) -> Void) {
        var urlString = "\(APIManager.baseUrl)/movie/popular"
        setApiKey(url: &urlString)
        
        makeRequest(url: urlString) { (data, response, error) in
            if let error = error {
                print(error)
                completion(nil, error)
            }
            else if let data = data {
                var movies: [Movie] = []
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let dict = dataDictionary["results"] as! [[String:Any]]
                for item in dict {
                    movies.append(Movie(dictionary: item))
                }
                completion(movies, nil)
            }
        }
    }
    
    func popularTVShows(completion: @escaping ([TVShow]?, Error?) -> Void) {
        var urlString = "\(APIManager.baseUrl)/tv/popular"
        setApiKey(url: &urlString)
        
        makeRequest(url: urlString) { (data, response, error) in
            if let error = error {
                print(error)
                completion(nil, error)
            }
            else if let data = data {
                var tvShows: [TVShow] = []
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let dict = dataDictionary["results"] as! [[String:Any]]
                for item in dict {
                    tvShows.append(TVShow(dictionary: item))
                }
                completion(tvShows, nil)
            }
        }
    }
    
    func popularActors(completion: @escaping ([Actor]?, Error?) -> Void) {
        var urlString = "\(APIManager.baseUrl)/person/popular"
        setApiKey(url: &urlString)
        
        makeRequest(url: urlString) { (data, response, error) in
            if let error = error {
                print(error)
                completion(nil, error)
            }
            else if let data = data {
                var actors: [Actor] = []
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let dict = dataDictionary["results"] as! [[String:Any]]
                for item in dict {
                    actors.append(Actor(dictionary: item))
                }
                completion(actors, nil)
            }
        }
    }
    
    func searchMovies(query: String, includeAdult: String, completion: @escaping ([Movie]?, Error?) -> Void) {
        var urlString = "\(APIManager.baseUrl)/search/movie"
        setApiKey(url: &urlString)
        setLanguage(url: &urlString)
        setPage(url: &urlString, page: 1)
        urlString = urlString + "&query=\(query)&include_adult=\(includeAdult)"
        
        makeRequest(url: urlString) { (data, response, error) in
            if let error = error {
                print(error)
                completion(nil, error)
            }
            else if let data = data {
                var movies: [Movie] = []
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let dict = dataDictionary["results"] as! [[String:Any]]
                for item in dict {
                    movies.append(Movie(dictionary: item))
                }
                completion(movies, nil)
            }
        }
    }
    
    func searchTvShows(query: String, includeAdult: String, completion: @escaping ([TVShow]?, Error?) -> Void) {
        var urlString = "\(APIManager.baseUrl)/search/tv"
        setApiKey(url: &urlString)
        setLanguage(url: &urlString)
        setPage(url: &urlString, page: 1)
        urlString = urlString + "&query=\(query)&include_adult=\(includeAdult)"
        
        makeRequest(url: urlString) { (data, response, error) in
            if let error = error {
                print(error)
                completion(nil, error)
            }
            else if let data = data {
                var tvShows: [TVShow] = []
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let dict = dataDictionary["results"] as! [[String:Any]]
                for item in dict {
                    tvShows.append(TVShow(dictionary: item))
                }
                completion(tvShows, nil)
            }
        }
    }
    
    func searchActors(query: String, includeAdult: String, completion: @escaping ([Actor]?, Error?) -> Void) {
        var urlString = "\(APIManager.baseUrl)/search/person"
        setApiKey(url: &urlString)
        setLanguage(url: &urlString)
        setPage(url: &urlString, page: 1)
        urlString = urlString + "&query=\(query)&include_adult=\(includeAdult)"
        
        makeRequest(url: urlString) { (data, response, error) in
            if let error = error {
                print(error)
                completion(nil, error)
            }
            else if let data = data {
                var actors: [Actor] = []
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let dict = dataDictionary["results"] as! [[String:Any]]
                for item in dict {
                    actors.append(Actor(dictionary: item))
                }
                completion(actors, nil)
            }
        }
    }
    
    func actorDetail(id: Int, completion: @escaping (Actor?, Error?) -> Void) {
        var urlString = "\(APIManager.baseUrl)/person/\(id)"
        setApiKey(url: &urlString)
        setLanguage(url: &urlString)
        
        makeRequest(url: urlString) { (data, response, error) in
            if let error = error {
                print(error)
                completion(nil, error)
            }
            else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let actor = Actor(dictionary: dataDictionary)
                completion(actor, nil)
            }
        }
    }
    
    func getYouTubeKey(id: Int, completion: @escaping (String?, Error?) -> Void) {
        var urlString = "\(APIManager.baseUrl)/movie/\(id)/videos"
        setApiKey(url: &urlString)
        
        makeRequest(url: urlString) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil, error)
            }
            else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let result = dataDictionary["results"] as! [[String:Any]]
                
                if let res = result.first {
                    let key = res["key"] as! String
                    completion(key, nil)
                }
            }
        }
    }
    
    func setLanguage(url: inout String) {
        url = url + "&language=en-US"
    }
    
    func setPage(url: inout String, page: Int) {
        url = url + "&page=\(page)"
    }
    
    func setApiKey(url: inout String) {
        url = url + "?api_key=\(APIManager.api_key)"
    }
}
