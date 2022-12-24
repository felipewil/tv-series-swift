//
//  ShowDetailsViewController.swift
//  tv-series
//
//  Created by Felipe Leite on 24/12/22.
//

import Foundation
import UIKit
import Combine

class ShowDetailsViewController: UIViewController {
    
    private struct Consts {
        static let padding: CGFloat = 16.0
        static let imageSize: CGFloat = 96.0
        static let titleFontSize: CGFloat = 28.0
        static let subtitleFontSize: CGFloat = 18.0
        static let bodyFontSize: CGFloat = 15.0
    }
    
    private enum Section: Int {
        case details
        case season
        case episodes
    }
    
    private enum Identifier: Int {
        case details = -1
        case seasons = -2
    }

    // MARK: Properties
    
    private let viewModel: ShowDetailsViewModel!
    private var dataSource: UITableViewDiffableDataSource<Section, Int>?
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: Subviews
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)

        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.sectionHeaderTopPadding = 0.0
        tableView.sectionFooterHeight = 0.0
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(EpisodeCell.self, forCellReuseIdentifier: EpisodeCell.reuseIdentifier)
        tableView.register(LoadingCell.self, forCellReuseIdentifier: LoadingCell.reuseIdentifier)
        tableView.register(ShowDetailsCell.self, forCellReuseIdentifier: ShowDetailsCell.reuseIdentifier)
        tableView.register(SeasonsCell.self, forCellReuseIdentifier: SeasonsCell.reuseIdentifier)

        return tableView
    }()
    
    // MARK: Initialization
    
    init(viewModel: ShowDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        self.setup()
    }

    required init?(coder: NSCoder) {
        self.viewModel = nil
        super.init(coder: coder)
    }

    // MARK: Public methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = makeDataSource()
        self.dataSource?.defaultRowAnimation = .fade
        self.tableView.dataSource = self.dataSource

        self.viewModel.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: self.handleEvent)
            .store(in: &cancellables)

        self.loadDetails()
        self.viewModel.loadEpisodes()
    }

    // MARK: Helpers
    
    private func setup() {
        self.view.backgroundColor = .white
        self.view.addSubview(self.tableView)
        
        NSLayoutConstraint.activate([
            self.tableView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.tableView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func makeDataSource() -> UITableViewDiffableDataSource<Section, Int> {
        return UITableViewDiffableDataSource(tableView: self.tableView) { tableView, indexPath, itemIdentifier in
            if indexPath.section == Section.details.rawValue {
                let viewModel = ShowDetailsCellViewModel(show: self.viewModel.show)
                return ShowDetailsCell.dequeueReusableCell(from: tableView, viewModel: viewModel, for: indexPath)
            } else if indexPath.section == Section.season.rawValue {
                let cell = SeasonsCell.dequeueReusableCell(from: tableView, seasons: self.viewModel.seasons(), for: indexPath)

                cell.eventPublisher
                    .sink(receiveValue: self.handleSeasonsEvent)
                    .store(in: &cell.cancellables)

                return cell
            } else if indexPath.section == Section.episodes.rawValue {
                let episode = self.viewModel.episode(at: indexPath.row)
                let viewModel = EpisodeCellViewModel(episode: episode)
                return EpisodeCell.dequeueReusableCell(from: tableView, viewModel: viewModel, for: indexPath)
            }
            
            return LoadingCell.dequeueReusableCell(from: tableView, for: indexPath)
        }
    }
    
    private func handleEvent(_ event: ShowDetailsViewModelEvent) {
        switch event {
        case .episodesUpdated:
            var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
            snapshot.appendSections([ .details, .season, .episodes ])
            snapshot.appendItems([ Identifier.details.rawValue ], toSection: .details)
            snapshot.appendItems([ Identifier.seasons.rawValue ], toSection: .season)

            if let eps = self.viewModel.episodesBySeason[self.viewModel.selectedSeason] {
                snapshot.appendItems(eps.map { $0.id }, toSection: .episodes)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.dataSource?.apply(snapshot)
            }
        }
    }
    
    private func handleSeasonsEvent(_ event: SeasonsCellEvent) {
        switch event {
        case .seasonSelected(let index):
            self.viewModel.seasonSelected(at: index)
        }
    }
    
    private func loadDetails() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([ .details ])
        snapshot.appendItems([ Identifier.details.rawValue ])
        
        self.dataSource?.apply(snapshot)
    }

}

// MARK: -

extension ShowDetailsViewController: UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scroll", scrollView.contentOffset)
        
        self.title = scrollView.contentOffset.y > 72.0 ? self.viewModel.name : nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard
            let identifier = self.dataSource?.itemIdentifier(for: indexPath),
            let episode = self.viewModel.episode(withID: identifier) else { return }

        let detailsViewModel = EpisodeDetailsViewModel(episode: episode)
        let detailsVC = EpisodeDetailsViewController(viewModel: detailsViewModel)

        self.navigationController?.pushViewController(detailsVC, animated: true)
    }

}
