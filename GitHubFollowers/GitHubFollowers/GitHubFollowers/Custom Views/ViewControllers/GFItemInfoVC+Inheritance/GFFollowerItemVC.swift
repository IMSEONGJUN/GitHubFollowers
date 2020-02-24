//
//  GFFollowerItemVC.swift
//  GitHubFollowers
//
//  Created by SEONGJUN on 2020/01/27.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

class GFFollowerItemVC: GFItemInfoVC {
    
    var whatToLoad: WhatToLoad!
    var buttonTitle = "Get Followers"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMySwitch()
        setWhatToLoad()
        configureItems()
    }
    
    private func setMySwitch(){
        self.mySwitch.isOn = true
    }
    
    private func setWhatToLoad() {
        whatToLoad = mySwitch.isOn ? .followers : .following
    }
    
    func configureItems() {
        itemInfoViewOne.set(itemInfoType: .following, withCount: user.following)
        itemInfoViewTwo.set(itemInfoType: .followers, withCount: user.followers)
        self.actionButton.set(backgroundColor: .systemGreen, title: buttonTitle)
    }
    
    override func didTapActionButton() {
        delegate?.didTapGetFollowers(for: user, whatToLoad: whatToLoad)
    }
    
    override func switchButtonHandle(_sender: UISwitch) {
        
        self.actionButton.setTitle(self.mySwitch.isOn ? "Get Followers" : "Get Following", for: .normal)
        
        whatToLoad = mySwitch.isOn ? .followers : .following
    }
    
}
