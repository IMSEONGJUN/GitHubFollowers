//
//  NetworkManager.swift
//  GitHubFollowers
//
//  Created by SEONGJUN on 2020/01/19.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

class NetworkManager {
    
    static let shared = NetworkManager()
    private init() {}
    
    private let baseURL = "https://api.github.com/users/"
    private let cache = NSCache<NSString, UIImage>()
    private let countPerPage = 100
    
    var whatToLoad = WhatToLoad.followers.rawValue
    
    func getFollowers(for username: String, page: Int?, completed: @escaping (Result<[Follower], GFError>) -> Void) {
        
        let endpoint = baseURL + "\(username)/\(whatToLoad)?per_page=\(countPerPage)&page=\(page ?? 0)"
        
        guard let url = URL(string: endpoint) else {
            completed(.failure(.invalidUsername))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let _ = error {
                completed(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) else {
                completed(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let followers = try decoder.decode([Follower].self, from: data)
                completed(.success(followers))
            } catch {
                completed(.failure(.invalidData))
            }
        }
        
        task.resume()
    }
    
    func getUserInfo(for username: String, completed: @escaping (Result<User, GFError>) -> Void) {
        let endpoint = baseURL + "\(username)"
        print("2")
        guard let url = URL(string: endpoint) else {
            completed(.failure(.invalidUsername))
            return
        }
        print("3")
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            print("7")
            print("\nthread Test: ", Thread.isMainThread) // false
            guard error == nil else {
                completed(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) else {
                completed(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .iso8601
                let user = try decoder.decode(User.self, from: data)
                print("8")
                completed(.success(user))
            } catch {
                completed(.failure(.invalidData))
            }
            print("Async task end")
        }
        print("4")
        task.resume()
        print("5")
    }
    
    func downLoadImage(from urlString: String, completed: @escaping (UIImage?) -> Void) {
        let cacheKey = NSString(string: urlString)
        
        if let image = cache.object(forKey: cacheKey) {
            completed(image)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completed(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                error == nil,
                let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode),
                let data = data,
                let image = UIImage(data: data) else {
                    completed(nil)
                return
            }
            
            self.cache.setObject(image, forKey: cacheKey)
            
            completed(image)
        }
        
        task.resume()
    }
}
