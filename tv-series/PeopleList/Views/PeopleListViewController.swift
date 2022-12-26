//
//  PeopleListViewController.swift
//  tv-series
//
//  Created by Felipe Leite on 26/12/22.
//

import UIKit
import Combine

class PeopleListViewController: UIViewController {

    private struct Consts {
        static let estimatedRowSize: CGFloat = 128.0
    }
    
    private enum Section: Int {
        case header
        case loading
        case list
    }
    
    private enum Identifiers: Int {
        case header = -1
        case loading = -2
    }

    // MARK: Properties

    private let viewModel = PeopleListViewModel()
    private var dataSource: UITableViewDiffableDataSource<Section, People.ID>?
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
        tableView.register(PeopleCell.self, forCellReuseIdentifier: PeopleCell.reuseIdentifier)

        return tableView
    }()
    
    lazy var searchController = UISearchController()
    
    // MARK: Public methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "People"
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
            .sink { [ weak self ] isLoading in self?.handleLoading(isLoading) }
            .store(in: &self.cancellables)

        DispatchQueue.main.async {
            self.handleListEvent(.listUpdated, animated: false)
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
    
    private func makeDataSource() -> UITableViewDiffableDataSource<Section, People.ID> {
        return UITableViewDiffableDataSource(tableView: self.tableView) { tableView, indexPath, itemIdentifier in
            let section = self.dataSource?.sectionIdentifier(for: indexPath.section
)
            if section == .header {
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                var configuration = cell.defaultContentConfiguration()

                configuration.text = self.viewModel.isLoading ? "Searching" : "Type a name to start searching"
                configuration.textProperties.alignment = .center
                
                cell.contentConfiguration = configuration
                cell.selectionStyle = .none
                
                return cell
            }

            let people = self.viewModel.people[indexPath.row]
            let viewModel = PeopleCellViewModel(people: people)

            return PeopleCell.dequeueReusableCell(from: tableView, viewModel: viewModel, for: indexPath)
        }
    }

    private func handleListEvent(_ event: PeopleListEvent, animated: Bool = true) {
        switch event {
        case .listUpdated:
            var snapshot = NSDiffableDataSourceSnapshot<Section, Show.ID>()

            snapshot.appendSections([ .header, .list ])
            snapshot.appendItems([ Identifiers.header.rawValue ], toSection: .header)
            snapshot.appendItems(self.viewModel.people.ids(), toSection: .list)

            self.dataSource?.apply(snapshot, animatingDifferences: animated)
        }
    }
    
    private func handleLoading(_ isLoading: Bool) {
        guard var snapshot = self.dataSource?.snapshot() else { return }

        snapshot.reloadItems([ Identifiers.header.rawValue ])

        self.dataSource?.apply(snapshot)
    }

}

// MARK: -

extension PeopleListViewController: UISearchControllerDelegate, UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        if searchController.isActive {
            let search = searchController.searchBar.text
            self.viewModel.search(for: search)
        } else {
            self.viewModel.search(for: "")
        }
    }

}

// MARK: -

extension PeopleListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let people = self.viewModel.people[indexPath.row]
        let viewModel = PeopleDetailsViewModel(people: people)
        let vc = PeopleDetailsViewController(viewModel: viewModel)

        self.navigationController?.pushViewController(vc, animated: true)
    }

}

