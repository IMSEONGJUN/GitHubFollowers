//
//  UserInfoVC.swift
//  GitHubFollowers
//
//  Created by SEONGJUN on 2020/01/20.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import SafariServices

protocol UserInfoVCDelegate: class {
    func didRequestFollowers(for username: String, whatToLoad: WhatToLoad)
}


class UserInfoVC: UIViewController {

    let scrollView = UIScrollView()
    let overallContainerView = UIView()
    
    let headerView = UIView()
    let itemViewOne = UIView()
    let itemViewTwo = UIView()
    let dateLabel = GFBodyLabel(textAlignment: .center)
    
    var itemViews = [UIView]()
    var isFromFavoriteView = false
    var username = ""
    
    weak var delegate: UserInfoVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        if !isFromFavoriteView {
            configureNavigationBarButton()
        } else {
            navigationController?.navigationBar.isHidden = false
            navigationController?.navigationBar.prefersLargeTitles = false
        }
        configureScrollView()
        layoutUI()
        getUserInfo()
    }
    
    func configureNavigationBarButton() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        doneButton.tintColor = .systemGreen
        navigationItem.leftBarButtonItem = doneButton
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFavoritesButtonTapped))
        addButton.tintColor = .systemGreen
        navigationItem.rightBarButtonItem = addButton
    }
    
    @objc func addFavoritesButtonTapped() {
        NetworkManager.shared.getUserInfo(for: username) {[weak self] result in
            guard let self = self else {return}
            
            switch result {
            case .success(let user):
                self.addUserToFavoriteVC(user: user)
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Error Message", message: error.rawValue, buttonTitle: "OK")
            }
        }
    }
    
    func addUserToFavoriteVC(user: User) {
        let favorite = Follower(login: user.login, avatarUrl: user.avatarUrl)
        
        PersistenceManager.updateWith(favorite: favorite, actionType: .add) {[weak self] error in
            guard let self = self else {return}
            guard let error = error else {
                self.presentGFAlertOnMainThread(title: "Success!", message: "You have successfully favorited this user.", buttonTitle: "OK")
                return
            }
            self.presentGFAlertOnMainThread(title: "Error Message", message: error.rawValue, buttonTitle: "OK")
        }
    }
    
    func getUserInfo() {
        print("1")
        let group = DispatchGroup()
        group.enter()
        NetworkManager.shared.getUserInfo(for: username) { [weak self] result in
            guard let self = self else {return}
            print("9")
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    print("11.5")
                    self.configureUIElements(with: user)
                }
                print("10")
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Error Message", message: error.rawValue, buttonTitle: "OK")
                break
            }
            print("11")
            group.leave()
        }
//        group.wait()
        group.notify(queue: .main) {
            print("6")
        }
        
    }
    
    func configureUIElements(with user: User) {
        print("12")
        self.add(childVC: GFUserInfoHeaderVC(user: user), to: self.headerView)
        
        let repoItemVC = GFRepoItemVC(user: user)
        repoItemVC.delegate = self
        
        let followerItemVC = GFFollowerItemVC(user: user)
        followerItemVC.whatToLoad = .followers
        followerItemVC.delegate = self
        
        self.add(childVC: repoItemVC, to: self.itemViewOne)
        self.add(childVC: followerItemVC, to: self.itemViewTwo)
        self.dateLabel.text = "Started GitHub Since \(user.createdAt.convertToMonthYearFormat())"
        print("13")
    }
    
    func configureScrollView(){
        view.addSubview(scrollView)
        scrollView.addSubview(overallContainerView)
        scrollView.pinToEdge(of: view)
        overallContainerView.pinToEdge(of: scrollView)
        
        NSLayoutConstraint.activate([
            overallContainerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            overallContainerView.heightAnchor.constraint(equalToConstant: 600)
        ])
        
    }
    
    func layoutUI() {
        let padding: CGFloat = 20
        let itemHeight: CGFloat = 140
        
        itemViews = [headerView, itemViewOne, itemViewTwo, dateLabel]
        itemViews.forEach {overallContainerView.addSubview($0)}
        itemViews.forEach {$0.translatesAutoresizingMaskIntoConstraints = false}
        itemViews.forEach{
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: overallContainerView.leadingAnchor, constant: padding),
                $0.trailingAnchor.constraint(equalTo: overallContainerView.trailingAnchor, constant: -padding)
            ])
        }
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: overallContainerView.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 210),
            
            itemViewOne.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: padding),
            itemViewOne.heightAnchor.constraint(equalToConstant: itemHeight),
            
            itemViewTwo.topAnchor.constraint(equalTo: itemViewOne.bottomAnchor, constant: padding),
            itemViewTwo.heightAnchor.constraint(equalToConstant: itemHeight),
            
            dateLabel.topAnchor.constraint(equalTo: itemViewTwo.bottomAnchor, constant: padding),
            dateLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func add(childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
        
    }
    
    @objc func dismissVC() {
        dismiss(animated: true)
    }


}
extension UserInfoVC: GFItemInfoVCDelegate {
    func didTapGitHubProfile(for user: User) {
        guard let url = URL(string: user.htmlUrl) else {
            presentGFAlertOnMainThread(title: "Invalid URL", message: "The url attached to this user is invalid.", buttonTitle: "OK")
            return
        }
        presentSafariVC(with: url)
    }
    
    func didTapGetFollowers(for user: User, whatToLoad: WhatToLoad) {
        delegate?.didRequestFollowers(for: user.login, whatToLoad: whatToLoad)
        
        if !isFromFavoriteView {
            dismissVC()
        } 
    }
    
    
}
