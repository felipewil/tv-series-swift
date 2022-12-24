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
        static let selectedForegroundColor = "#242424"
        static let selectedBackgroundColor = "#FFFFFF"
    }

    // MARK: Properties
    
    private let title: String
    override var isSelected: Bool {
        didSet { self.update() }
    }
    
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
        self.setTitle(self.title, for: .normal)
        self.titleLabel?.font = .systemFont(ofSize: Consts.fontSize, weight: .semibold)
        self.layer.cornerRadius = Consts.cornerRadius
        
        self.setTitleColor(UIColor(hex: Consts.selectedForegroundColor), for: .highlighted)
        self.setTitleColor(UIColor(hex: Consts.foregroundColor), for: .normal)
        self.backgroundColor = UIColor(hex: self.isSelected ? Consts.selectedBackgroundColor : Consts.backgroundColor)

        self.update()
    }
    
    private func update() {
        self.backgroundColor = UIColor(hex: self.isSelected ? Consts.selectedBackgroundColor : Consts.backgroundColor)

        let titleColor = UIColor(hex: self.isSelected ? Consts.selectedForegroundColor : Consts.foregroundColor)
        self.setTitleColor(titleColor, for: .normal)
        
        self.layer.borderColor = titleColor?.cgColor
        self.layer.borderWidth = self.isSelected ? 0.5 : 0.0
    }

}
