//
//  SeriesListViewController.swift
//  tv-series
//
//  Created by Felipe Leite on 23/12/22.
//

import UIKit
import Combine

class ShowsListViewController: UIViewController {

    private struct Consts {
        static let estimatedRowSize: CGFloat = 128.0
    }
    
    private enum Section: Int {
        case list
        case search
    }
    
    private enum Identifiers: Int {
        case emptySearch = -1
        case loadingSearch = -2
        case loadingMore = -3
    }

    // MARK: Properties

    private var viewModel: ShowsListViewModel!
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
    
    // MARK: Initializations
    
    init(viewModel: ShowsListViewModel = ShowsListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: Public methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "Shows"
        self.setup()
        self.dataSource = makeDataSource()
        self.dataSource?.defaultRowAnimation = .fade
        self.tableView.dataSource = self.dataSource

        self.viewModel.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [ weak self ] event in self?.handleShowsListEvent(event) }
            .store(in: &self.viewModel.cancellables)
        
        self.viewModel.$isLoading
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [ weak self ] isLoading in self?.showLoading(isLoading) }
            .store(in: &self.cancellables)

        DispatchQueue.main.async {
            self.showLoading(true, animated: false)
            self.viewModel.loadNextPage()
        }
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
                    return LoadingCell.dequeueReusableCell(from: tableView, description: "Loading more shows", for: indexPath)
                }

                let show = self.viewModel.show(at: indexPath.row)
                let viewModel = ShowCellViewModel(show: show)
                let cell = ShowCell.dequeueReusableCell(from: tableView, viewModel: viewModel, for: indexPath)
                
                cell.eventPublisher
                    .sink { self.handleShowCellEvent($0, at: indexPath )}
                    .store(in: &cell.cancellables)

                return cell
            } else if indexPath.section == Section.search.rawValue {
                if itemIdentifier == Identifiers.emptySearch.rawValue {
                    let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                    var configuration = cell.defaultContentConfiguration()

                    configuration.text = "Type a show name"
                    configuration.textProperties.alignment = .center
                    
                    cell.contentConfiguration = configuration
                    cell.selectionStyle = .none
                    
                    return cell
                } else if itemIdentifier == Identifiers.loadingSearch.rawValue {
                    return LoadingCell.dequeueReusableCell(from: tableView, description: "Searching", for: indexPath)
                }

                let show = self.viewModel.show(at: indexPath.row)
                let viewModel = ShowCellViewModel(show: show)
                let cell = ShowCell.dequeueReusableCell(from: tableView, viewModel: viewModel, for: indexPath)

                cell.eventPublisher
                    .sink { self.handleShowCellEvent($0, at: indexPath )}
                    .store(in: &cell.cancellables)

                return cell
            }
            
            return LoadingCell.dequeueReusableCell(from: tableView, for: indexPath)
        }
    }

    private func handleShowsListEvent(_ event: ShowsListEvent) {
        switch event {
        case .showsUpdated:
            var snapshot = NSDiffableDataSourceSnapshot<Section, Show.ID>()

            snapshot.appendSections([ .list, .search ])
            snapshot.appendItems(self.viewModel.showsIDs(), toSection: .list)

            self.dataSource?.apply(snapshot)
        case .showsSearched:
            var snapshot = NSDiffableDataSourceSnapshot<Section, Show.ID>()

            snapshot.appendSections([ .list, .search ])
            snapshot.appendItems(self.viewModel.searchResults.ids(), toSection: .search)
            
            if self.viewModel.searchResults.count == 0 {
                snapshot.appendItems([ Identifiers.emptySearch.rawValue ], toSection: .search)
            }

            self.dataSource?.apply(snapshot)
        case .reloadShow(let id):
            guard
                var snapshot = self.dataSource?.snapshot(),
                snapshot.indexOfItem(id) != nil else { return }

            snapshot.reconfigureItems([ id ])
            
            self.dataSource?.apply(snapshot, animatingDifferences: false)
        }
    }
    
    private func handleShowCellEvent(_ event: ShowCellEvent, at indexPath: IndexPath) {
        switch event {
        case .favoriteChanged:
            self.viewModel.showFavoritedChanged(at: indexPath.row)
        }
    }
    
    private func showLoading(_ show: Bool, animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Show.ID>()

        snapshot.appendSections([ .list ])
        snapshot.appendItems(self.viewModel.showsIDs())
        snapshot.appendItems([ Identifiers.loadingMore.rawValue ])

        self.dataSource?.apply(snapshot, animatingDifferences: animated)
    }

}

// MARK: -

extension ShowsListViewController: UISearchControllerDelegate, UISearchResultsUpdating {

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

extension ShowsListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.section == Section.list.rawValue,
              indexPath.row > self.viewModel.numberOfShows() - 3,
              self.viewModel.hasMoreShows() else { return }

        self.viewModel.loadNextPage()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let show = self.viewModel.show(at: indexPath.row)
        let detailsViewModel = ShowDetailsViewModel(show: show)
        let detailsVC = ShowDetailsViewController(viewModel: detailsViewModel)
        
        self.navigationController?.pushViewController(detailsVC, animated: true)
    }

}
