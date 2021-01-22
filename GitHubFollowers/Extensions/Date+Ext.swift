//
//  Date+Ext.swift
//  GitHubFollowers
//
//  Created by SEONGJUN on 2020/01/27.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    func convertToMonthYearFormat() -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MMMM yyyy"
        return dateformatter.string(from: self)
    }
}

extension UIView {
    func pinToEdge(of superView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
        }
}
