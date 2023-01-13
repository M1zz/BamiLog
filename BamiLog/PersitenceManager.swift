//
//  PersitenceManager.swift
//  BamiLog
//
//  Created by hyunho lee on 2023/01/01.
//

import Foundation

enum PersistenceActionType {
    case add, remove(Int)
}
enum GFError: String, Error {
    case invalidUsername    = "This username created an invalid request. Please try again."
    case unableToComplete   = "Unable to complete your request. Please check your internet connection"
    case invalidResponse    = "Invalid response from the server. Please try again."
    case invalidData        = "The data received from the server was invalid. Please try again."
    case unableToFavorite   = "There was an error favoriting this user. Please try again."
    case alreadyInFavorites = "You've already favorited this user. You must REALLY like them!"
}

enum PersitenceManager {
    
    static private let defaults = UserDefaults.standard
    
    enum Keys: String {
        case feed
        case profile
        case diaper
    }
    
    
    static func updateWith(favorite: MilkRecord, actionType: PersistenceActionType, key: Keys, completed: @escaping (GFError?) -> Void) {
        retrieveFavorites(key: PersitenceManager.Keys(rawValue: key.rawValue) ?? .feed) { result in
            switch result {
            case .success(var favorites):
                
                switch actionType {
                case .add:
                    guard !favorites.contains(favorite) else {
                        completed(.alreadyInFavorites)
                        return
                    }
                    
                    favorites.append(favorite)
                    
                case .remove:
                    favorites.removeAll { $0.startTime == favorite.startTime }
                }
                
                completed(save(favorites: favorites, key: key))
                
            case .failure(let error):
                completed(error)
            }
        }
    }
    
    
    static func deleteWith(records: [String? : [MilkRecord]], actionType: PersistenceActionType, key: Keys, completed: @escaping (GFError?) -> Void) {
        let favorite: MilkRecord! = MilkRecord(startTime: Date())
        var tempMilkRecord: [MilkRecord] = []
        
        for element in records {
            element.value.forEach { item in
                tempMilkRecord.append(item)
            }
        }

        
        // print("\(tempMilkRecord) ?? \(tempMilkRecord.count) ")
        retrieveFavorites(key: PersitenceManager.Keys(rawValue: key.rawValue) ?? .feed) { result in
            switch result {
            case .success(var favorites):
                
                switch actionType {
                case .add:
                    favorites = tempMilkRecord
                    
                case .remove:
                    print("remove")
                    //favorites.removeAll { $0.startTime == favorite.startTime }
                }
                
                completed(save(favorites: favorites, key: key))
                
            case .failure(let error):
                completed(error)
            }
        }
    }
    
    static func retrieveFavorites(key:Keys, completed: @escaping (Result<[MilkRecord], GFError>) -> Void) {
        guard let favoritesData = defaults.object(forKey: key.rawValue) as? Data else {
            completed(.success([]))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let favorites = try decoder.decode([MilkRecord].self, from: favoritesData)
            completed(.success(favorites))
        } catch {
            completed(.failure(.unableToFavorite))
        }
    }
    
    
    static func save(favorites: [MilkRecord], key: Keys) -> GFError? {
        do {
            let encoder = JSONEncoder()
            let encodedFavorites = try encoder.encode(favorites)
            defaults.set(encodedFavorites, forKey: key.rawValue)
            return nil
        } catch {
            return .unableToFavorite
        }
    }
    
    
    static func saveProfile(profile: Profile, key: Keys) -> GFError? {
        do {
            let encoder = JSONEncoder()
            let encodedProfile = try encoder.encode(profile)
            defaults.set(encodedProfile, forKey: key.rawValue)
            return nil
        } catch {
            return .unableToFavorite
        }
    }
    
    
    static func retrieveProfile(key:Keys, completed: @escaping (Result<Profile, GFError>) -> Void) {
        guard let profileData = defaults.object(forKey: key.rawValue) as? Data else {
            completed(.failure(.alreadyInFavorites))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let profile = try decoder.decode(Profile.self, from: profileData)
            completed(.success(profile))
        } catch {
            completed(.failure(.unableToFavorite))
        }
    }
}
