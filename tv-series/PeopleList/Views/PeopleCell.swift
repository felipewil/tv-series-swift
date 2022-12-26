//
//  PeopleCell.swift
//  tv-series
//
//  Created by Felipe Leite on 26/12/22.
//

import Foundation
import UIKit
import Combine

class PeopleCell: UITableViewCell {
    
    private struct Consts {
        static let imageSize: CGFloat = 72.0
        static let padding: CGFloat = 16.0
        static let buttonSize: CGFloat = 48.0
        static let titleFontSize: CGFloat = 17.0
    }

    // MARK: Properties
    
    static let reuseIdentifier = "PeopleCell"
    private var viewModel: PeopleCellViewModel?

    var cancellables: Set<AnyCancellable> = []
    
    // MARK: Subviews
    
    lazy var peopleImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
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
    
    static func dequeueReusableCell(from tableView: UITableView, viewModel: PeopleCellViewModel, for indexPath: IndexPath) -> PeopleCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as! PeopleCell

        cell.viewModel = viewModel
        cell.nameLabel.text = viewModel.name
        cell.loadImage(viewModel: viewModel)

        return cell
    }
    
    override func prepareForReuse() {
        self.cancellables = []
        self.peopleImageView.image = nil
    }
    
    // MARK: Helpers
    
    private func setup() {
        self.contentView.addSubview(self.peopleImageView)
        self.contentView.addSubview(self.nameLabel)
        
        NSLayoutConstraint.activate([
            self.peopleImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: Consts.padding),
            self.peopleImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: Consts.padding),
            self.peopleImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -Consts.padding),
            self.peopleImageView.heightAnchor.constraint(equalToConstant: Consts.imageSize),
            self.peopleImageView.widthAnchor.constraint(equalToConstant: Consts.imageSize),
        ])
        
        NSLayoutConstraint.activate([
            self.nameLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.nameLabel.leftAnchor.constraint(equalTo: self.peopleImageView.rightAnchor, constant: Consts.padding),
            self.nameLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -Consts.padding),
        ])
    }
    
    private func loadImage(viewModel: PeopleCellViewModel) {
        guard
            let imageUrl = viewModel.mediumImageUrl,
            let url = URL(string: imageUrl) else { return }

        self.peopleImageView.loadImage(url: url)
            .store(in: &cancellables)
    }

}
