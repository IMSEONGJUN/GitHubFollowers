//
//  FavoriteCellTableViewCell.swift
//  GitHubFollowers
//
//  Created by SEONGJUN on 2020/01/30.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

class FavoriteCellTableViewCell: UITableViewCell {

    static let reuseID = "FavoriteCell"
    
    let avatarImageView = GFAvatarImageView(frame: .zero)
    let usernameLabel = GFTitleLabel(textAlignment: .left, fontSize: 26)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(favorite: Follower) {
        usernameLabel.text = favorite.login
        NetworkManager.shared.downLoadImage(from: favorite.avatarUrl) { [weak self] (image) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.avatarImageView.image = image
            }
        }
    }
    
    private func configure() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(usernameLabel)
        
        contentView.backgroundColor = .tertiarySystemBackground
        backgroundColor = .tertiarySystemBackground
        selectedBackgroundView?.isHidden = true
        accessoryType = .disclosureIndicator
//        let image = UIImageView(image: UIImage(systemName: "chevron.right"))
//        image.backgroundColor = .tertiarySystemBackground
//        accessoryView = image

        let padding: CGFloat = 12
        
        NSLayoutConstraint.activate([
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            avatarImageView.widthAnchor.constraint(equalToConstant: 60),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
            
            usernameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 24),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            usernameLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
}
