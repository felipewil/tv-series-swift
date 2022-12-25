//
//  FavoriteListViewController.swift
//  tv-series
//
//  Created by Felipe Leite on 24/12/22.
//

import UIKit
import Combine

class FavoriteListViewController: UIViewController {

    private struct Consts {
        static let estimatedRowSize: CGFloat = 128.0
    }
    
    private enum Section: Int {
        case list
    }
    
    private enum Identifiers: Int {
        case emptySearch = -1
        case loadingSearch = -2
        case loadingMore = -3
    }

    // MARK: Properties

    private let viewModel = FavoriteListViewModel()
    private var dataSource: UITableViewDiffableDataSource<Section, Show.ID>?
    private var cancellables: Set<AnyCancellable> = []

    // MARK: Subviews
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)

        // Hiding top distance between nav bar and table view
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: CGFloat.leastNormalMagnitude))
        tableView.sectionHeaderTopPadding = 0.0
        tableView.sectionHeaderHeight = 0.0
        tableView.sectionFooterHeight = 6.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Consts.estimatedRowSize
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(LoadingCell.self, forCellReuseIdentifier: LoadingCell.reuseIdentifier)
        tableView.register(ShowCell.self, forCellReuseIdentifier: ShowCell.reuseIdentifier)

        return tableView
    }()
    
    lazy var searchController = UISearchController()
    
    // MARK: Public methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "Favorites"
        self.setup()
        self.dataSource = makeDataSource()
        self.dataSource?.defaultRowAnimation = .fade
        self.tableView.dataSource = self.dataSource

        self.viewModel.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [ weak self ] event in self?.handleListEvent(event) }
            .store(in: &self.viewModel.cancellables)
        
        self.viewModel.$isLoading
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [ weak self ] isLoading in self?.showLoading(isLoading) }
            .store(in: &self.cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewModel.loadFavorites()
    }

    // MARK: Helpers
    
    private func setup() {
        self.view.addSubview(self.tableView)
        
        self.searchController.searchResultsUpdater = self
        self.navigationItem.searchController = searchController
        
        NSLayoutConstraint.activate([
            self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func makeDataSource() -> UITableViewDiffableDataSource<Section, Show.ID> {
        return UITableViewDiffableDataSource(tableView: self.tableView) { tableView, indexPath, itemIdentifier in
            if indexPath.section == Section.list.rawValue {
                if itemIdentifier == Identifiers.loadingMore.rawValue {
                    return LoadingCell.dequeueReusableCell(from: tableView, description: "Loading favorites", for: indexPath)
                }

                let show = self.viewModel.show(at: indexPath.row)
                let viewModel = ShowCellViewModel(show: show)
                return ShowCell.dequeueReusableCell(from: tableView, viewModel: viewModel, for: indexPath)
            }
            
            return LoadingCell.dequeueReusableCell(from: tableView, for: indexPath)
        }
    }

    private func handleListEvent(_ event: FavoriteListEvent) {
        switch event {
        case .showsUpdated:
            var snapshot = NSDiffableDataSourceSnapshot<Section, Show.ID>()

            snapshot.appendSections([ .list ])
            snapshot.appendItems(self.viewModel.showsIDs(), toSection: .list)

            self.dataSource?.apply(snapshot)
        }
    }
    
    private func showLoading(_ show: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Show.ID>()

        snapshot.appendSections([ .list ])
        snapshot.appendItems(self.viewModel.showsIDs())
        snapshot.appendItems([ Identifiers.loadingMore.rawValue ])

        self.dataSource?.apply(snapshot)
    }

}

// MARK: -

extension FavoriteListViewController: UISearchControllerDelegate, UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        if searchController.isActive {
            let search = searchController.searchBar.text
            self.viewModel.searchShows(for: search)
        } else {
            self.viewModel.searchCancelled()
        }
    }

}

// MARK: -

extension FavoriteListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard
            let identifier = self.dataSource?.itemIdentifier(for: indexPath),
            let show = self.viewModel.show(withID: identifier) else { return }
        
        let detailsViewModel = ShowDetailsViewModel(show: show)
        let detailsVC = ShowDetailsViewController(viewModel: detailsViewModel)
        
        self.navigationController?.pushViewController(detailsVC, animated: true)
    }

}
