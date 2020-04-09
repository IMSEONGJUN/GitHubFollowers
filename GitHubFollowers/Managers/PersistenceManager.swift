//
//  PersistenceManager.swift
//  GitHubFollowers
//
//  Created by SEONGJUN on 2020/01/29.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import Foundation

enum PersistenceActionType {
    case add, remove
}


enum PersistenceManager {
    
    static private let defaults = UserDefaults.standard // 객체 생성없이 사용해야하며, PersistenceManager안에서만 사용해야하니까
                                                        // static private 붙여줌
    enum Keys {
        static let favorites = "favorites"
    }
    
    static func updateWith(favorite: Follower, actionType: PersistenceActionType, completed: (GFError?) -> Void) {
        
        retrieveFavorites{ result in
            
            switch result {
            case .success(let favorites):
                var retrievedFavorites = favorites
                
                switch actionType {
                case .add:
                    guard !retrievedFavorites.contains(favorite) else {
                        completed(.alreadyInFavorites)
                        return
                    }
                    retrievedFavorites.append(favorite)
                    
                case .remove:
                    retrievedFavorites.removeAll {$0.login == favorite.login}
                }
                
                completed(save(favorites: retrievedFavorites))
                
            case .failure(let error):
                completed(error)
            }
        }
        
    }
    
    static func retrieveFavorites(completed: (Result<[Follower], GFError>) -> Void) {
        guard let favoriteData = defaults.object(forKey: Keys.favorites) as? Data else {
            completed(.success([]))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let favorites = try decoder.decode([Follower].self, from: favoriteData)
            completed(.success(favorites))
        } catch {
            completed(.failure(.unableToFavorite))
        }
    }
    
    static func save(favorites: [Follower]) -> GFError? {
        do {
            let encoder = JSONEncoder()
            let encodedFavorites = try encoder.encode(favorites)
            defaults.set(encodedFavorites, forKey: Keys.favorites)
            return nil
        } catch {
            return .unableToFavorite
        }
    }
}
