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

    // MARK: - Properties
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
    
    
    // MARK: - Life Cycle
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
    
    
    // MARK: - Initial SetUp
    func configureNavigationBarButton() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        doneButton.tintColor = .systemGreen
        navigationItem.leftBarButtonItem = doneButton
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFavoritesButtonTapped))
        addButton.tintColor = .systemGreen
        navigationItem.rightBarButtonItem = addButton
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
            overallContainerView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
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
    
    
    // MARK: - Action Handler
    func getUserInfo() {
        print("1")
        //let semaphore = DispatchSemaphore(value: 0)
        let group = DispatchGroup()
        group.enter()
        NetworkManager.shared.getUserInfo(for: username) { [weak self] result in
            guard let self = self else {return}
            print("9")
            switch result {
            case .success(let user):
                DispatchQueue.main.async { // A)) main큐에 아래 task를 할당하고 실행 흐름 이어감
                    print("11.5")
                    print("Thread Test: ", Thread.isMainThread)
                    self.configureUIElements(with: user)
                }
                print("10")
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Error Message", message: error.rawValue, buttonTitle: "OK")
                break
            }
            print("11")
            //semaphore.signal()
            group.leave() // 여기서 leave를 치고 notify를 호출하는데 notify의 큐가 main큐이다. 위에 A))에서 먼저 main큐에 작업을 할당했기 때문에 serial큐인 main큐는 먼저 할당된 task를 끝내야만 두번째로 할당된 notify의 task를 실행한다. notify의 큐를 main이 아닌 커스텀큐로 하면 main과 커스텀큐의 notify작업이 별도로 동시에 실행됨.
        }
        print("12")
//        semaphore.wait()
//        group.wait()
        print("after Async task end")
        
// MARK: <notify의 task를 main큐에 할당했을 경우, 위에 먼저 main큐에 할당된 task->self.configureUIElements(with: user) 먼저 실행하고나서 실행>
        group.notify(queue: .main) {
            print("6") // 가장 마지막에 실행
            print("Thread Test: ", Thread.isMainThread)
        }
        
// MARK: <notify의 task를 main이 아닌 커스텀큐에 할당했을 경우>
//      group.notify(queue: .init(label: "my")) {
//          print("6") // group.leave() 호출 즉시 커스텀큐 안에 앞에 먼저 할당된 task가 없는 경우 가장 먼저 실행됨
//      }
        
//       print("6") // for semaphore
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


// MARK: - Custom Delegates
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
