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

    // MARK: - Properties
    let tableView = UITableView()
    var favorites: [Follower] = []
    
    weak var delegate: FavoritesVCDelegate?
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNaviBar()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFavorites()
    }
    
    
    // MARK: - Initial SetUp
    func configureNaviBar() {
        view.backgroundColor = .systemBackground
        title = "Favorites"
        navigationController?.navigationBar.prefersLargeTitles = true
//        let appearance = UINavigationBarAppearance()
//        appearance.largeTitleTextAttributes = [.foregroundColor : UIColor.black]
//        navigationController?.navigationBar.standardAppearance = appearance
    }
    
    func configureTableView() {
        tableView.backgroundColor = .tertiarySystemBackground
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80
        tableView.register(FavoriteCellTableViewCell.self, forCellReuseIdentifier: FavoriteCellTableViewCell.reuseID)
        tableView.frame = view.bounds
        tableView.tableFooterView = UIView(frame: .zero)
        view.addSubview(tableView)
    }
    
    // MARK: - Action Handler
    func getFavorites() {
        PersistenceManager.retrieveFavorites { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let favorites):
                if favorites.isEmpty {
                    self.tableView.separatorStyle = .none
                    self.showEmptyStateView(with: "😭 No Favorite?\nAdd certain Github user by pushing + Button", in: self.view )
                } else {
                    self.tableView.separatorStyle = .singleLine
                    self.favorites = favorites
                    DispatchQueue.main.async {
                        if let emptyView = self.view.subviews.last as? GFEmptyStateView {
                            emptyView.removeFromSuperview()
                        }
                        self.tableView.reloadData()
//                        self.view.bringSubviewToFront(self.tableView)
                    }
                }
                self.favorites = favorites
                
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Error", message: error.rawValue, buttonTitle: "OK")
            }
        }
    }
}


// MARK: - UITableViewDataSource
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


// MARK: - UITableViewDelegate
extension FavoritesListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favorite = favorites[indexPath.row]
        let userInfoVC = UserInfoVC()
//        guard let searchVC = self.tabBarController?.viewControllers?.first?.children.first as? SearchVC else { return } // 탭바 컨트롤러의 뷰컨트롤러 중 그것의 children 중 첫번째로 찾아서 searchVC객체에 delegate 연결할 수 있었다.
        
//        userInfoVC.delegate = searchVC
        userInfoVC.delegate = self
        userInfoVC.isFromFavoriteView = true
        userInfoVC.username = favorite.login
        userInfoVC.title = favorite.login
        
        navigationController?.pushViewController(userInfoVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {return}
        print("1")
        
        PersistenceManager.updateWith(favorite: favorites[indexPath.row], actionType: .remove) { [weak self] error in
            guard let self = self else {return}
            guard let error = error else {
                print("2")
                self.favorites.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                return
            }
            self.presentGFAlertOnMainThread(title: "Unable to remove", message: error.rawValue, buttonTitle: "OK")
        }
        print("3")
        if favorites.isEmpty {
            print("5")
            DispatchQueue.main.async {
                self.tableView.separatorStyle = .none
                self.showEmptyStateView(with: "😭 No Favorite?\nAdd certain Github user by pushing + Button", in: self.view )
                print("7")
            }
            print("6")
        }
        print("4")
    }
}


// MARK: - UserInfoVCDelegate
extension FavoritesListVC: UserInfoVCDelegate {
    func didRequestFollowers(for username: String, whatToLoad: WhatToLoad) {
        self.delegate?.requestFollowerOrFollowingList(for: username, whatToLoad: whatToLoad)
        DispatchQueue.main.async {
            self.tabBarController?.selectedIndex = 0
        }
        
    }
}
