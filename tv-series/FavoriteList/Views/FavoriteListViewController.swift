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
        case empty
        case list
    }
    
    private enum Identifiers: Int {
        case empty = -1
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

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit",
                                                                 image: nil,
                                                                 target: self,
                                                                 action: #selector(self.toggleEdit))

        self.viewModel.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [ weak self ] event in self?.handleListEvent(event) }
            .store(in: &self.viewModel.cancellables)
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
        let dataSource = FavoriteDataSource(tableView: self.tableView) { tableView, indexPath, itemIdentifier in
            let section = self.dataSource?.sectionIdentifier(for: indexPath.section)

            if section == Section.list {
                let show = self.viewModel.show(at: indexPath.row)
                let viewModel = ShowCellViewModel(show: show, canFavorite: false)
                return ShowCell.dequeueReusableCell(from: tableView, viewModel: viewModel, for: indexPath)
            }
            
            let cell = UITableViewCell()
            var config = cell.defaultContentConfiguration()
            
            config.text = "No favorites"
            config.textProperties.alignment = .center
            
            cell.contentConfiguration = config
            
            return cell
        }

        dataSource.onDelete = { [ weak self ] id in
            self?.viewModel.removeFavorite(withID: id)
        }

        return dataSource
    }

    private func handleListEvent(_ event: FavoriteListEvent) {
        switch event {
        case .showsUpdated:
            var snapshot = NSDiffableDataSourceSnapshot<Section, Show.ID>()
            let showsIDs = self.viewModel.showsIDs()

            if showsIDs.count == 0 {
                snapshot.appendSections([ .empty ])
                snapshot.appendItems([ Identifiers.empty.rawValue ], toSection: .empty)
            } else {
                snapshot.appendSections([ .list ])
                snapshot.appendItems(showsIDs, toSection: .list)
            }

            self.dataSource?.apply(snapshot)
        }
    }

    @objc private func toggleEdit() {
        UIView.animate(withDuration: 0.3, delay: 0.0) {
            self.tableView.isEditing.toggle()
        }
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
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove favorite"
    }

}

// MARK: -

extension FavoriteListViewController {
 
    private class FavoriteDataSource: UITableViewDiffableDataSource<Section, Show.ID> {

        var onDelete: ((Show.ID) -> Void)?
        
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
        
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            guard let identifier = self.itemIdentifier(for: indexPath) else { return }
            self.onDelete?(identifier)
        }
        
    }

}
