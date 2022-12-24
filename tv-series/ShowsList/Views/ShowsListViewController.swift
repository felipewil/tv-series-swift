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

    // MARK: Properties

    private let viewModel = ShowsListViewModel()
    private var dataSource: UITableViewDiffableDataSource<Int, Show>?
    private var cancellables: Set<AnyCancellable> = []

    // MARK: Subviews
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)

        // Hiding top distance between nav bar and table view
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: CGFloat.leastNormalMagnitude))
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Consts.estimatedRowSize
        tableView.register(LoadingCell.self, forCellReuseIdentifier: LoadingCell.reuseIdentifier)
        tableView.register(ShowCell.self, forCellReuseIdentifier: ShowCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        return tableView
    }()
    
    // MARK: Public methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "Shows"
        self.setup()
        self.dataSource = makeDataSource()
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

        self.viewModel.loadNextPage()
    }

    // MARK: Helpers
    
    private func setup() {
        self.view.addSubview(self.tableView)
        
        NSLayoutConstraint.activate([
            self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func makeDataSource() -> UITableViewDiffableDataSource<Int, Show> {
        return UITableViewDiffableDataSource(tableView: self.tableView) { tableView, indexPath, itemIdentifier in
            if indexPath.section == 0 {
                let show = self.viewModel.show(at: indexPath.row)
                let viewModel = ShowCellViewModel(show: show)
                return ShowCell.dequeueReusableCell(from: tableView, viewModel: viewModel, for: indexPath)
            }
            
            return LoadingCell.dequeueReusableCell(from: tableView, for: indexPath)
        }
    }

    private func handleShowsListEvent(_ event: ShowsListEvent) {
        switch event {
        case .showsUpdated:
            var snapshot = NSDiffableDataSourceSnapshot<Int, Show>()

            snapshot.appendSections([ 0 ])
            snapshot.appendItems(self.viewModel.shows)

            self.dataSource?.apply(snapshot)
        }
    }
    
    private func showLoading(_ show: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Show>()

        snapshot.appendSections([ 1 ])
        snapshot.appendItems(self.viewModel.shows)

        self.dataSource?.apply(snapshot)
    }

}

