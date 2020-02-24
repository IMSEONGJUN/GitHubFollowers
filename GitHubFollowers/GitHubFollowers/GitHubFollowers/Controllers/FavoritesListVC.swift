//
//  FavoritesListVC.swift
//  GitHubFollowers
//
//  Created by SEONGJUN on 2020/01/17.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

protocol FavoritesVCDelegate: class {
    func requestFollowerOrFollowingList(for username: String, whatToLoad: WhatToLoad)
}


class FavoritesListVC: UIViewController {

    let tableView = UITableView()
    var favorites: [Follower] = []
    
    weak var delegate: FavoritesVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewDidLoad()
        configureTableView()
    }
    func configureViewDidLoad() {
        view.backgroundColor = .systemBackground
        title = "Favorites"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFavorites()
    }
    
    
    func getFavorites() {
        PersistenceManager.retrieveFavorites { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let favorites):
                if favorites.isEmpty {
                    self.tableView.separatorStyle = .none
                    self.showEmptyStateView(with: "😭 No Favorite?\nAdd one on the List screen or UserInfo screen pushing + Button", in: self.view )
                } else {
                    self.tableView.separatorStyle = .singleLine
                    self.favorites = favorites
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.view.bringSubviewToFront(self.tableView)
                    }
                }
                self.favorites = favorites
                
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Error", message: error.rawValue, buttonTitle: "OK")
            }
        }
    }
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80
        tableView.register(FavoriteCellTableViewCell.self, forCellReuseIdentifier: FavoriteCellTableViewCell.reuseID)
        tableView.frame = view.bounds
        tableView.tableFooterView = UIView(frame: .zero)
        view.addSubview(tableView)
    }
}

extension FavoritesListVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCellTableViewCell.reuseID, for: indexPath) as! FavoriteCellTableViewCell
        cell.set(favorite: favorites[indexPath.row])
        return cell
    }
    
    
}

extension FavoritesListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favorite = favorites[indexPath.row]
        let destVC = UserInfoVC()
        destVC.delegate = self
        destVC.isFromFavoriteView = true
        destVC.username = favorite.login
        destVC.title = favorite.login
        
        navigationController?.pushViewController(destVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {return}
        
        PersistenceManager.updateWith(favorite: favorites[indexPath.row], actionType: .remove) { [weak self] error in
            guard let self = self else {return}
            guard let error = error else {
                self.favorites.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                return
            }
            self.presentGFAlertOnMainThread(title: "Unable to remove", message: error.rawValue, buttonTitle: "OK")
        }
        if favorites.isEmpty {
            DispatchQueue.main.async {
                self.tableView.separatorStyle = .none
                self.showEmptyStateView(with: "😭 No Favorite?\nAdd one on the List screen or UserInfo screen pushing + Button", in: self.view )
            }
        }
    }
}
extension FavoritesListVC: UserInfoVCDelegate {
    func didRequestFollowers(for username: String, whatToLoad: WhatToLoad) {
        self.delegate?.requestFollowerOrFollowingList(for: username, whatToLoad: whatToLoad)
        DispatchQueue.main.async {
            self.tabBarController?.selectedIndex = 0
        }
        
    }
    
    
}
