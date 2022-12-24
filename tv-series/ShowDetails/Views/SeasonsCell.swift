//
//  SeasonsCell.swift
//  tv-series
//
//  Created by Felipe Leite on 24/12/22.
//

import UIKit
import Combine

enum SeasonsCellEvent {
    case seasonSelected(index: Int)
}

class SeasonsCell: UITableViewCell {
    
    private struct Consts {
        static let padding: CGFloat = 16.0
        static let titleFontSize: CGFloat = 18.0
    }

    // MARK: Properties
    
    static let reuseIdentifier = "SeasonsCell"
    private var viewModel: ShowDetailsCellViewModel!
    private let eventSubject = PassthroughSubject<SeasonsCellEvent, Never>()

    var eventPublisher: AnyPublisher<SeasonsCellEvent, Never> {
        return self.eventSubject.eraseToAnyPublisher()
    }
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: Subviews
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()

        label.text = "Seasons"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: Consts.titleFontSize, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    lazy var seasonsStackView: UIStackView = {
        let view = UIStackView()

        view.spacing = 3.0
        view.distribution = .fill
        view.axis = .horizontal
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        return scrollView
    }()
    
    lazy var scrollViewContainer: UIView = {
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
    
    // MARK: Public methods
    
    static func dequeueReusableCell(from tableView: UITableView, seasons: [ Int ], for indexPath: IndexPath) -> SeasonsCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as! SeasonsCell

        cell.prepareContent(seasons: seasons)

        return cell
    }
    
    override func prepareForReuse() {
        self.cancellables = []
    }
    
    // MARK: Helpers
    
    private func setup() {
        self.selectionStyle = .none
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.scrollView)
        self.scrollView.addSubview(self.scrollViewContainer)
        self.scrollViewContainer.addSubview(self.seasonsStackView)
        
        NSLayoutConstraint.activate([
            self.titleLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: Consts.padding),
            self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: Consts.padding),
            self.titleLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -Consts.padding),
        ])

        NSLayoutConstraint.activate([
            self.scrollView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor),
            self.scrollView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: Consts.padding),
            self.scrollView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -Consts.padding),
            self.scrollView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -Consts.padding),
        ])
        
        NSLayoutConstraint.activate([
            self.scrollViewContainer.leftAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leftAnchor),
            self.scrollViewContainer.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
            self.scrollViewContainer.rightAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.rightAnchor),
            self.scrollViewContainer.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
            // Scrolling horizontally only
            self.scrollViewContainer.topAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.topAnchor),
            self.scrollViewContainer.bottomAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            self.seasonsStackView.topAnchor.constraint(equalTo: self.scrollViewContainer.topAnchor),
            self.seasonsStackView.leftAnchor.constraint(equalTo: self.scrollViewContainer.leftAnchor),
            self.seasonsStackView.rightAnchor.constraint(equalTo: self.scrollViewContainer.rightAnchor),
            self.seasonsStackView.bottomAnchor.constraint(equalTo: self.scrollViewContainer.bottomAnchor),
        ])
    }

    private func prepareContent(seasons: [ Int ]) {
        self.seasonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        seasons.enumerated().forEach { (index, season) in
            let view = ChipButtonView(title: "\(season)")
            view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalToConstant: 50.0)
            ])
            
            if index == 0 {
                view.isSelected = true
            }

            view.addTarget(self, action: #selector(seasonTapped(_:)), for: .touchUpInside)

            self.seasonsStackView.addArrangedSubview(view)
        }
    }
    
    @objc private func seasonTapped(_ chipView: ChipButtonView) {
        guard let selectedIndex = self.seasonsStackView.arrangedSubviews.firstIndex(where: { $0 === chipView }) else { return }

        UIView.animate(withDuration: 0.15, delay: 0.0) {
            self.seasonsStackView.arrangedSubviews.enumerated().forEach { (index, view) in
                guard let chip = view as? ChipButtonView else { return }
                chip.isSelected = index == selectedIndex
            }
        }

        self.eventSubject.send(.seasonSelected(index: selectedIndex))
    }

}
