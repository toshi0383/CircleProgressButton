//
//  TableViewCell.swift
//  Example
//
//  Created by 鈴木 俊裕 on 2018/03/19.
//  Copyright © 2018 toshi0383. All rights reserved.
//

import CircleProgressButton
import UIKit

final class TableViewCell: UITableViewCell {

    private let progressButton = MyCircleProgressButton(defaultIconTintColor: UIColor(hex: 0xA3A3A3))

    var progressState: Item.State = .inactive(0) {
        didSet {
            progressButton.progress = progressState.progress

            switch progressState {
            case .active:
                progressButton.resume()
            case .inactive:
                progressButton.suspend()
            case .completed:
                progressButton.complete()
            }
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    private func configure() {
        preservesSuperviewLayoutMargins = true

        addSubview(progressButton)
        progressButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressButton.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            progressButton.widthAnchor.constraint(equalToConstant: 44),
            progressButton.heightAnchor.constraint(equalToConstant: 44),
            progressButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
}
