//
//  Follower.swift
//  GitHubFollowers
//
//  Created by SEONGJUN on 2020/01/19.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import Foundation

struct Follower: Codable, Hashable {
    var login: String
    var avatarUrl: String
}
