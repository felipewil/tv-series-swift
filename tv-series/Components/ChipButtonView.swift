//
//  ChipButtonView.swift
//  tv-series
//
//  Created by Felipe Leite on 24/12/22.
//

import UIKit

class ChipButtonView: UIButton {
    
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

        self.titleLabel?.text = self.title
        self.titleLabel?.textColor = UIColor(hex: Consts.foregroundColor)
        self.titleLabel?.font = .systemFont(ofSize: Consts.fontSize, weight: .semibold)
        self.layer.cornerRadius = Consts.cornerRadius
    }

}
