//
//  SearchVC.swift
//  GitHubFollowers
//
//  Created by SEONGJUN on 2020/01/17.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit
import AudioToolbox.AudioServices

protocol SearchVCDelegate: class {
    func popViewController()
}


class SearchVC: UIViewController {

    let logoImageView = UIImageView()
    let usernameTextField = GFTextField()
    let callToActionButton = GFButton(backgroundColor: .systemGreen, title: "Get List")
    
    let selectionLabel = GFTitleLabel(textAlignment: .center, fontSize: 15)
    let selectionSwitch = UISwitch()
    
    var isFollowerSelected: Bool { return selectionSwitch.isOn }
    var isUsernameEntered: Bool { return !usernameTextField.text!.isEmpty }
    
    var logoImageViewTopConstaint:NSLayoutConstraint!
    var callToActionButtonBottomConstraint:NSLayoutConstraint!
    
    weak var delegate: SearchVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        configureLogoImageView()
        configureTextField()
        configureSelectionLabel()
        configureSelectionSwith()
        configureCallToActionButton()
        createDismissKeyboardTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        selectionSwitch.isOn = true
        NetworkManager.shared.whatToLoad = WhatToLoad.followers.rawValue
    }
    
    func configureSelectionLabel() {
        view.addSubview(selectionLabel)
        selectionLabel.text = "Follower"
        selectionLabel.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 30).isActive = true
        selectionLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        selectionLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        selectionLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func configureSelectionSwith() {
        view.addSubview(selectionSwitch)
        selectionSwitch.isOn = true
        selectionSwitch.addTarget(self, action: #selector(switchValueHandle(_:)), for: .valueChanged)
        
        selectionSwitch.translatesAutoresizingMaskIntoConstraints = false
        selectionSwitch.topAnchor.constraint(equalTo: selectionLabel.bottomAnchor, constant: 10).isActive = true
        selectionSwitch.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        
    }
    
    func configureLogoImageView() {
        view.addSubview(logoImageView)
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = Images.ghLogo
        
        let topConstraintConstant:CGFloat = DeviceTypes.isiPhoneSE || DeviceTypes.isiPhone8Zoomed ?  20 : 80
        
        logoImageViewTopConstaint = logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topConstraintConstant)
        logoImageViewTopConstaint.isActive = true
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 200),
            logoImageView.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    func configureTextField() {
        view.addSubview(usernameTextField)
        usernameTextField.delegate = self
    
        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 48),
            usernameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
            usernameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func configureCallToActionButton() {
        view.addSubview(callToActionButton)
        callToActionButton.addTarget(self, action: #selector(didTapFollowerListButton), for: .touchUpInside)
        
        let callToActionButtonBottomConstant:CGFloat = DeviceTypes.isiPhoneSE || DeviceTypes.isiPhone8Zoomed ?  -20 : -50
        
        callToActionButtonBottomConstraint = callToActionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: callToActionButtonBottomConstant)
        callToActionButtonBottomConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            callToActionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            callToActionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            callToActionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func switchValueHandle(_ sender: UISwitch) {
        selectionLabel.text = sender.isOn ? "Follower" : "Following"
        NetworkManager.shared.whatToLoad = sender.isOn ? "followers" : "following"
    }
    
    func createDismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
    }
    
    @objc func didTapFollowerListButton() {
        guard isUsernameEntered else {
            vibrate()
            presentGFAlertOnMainThread(title: "Empty UserName", message: "Please enter a username. We need to know who to look for :)", buttonTitle: "OK")
            return
        }
        let follwerListVC = FollowerListVC(username: usernameTextField.text!)
        self.delegate = follwerListVC
        self.usernameTextField.text?.removeAll()
        self.usernameTextField.resignFirstResponder()
        navigationController?.pushViewController(follwerListVC, animated: true)
    }
    
    func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    
}

extension SearchVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapFollowerListButton()
        return true
    }
}

extension SearchVC: FavoritesVCDelegate {
    func requestFollowerOrFollowingList(for username: String, whatToLoad: WhatToLoad) {
            
            delegate?.popViewController()
        
            self.usernameTextField.text = username
            NetworkManager.shared.whatToLoad = whatToLoad.rawValue
            didTapFollowerListButton()
        }
    }
    
    

