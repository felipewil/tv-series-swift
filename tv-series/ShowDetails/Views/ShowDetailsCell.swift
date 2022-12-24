//
//  ShowDetailsCell.swift
//  tv-series
//
//  Created by Felipe Leite on 24/12/22.
//

import UIKit
import Combine

class ShowDetailsCell: UITableViewCell {
    
    private struct Consts {
        static let padding: CGFloat = 16.0
        static let imageSize: CGFloat = 96.0
        static let titleFontSize: CGFloat = 28.0
        static let subtitleFontSize: CGFloat = 18.0
        static let bodyFontSize: CGFloat = 15.0
    }

    // MARK: Properties
    
    static let reuseIdentifier = "ShowDetailsCell"
    private var viewModel: ShowDetailsCellViewModel!

    var cancellables: Set<AnyCancellable> = []
    
    // MARK: Subviews
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()

        label.numberOfLines = 0
        label.font = .systemFont(ofSize: Consts.titleFontSize, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    lazy var genreLabel: UILabel = {
        let label = UILabel()

        label.numberOfLines = 0
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
    
    lazy var showImageView: UIImageView = {
        let imageView = UIImageView()

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()
    
    lazy var timeStackView: UIStackView = {
        let view = UIStackView()

        view.spacing = 3.0
        view.distribution = .fill
        view.axis = .horizontal
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()
    
    lazy var daysStackView: UIStackView = {
        let view = UIStackView()

        view.spacing = 3.0
        view.distribution = .fill
        view.axis = .horizontal
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
    
    // MARK: Public methods
    
    static func dequeueReusableCell(from tableView: UITableView, viewModel: ShowDetailsCellViewModel, for indexPath: IndexPath) -> ShowDetailsCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as! ShowDetailsCell

        cell.viewModel = viewModel
        cell.prepareContent()

        return cell
    }
    
    override func prepareForReuse() {
        self.cancellables = []
    }
    
    // MARK: Helpers
    
    private func setup() {
        self.selectionStyle = .none
        self.contentView.addSubview(self.showImageView)
        self.contentView.addSubview(self.timeStackView)
        self.contentView.addSubview(self.daysStackView)
        self.contentView.addSubview(self.summaryLabel)
        self.contentView.addSubview(self.summaryContentLabel)
        
        let titleWrapper = UIView()
        titleWrapper.translatesAutoresizingMaskIntoConstraints = false
        titleWrapper.addSubview(self.titleLabel)
        titleWrapper.addSubview(self.genreLabel)
        self.contentView.addSubview(titleWrapper)
        
        NSLayoutConstraint.activate([
            self.showImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: Consts.padding),
            self.showImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: Consts.padding),
            self.showImageView.heightAnchor.constraint(equalToConstant: Consts.imageSize),
            self.showImageView.widthAnchor.constraint(equalToConstant: Consts.imageSize),
        ])

        NSLayoutConstraint.activate([
            titleWrapper.leftAnchor.constraint(equalTo: self.showImageView.rightAnchor, constant: Consts.padding),
            titleWrapper.centerYAnchor.constraint(equalTo: self.showImageView.centerYAnchor),
            titleWrapper.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -Consts.padding),
        ])
        
        NSLayoutConstraint.activate([
            self.titleLabel.leftAnchor.constraint(equalTo: titleWrapper.leftAnchor),
            self.titleLabel.topAnchor.constraint(equalTo: titleWrapper.topAnchor),
            self.titleLabel.rightAnchor.constraint(equalTo: titleWrapper.rightAnchor),
        ])
        
        NSLayoutConstraint.activate([
            self.genreLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor),
            self.genreLabel.leftAnchor.constraint(equalTo: titleWrapper.leftAnchor),
            self.genreLabel.rightAnchor.constraint(equalTo: titleWrapper.rightAnchor),
            self.genreLabel.bottomAnchor.constraint(equalTo: titleWrapper.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            self.daysStackView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: Consts.padding),
            self.daysStackView.topAnchor.constraint(equalTo: self.showImageView.bottomAnchor, constant: Consts.padding),
            self.daysStackView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -Consts.padding),
        ])

        NSLayoutConstraint.activate([
            self.timeStackView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: Consts.padding),
            self.timeStackView.topAnchor.constraint(equalTo: self.daysStackView.bottomAnchor, constant: Consts.padding),
            self.timeStackView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -Consts.padding),
        ])
        
        NSLayoutConstraint.activate([
            self.summaryLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: Consts.padding),
            self.summaryLabel.topAnchor.constraint(equalTo: self.timeStackView.bottomAnchor, constant: Consts.padding),
            self.summaryLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -Consts.padding),
        ])
        
        NSLayoutConstraint.activate([
            self.summaryContentLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: Consts.padding),
            self.summaryContentLabel.topAnchor.constraint(equalTo: self.summaryLabel.bottomAnchor),
            self.summaryContentLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -Consts.padding),
            self.summaryContentLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
        ])
    }
    
    private func prepareContent() {
        if let imageUrl = self.viewModel.mediumImageUrl, let url = URL(string: imageUrl) {
            self.showImageView.loadImage(url: url)
                .store(in: &cancellables)
        }

        self.titleLabel.text = self.viewModel.name
        self.genreLabel.text = self.viewModel.genres?.joined(separator: ", ")

        self.setupDays()
        self.setupTime()
        self.setupSummary()
    }
    
    private func setupDays() {
        self.daysStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let imageView = UIImageView(image: UIImage(systemName: "calendar"))
        imageView.tintColor = .black
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 24.0),
            imageView.widthAnchor.constraint(equalToConstant: 24.0),
        ])

        self.daysStackView.addArrangedSubview(imageView)
        self.viewModel.days?.forEach { day in
            let translated = self.translateDay(day)
            let chipView = ChipView(title: translated)
            
            self.daysStackView.addArrangedSubview(chipView)
        }

        if (self.viewModel?.days?.count ?? 0) < 5 {
            let filler = UILabel(frame: .zero)
            filler.text = " "
            self.daysStackView.addArrangedSubview(filler)
        } else {
            self.daysStackView.distribution = .fillProportionally
        }
    }

    private func setupTime() {
        self.timeStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let imageView = UIImageView(image: UIImage(systemName: "clock"))
        imageView.tintColor = .black
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 24.0),
            imageView.widthAnchor.constraint(equalToConstant: 24.0),
        ])

        let chipView = ChipView(title: self.viewModel.time ?? "")
        chipView.translatesAutoresizingMaskIntoConstraints = false
        
        let filler = UILabel(frame: .zero)
        filler.text = " "
        
        self.timeStackView.addArrangedSubview(imageView)
        self.timeStackView.addArrangedSubview(chipView)
        self.timeStackView.addArrangedSubview(filler)
    }
    
    private func translateDay(_ day: String) -> String {
        switch day {
        case "Monday": return "Mon"
        case "Tuesday": return "Tue"
        case "Wednesday": return "Wed"
        case "Thursday": return "Thu"
        case "Friday": return "Fri"
        case "Saturday": return "Sat"
        case "Sunday": return "Sun"
        default: return ""
        }
    }
    
    private func setupSummary() {
        self.summaryContentLabel.attributedText = .templatedHtml(self.viewModel.summary ?? "<em>No summary</em>")
    }

}
