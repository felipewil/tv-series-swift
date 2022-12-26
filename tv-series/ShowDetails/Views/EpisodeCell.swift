//
//  EpisodeCell.swift
//  tv-series
//
//  Created by Felipe Leite on 24/12/22.
//

import UIKit
import Combine

class EpisodeCell: UITableViewCell {
    
    private struct Consts {
        static let imageHeight: CGFloat = 40.5
        static let imageWidth: CGFloat = 72.0
        static let padding: CGFloat = 16.0
        static let titleFontSize: CGFloat = 17.0
        static let subtitleFontSize: CGFloat = 14.0
    }

    // MARK: Properties
    
    static let reuseIdentifier = "EpisodeCell"
    private var viewModel: EpisodeCellViewModel?
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: Subviews
    
    lazy var episodeImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(hex: "#242424")
        
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: Consts.titleFontSize, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var airdateLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: Consts.subtitleFontSize)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // MARK: Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    // MARK: Public methods
    
    static func dequeueReusableCell(from tableView: UITableView, viewModel: EpisodeCellViewModel, for indexPath: IndexPath) -> EpisodeCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as! EpisodeCell

        cell.nameLabel.text = viewModel.name
        cell.setAirdate(viewModel.airdate)
        cell.loadImage(viewModel: viewModel)

        return cell
    }
    
    override func prepareForReuse() {
        self.cancellables = []
        self.episodeImageView.image = nil
    }
    
    // MARK: Helpers
    
    private func setup() {
        self.contentView.addSubview(self.episodeImageView)
        
        NSLayoutConstraint.activate([
            self.episodeImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: Consts.padding),
            self.episodeImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: Consts.padding),
            self.episodeImageView.heightAnchor.constraint(equalToConstant: Consts.imageHeight),
            self.episodeImageView.widthAnchor.constraint(equalToConstant: Consts.imageWidth),
        ])
        
        let bottomAnchor = self.episodeImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor,
                                                                         constant: -Consts.padding)
        bottomAnchor.isActive = true
        // Removing "breaking constraint" warning
        bottomAnchor.priority = .defaultHigh
        
        let contentWrapper = UIView()
        contentWrapper.translatesAutoresizingMaskIntoConstraints = false
        contentWrapper.addSubview(self.nameLabel)
        contentWrapper.addSubview(self.airdateLabel)
        
        self.contentView.addSubview(contentWrapper)
        
        NSLayoutConstraint.activate([
            contentWrapper.leftAnchor.constraint(equalTo: self.episodeImageView.rightAnchor, constant: Consts.padding),
            contentWrapper.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -Consts.padding),
            contentWrapper.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.nameLabel.leftAnchor.constraint(equalTo: contentWrapper.leftAnchor),
            self.nameLabel.topAnchor.constraint(equalTo: contentWrapper.topAnchor),
            self.nameLabel.rightAnchor.constraint(equalTo: contentWrapper.rightAnchor),
        ])

        NSLayoutConstraint.activate([
            self.airdateLabel.leftAnchor.constraint(equalTo: contentWrapper.leftAnchor),
            self.airdateLabel.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor),
            self.airdateLabel.rightAnchor.constraint(equalTo: contentWrapper.rightAnchor),
            self.airdateLabel.bottomAnchor.constraint(equalTo: contentWrapper.bottomAnchor),
        ])
    }

    private func loadImage(viewModel: EpisodeCellViewModel) {
        if let imageUrl = viewModel.mediumImageUrl, let url = URL(string: imageUrl) {
            self.episodeImageView.loadImage(url: url).store(in: &cancellables)
        } else {
            self.episodeImageView.image = UIImage(systemName: "tv")
        }
    }

    private func setAirdate(_ airdate: String?) {
        self.airdateLabel.text = nil
        
        guard let airdate else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        
        guard let date = dateFormatter.date(from: airdate) else { return }

        dateFormatter.dateFormat = "dd/mm/yyyy"
        self.airdateLabel.text = dateFormatter.string(from: date)
    }

}
