//
//  ChipView.swift
//  tv-series
//
//  Created by Felipe Leite on 24/12/22.
//

import UIKit

class ChipView: UIView {
    
    private struct Consts {
        static let horizontalPadding: CGFloat = 14.0
        static let verticalPadding: CGFloat = 4.0
        static let cornerRadius: CGFloat = 8.0
        static let fontSize: CGFloat = 13.0
        static let foregroundColor = "#FFFFFF"
        static let backgroundColor = "#242424"
    }

    // MARK: Properties
    
    private let title: String
    
    // MARK: Subviews
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()

        label.font = .systemFont(ofSize: Consts.fontSize, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    // MARK: Initialization
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        self.title = ""
        super.init(coder: coder)
    }
    
    // MARK: Setup
    
    private func setup() {
        self.backgroundColor = UIColor(hex: Consts.backgroundColor)
        self.addSubview(self.titleLabel)

        NSLayoutConstraint.activate([
            self.titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: Consts.horizontalPadding),
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: Consts.verticalPadding),
            self.titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -Consts.horizontalPadding),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Consts.verticalPadding),
        ])

        self.titleLabel.text = self.title
        self.titleLabel.textColor = UIColor(hex: Consts.foregroundColor)
        self.layer.cornerRadius = Consts.cornerRadius
        
        self.titleLabel.setContentHuggingPriority(.required, for: .horizontal)
    }

}
