//
//  LoadingCell.swift
//  tv-series
//
//  Created by Felipe Leite on 23/12/22.
//

import UIKit

class LoadingCell: UITableViewCell {
    
    private struct Consts {
        static let padding: CGFloat = 32.0
        static let contentPadding: CGFloat = 4.0
        static let descriptionFontSize: CGFloat = 14.0
    }
    
    // MARK: Properties
    
    static let reuseIdentifier = "LoadingCell"
    
    // MARK: Subviews
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)

        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()

        label.font = .systemFont(ofSize: Consts.descriptionFontSize, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    private lazy var wrapperView: UIView = {
        let view = UIView()

        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
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
    
    // MARK: Public method
    
    static func dequeueReusableCell(from tableView: UITableView, description: String? = nil, for indexPath: IndexPath) -> LoadingCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as! LoadingCell

        cell.descriptionLabel.text = description

        return cell
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.activityIndicator.startAnimating()
    }

    // MARK: Helpers
    
    private func setup() {
        self.contentView.addSubview(self.wrapperView)
        self.wrapperView.addSubview(self.activityIndicator)
        self.wrapperView.addSubview(self.descriptionLabel)
        
        self.descriptionLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            self.wrapperView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.wrapperView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.wrapperView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: Consts.padding),
            self.wrapperView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -Consts.padding),
        ])

        NSLayoutConstraint.activate([
            self.activityIndicator.topAnchor.constraint(equalTo: self.wrapperView.topAnchor),
            self.activityIndicator.leftAnchor.constraint(equalTo: self.wrapperView.leftAnchor),
            self.activityIndicator.rightAnchor.constraint(equalTo: self.wrapperView.rightAnchor),
        ])
        
        NSLayoutConstraint.activate([
            self.descriptionLabel.topAnchor.constraint(equalTo: self.activityIndicator.bottomAnchor, constant: Consts.contentPadding),
            self.descriptionLabel.leftAnchor.constraint(equalTo: self.wrapperView.leftAnchor),
            self.descriptionLabel.rightAnchor.constraint(equalTo: self.wrapperView.rightAnchor),
            self.descriptionLabel.bottomAnchor.constraint(equalTo: self.wrapperView.bottomAnchor),
        ])
        
        self.activityIndicator.startAnimating()
    }

}
