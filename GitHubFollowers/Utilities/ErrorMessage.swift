//
//  ErrorMessage.swift
//  GitHubFollowers
//
//  Created by SEONGJUN on 2020/01/19.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import Foundation

enum GFError: String, Error {
    case invalidUsername = "This username created an invalid request. Please try again."
    case unableToComplete = "Unable to complete your request. please check your internet connection."
    case invalidResponse = "Invalid response from the server. Please try again."
    case invalidData = "The data received from the server is invalid. Please try again."
    case unableToFavorite = "There is an error favoriting this user. Please try again."
    case alreadyInFavorites = "You've already favorited this user."
}

enum EmptyStateError: String {
    case noFollower = "This user doesn't have any followers. Go follow them 😀."
    case noFollowing = "This user doesn't follow anyone else. Tell this user follow someone😀."
}
