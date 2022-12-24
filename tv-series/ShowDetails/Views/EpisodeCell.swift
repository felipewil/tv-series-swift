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
        static let imageSize: CGFloat = 72.0
        static let padding: CGFloat = 16.0
        static let buttonSize: CGFloat = 48.0
        static let titleFontSize: CGFloat = 17.0
    }

    // MARK: Properties
    
    static let reuseIdentifier = "EpisodeCell"
    private var viewModel: EpisodeCellViewModel?
    
    // MARK: Subviews
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: Consts.titleFontSize, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var airdateLabel: UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: Consts.titleFontSize, weight: .semibold)
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

        return cell
    }
    
    // MARK: Helpers
    
    private func setup() {
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.airdateLabel)
        
        NSLayoutConstraint.activate([
            self.nameLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: Consts.padding),
            self.nameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: Consts.padding),
            self.nameLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -Consts.padding),
        ])
        
        NSLayoutConstraint.activate([
            self.airdateLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.airdateLabel.leftAnchor.constraint(equalTo: self.nameLabel.rightAnchor, constant: Consts.padding),
            self.airdateLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -Consts.padding),
        ])
    }

}
