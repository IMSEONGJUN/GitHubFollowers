//
//  GFRepoItemVC.swift
//  GitHubFollowers
//
//  Created by SEONGJUN on 2020/01/27.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

class GFRepoItemVC: GFItemInfoVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mySwitch.isHidden = true
        configureItems()
    }
    
    func configureItems() {
        itemInfoViewOne.set(itemInfoType: .repos, withCount: user.publicRepos)
        itemInfoViewTwo.set(itemInfoType: .gists, withCount: user.publicGists)
        actionButton.set(backgroundColor: .systemPurple, title: "GitHub Profile")
    }
    
    override func didTapActionButton() {
        delegate?.didTapGitHubProfile(for: user)
//        guard let url = URL(string: user.htmlUrl) else {
//            presentGFAlertOnMainThread(title: "Invalid URL", message: "The url attached to this user is invalid.", buttonTitle: "OK")
//            return
//        }
//        presentSafariVC(with: url)
    }
}
