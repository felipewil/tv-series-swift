//
//  ShowCell.swift
//  tv-series
//
//  Created by Felipe Leite on 24/12/22.
//

import Foundation

import UIKit
import Combine

enum ShowCellEvent {
    case favoriteChanged
}

class ShowCell: UITableViewCell {
    
    private struct Consts {
        static let imageSize: CGFloat = 72.0
        static let padding: CGFloat = 16.0
        static let buttonSize: CGFloat = 48.0
        static let titleFontSize: CGFloat = 17.0
    }

    // MARK: Properties
    
    static let reuseIdentifier = "ShowCell"
    private var viewModel: ShowCellViewModel?
    private var eventSubject = PassthroughSubject<ShowCellEvent, Never>()

    var eventPublisher: AnyPublisher<ShowCellEvent, Never> {
        return self.eventSubject.eraseToAnyPublisher()
    }

    var cancellables: Set<AnyCancellable> = []
    
    // MARK: Subviews
    
    lazy var showImageView: UIImageView = {
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
    
    lazy var favoriteButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        
        return button
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
    
    static func dequeueReusableCell(from tableView: UITableView, viewModel: ShowCellViewModel, for indexPath: IndexPath) -> ShowCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as! ShowCell

        cell.viewModel = viewModel
        cell.nameLabel.text = viewModel.name

//        if viewModel.isFavorite {
//            cell.favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
//        } else {
//            cell.favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
//        }
        
        cell.loadImage(viewModel: viewModel)

        return cell
    }
    
    override func prepareForReuse() {
        self.cancellables = []
        self.showImageView.image = nil
    }
    
    // MARK: Helpers
    
    private func setup() {
        self.contentView.addSubview(self.showImageView)
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.favoriteButton)
        
        NSLayoutConstraint.activate([
            self.showImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: Consts.padding),
            self.showImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: Consts.padding),
            self.showImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -Consts.padding),
            self.showImageView.heightAnchor.constraint(equalToConstant: Consts.imageSize),
            self.showImageView.widthAnchor.constraint(equalToConstant: Consts.imageSize),
        ])
        
        NSLayoutConstraint.activate([
            self.nameLabel.topAnchor.constraint(equalTo: self.showImageView.topAnchor),
            self.nameLabel.leftAnchor.constraint(equalTo: self.showImageView.rightAnchor, constant: Consts.padding),
            self.nameLabel.rightAnchor.constraint(equalTo: self.favoriteButton.leftAnchor, constant: -Consts.padding),
        ])
        
        NSLayoutConstraint.activate([
            self.favoriteButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.favoriteButton.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -Consts.padding),
            self.favoriteButton.widthAnchor.constraint(equalToConstant: Consts.buttonSize),
            self.favoriteButton.heightAnchor.constraint(equalToConstant: Consts.buttonSize),
        ])
    }
    
    private func loadImage(viewModel: ShowCellViewModel) {
        guard let url = URL(string: viewModel.mediumImageUrl) else { return }

        self.showImageView.loadImage(url: url).store(in: &cancellables)
    }
    
    @objc private func toggleFavorite() {
        self.eventSubject.send(.favoriteChanged)
    }

}
