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
    }
    
    // MARK: Properties
    
    static let reuseIdentifier = "LoadingCell"
    
    // MARK: Subviews
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)

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
    
    static func dequeueReusableCell(from tableView: UITableView, for indexPath: IndexPath) -> LoadingCell {
        return tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as! LoadingCell
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.activityIndicator.startAnimating()
    }

    // MARK: Helpers
    
    private func setup() {
        self.contentView.addSubview(self.activityIndicator)
        
        NSLayoutConstraint.activate([
            self.activityIndicator.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.activityIndicator.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: Consts.padding),
            self.activityIndicator.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -Consts.padding),
        ])
        
        self.activityIndicator.startAnimating()
    }

}
