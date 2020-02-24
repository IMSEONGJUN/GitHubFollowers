//
//  GFtextField.swift
//  GitHubFollowers
//
//  Created by SEONGJUN on 2020/01/17.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

class GFTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.cornerRadius = 10
        layer.borderWidth = 2
        layer.borderColor = UIColor.systemGray4.cgColor
        
        textColor = .label
        tintColor = .label
        textAlignment = .center
        font = UIFont.preferredFont(forTextStyle: .title2)
        adjustsFontSizeToFitWidth = true
        minimumFontSize = 12
        
        backgroundColor = .tertiarySystemBackground
        autocorrectionType = .no
        //keyboardType = .emailAddress
        returnKeyType = .go
        clearButtonMode = .whileEditing
        enablesReturnKeyAutomatically = true
        
        placeholder = "Enter a username"
    }

}
