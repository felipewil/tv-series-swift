//
//  EpisodeDetailsViewController.swift
//  tv-series
//
//  Created by Felipe Leite on 24/12/22.
//

import Foundation
import UIKit
import Combine

class EpisodeDetailsViewController: UIViewController {
    
    private struct Consts {
        static let padding: CGFloat = 16.0
        static let imageSize: CGFloat = 96.0
        static let titleFontSize: CGFloat = 28.0
        static let subtitleFontSize: CGFloat = 18.0
        static let bodyFontSize: CGFloat = 15.0
    }

    // MARK: Properties
    
    private let viewModel: EpisodeDetailsViewModel!
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: Subviews
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()

        scrollView.translatesAutoresizingMaskIntoConstraints = false

        return scrollView
    }()
    
    lazy var scrollContentView: UIView = {
        let view = UIView()
       
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()

        label.numberOfLines = 0
        label.font = .systemFont(ofSize: Consts.titleFontSize, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    lazy var numberLabel: UILabel = {
        let label = UILabel()

        label.font = .systemFont(ofSize: Consts.subtitleFontSize)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    lazy var summaryLabel: UILabel = {
        let label = UILabel()

        label.text = "Summary"
        label.font = .systemFont(ofSize: Consts.subtitleFontSize, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    lazy var summaryContentLabel: UILabel = {
        let label = UILabel()

        label.numberOfLines = 0
        label.font = .systemFont(ofSize: Consts.bodyFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(hex: "#242424")

        return imageView
    }()
    
    // MARK: Initialization
    
    init(viewModel: EpisodeDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        self.setup()
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = nil
        super.init(coder: coder)
    }

    // MARK: Public methods
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard self.traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else { return }
        
        DispatchQueue.main.async {
            self.setupSummary()
        }
    }

    // MARK: Helpers
    
    private func setup() {
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(self.scrollView)
        
        self.scrollView.addSubview(self.scrollContentView)
        
        self.scrollContentView.addSubview(self.imageView)
        self.scrollContentView.addSubview(self.summaryLabel)
        self.scrollContentView.addSubview(self.summaryContentLabel)
        
        let titleWrapper = UIView()
        titleWrapper.translatesAutoresizingMaskIntoConstraints = false
        titleWrapper.addSubview(self.titleLabel)
        titleWrapper.addSubview(self.numberLabel)
        self.view.addSubview(titleWrapper)
        
        NSLayoutConstraint.activate([
            self.scrollView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.scrollView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            self.scrollContentView.leftAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leftAnchor),
            self.scrollContentView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
            self.scrollContentView.rightAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.rightAnchor),
            self.scrollContentView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
            // Only vertical scroll
            self.scrollContentView.leftAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.leftAnchor),
            self.scrollContentView.rightAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.rightAnchor),
        ])
        
        NSLayoutConstraint.activate([
            self.imageView.leftAnchor.constraint(equalTo: self.scrollContentView.leftAnchor, constant: Consts.padding),
            self.imageView.topAnchor.constraint(equalTo: self.scrollContentView.topAnchor, constant: Consts.padding),
            self.imageView.heightAnchor.constraint(equalToConstant: Consts.imageSize),
            self.imageView.widthAnchor.constraint(equalToConstant: Consts.imageSize),
        ])

        NSLayoutConstraint.activate([
            titleWrapper.leftAnchor.constraint(equalTo: self.imageView.rightAnchor, constant: Consts.padding),
            titleWrapper.centerYAnchor.constraint(equalTo: self.imageView.centerYAnchor),
            titleWrapper.rightAnchor.constraint(equalTo: self.scrollContentView.rightAnchor, constant: -Consts.padding),
        ])
        
        NSLayoutConstraint.activate([
            self.titleLabel.leftAnchor.constraint(equalTo: titleWrapper.leftAnchor),
            self.titleLabel.topAnchor.constraint(equalTo: titleWrapper.topAnchor),
            self.titleLabel.rightAnchor.constraint(equalTo: titleWrapper.rightAnchor),
        ])
        
        NSLayoutConstraint.activate([
            self.numberLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor),
            self.numberLabel.leftAnchor.constraint(equalTo: titleWrapper.leftAnchor),
            self.numberLabel.rightAnchor.constraint(equalTo: titleWrapper.rightAnchor),
            self.numberLabel.bottomAnchor.constraint(equalTo: titleWrapper.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            self.numberLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor),
            self.numberLabel.leftAnchor.constraint(equalTo: titleWrapper.leftAnchor),
            self.numberLabel.rightAnchor.constraint(equalTo: titleWrapper.rightAnchor),
            self.numberLabel.bottomAnchor.constraint(equalTo: titleWrapper.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            self.summaryLabel.leftAnchor.constraint(equalTo: self.scrollContentView.leftAnchor, constant: Consts.padding),
            self.summaryLabel.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: Consts.padding),
            self.summaryLabel.rightAnchor.constraint(equalTo: self.scrollContentView.rightAnchor, constant: -Consts.padding),
        ])

        NSLayoutConstraint.activate([
            self.summaryContentLabel.leftAnchor.constraint(equalTo: self.scrollContentView.leftAnchor, constant: Consts.padding),
            self.summaryContentLabel.topAnchor.constraint(equalTo: self.summaryLabel.bottomAnchor),
            self.summaryContentLabel.rightAnchor.constraint(equalTo: self.scrollContentView.rightAnchor, constant: -Consts.padding),
            self.summaryContentLabel.bottomAnchor.constraint(equalTo: self.scrollContentView.bottomAnchor, constant: -Consts.padding),
        ])

        if let imageUrl = self.viewModel.mediumImageUrl, let url = URL(string: imageUrl) {
            self.imageView.loadImage(url: url)
                .store(in: &cancellables)
        } else {
            self.imageView.image = UIImage(systemName: "tv")
        }

        self.titleLabel.text = self.viewModel.name
        self.numberLabel.text = "Episode: \(self.viewModel.number) Season: \(self.viewModel.number)"
        self.setupSummary()
    }

    private func setupSummary() {
        let darkMode = self.traitCollection.userInterfaceStyle == .dark
        self.summaryContentLabel.attributedText = .templatedHtml(self.viewModel.summary ?? "<em>No summary</em>",
                                                                 darkMode: darkMode)
    }

}

