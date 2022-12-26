//
//  PeopleDetailsViewController.swift
//  tv-series
//
//  Created by Felipe Leite on 26/12/22.
//

import UIKit
import Combine

class PeopleDetailsViewController: UIViewController {
    
    private struct Consts {
        static let padding: CGFloat = 16.0
        static let headerFontSize: CGFloat = 18.0
    }
    
    private enum Section: Int {
        case details
        case castCredits
        case shows
    }
    
    private enum Identifier: Int {
        case details = -1
        case castCredits = -2
        case loadingCast = -3
        case emptyCast = -4
    }

    // MARK: Properties
    
    private let viewModel: PeopleDetailsViewModel!
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
        tableView.register(PeopleCell.self, forCellReuseIdentifier: PeopleCell.reuseIdentifier)
        tableView.register(LoadingCell.self, forCellReuseIdentifier: LoadingCell.reuseIdentifier)
        tableView.register(ShowCell.self, forCellReuseIdentifier: ShowCell.reuseIdentifier)

        return tableView
    }()
    
    // MARK: Initialization

    init(viewModel: PeopleDetailsViewModel) {
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
        self.viewModel.loadCastCredits()
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
                let viewModel = PeopleCellViewModel(people: self.viewModel.people)
                return PeopleCell.dequeueReusableCell(from: tableView, viewModel: viewModel, for: indexPath)
            } else if indexPath.section == Section.castCredits.rawValue {
                if itemIdentifier == Identifier.castCredits.rawValue {
                    let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                    var configuration = cell.defaultContentConfiguration()

                    configuration.text = "Cast credits"
                    configuration.textProperties.font = .systemFont(ofSize: 22.0, weight: .semibold)
                    
                    cell.contentConfiguration = configuration
                    cell.selectionStyle = .none
                    
                    return cell
                } else if itemIdentifier == Identifier.emptyCast.rawValue {
                    let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                    var configuration = cell.defaultContentConfiguration()

                    configuration.text = "No cast"
                    configuration.textProperties.color = .systemGray
                    
                    cell.contentConfiguration = configuration
                    cell.selectionStyle = .none
                    
                    return cell
                }
                
                return LoadingCell.dequeueReusableCell(from: tableView, description: "Loading cast", for: indexPath)
            }
            
            let show = self.viewModel.shows[indexPath.row]
            let viewModel = ShowCellViewModel(show: show)
            let cell = ShowCell.dequeueReusableCell(from: tableView, viewModel: viewModel, for: indexPath)
            
            cell.eventPublisher
                .sink { self.handleShowCellEvent($0, at: indexPath )}
                .store(in: &cell.cancellables)
            
            return cell
        }
    }
    
    private func handleEvent(_ event: PeopleDetailsViewModelEvent) {
        switch event {
        case .detailsUpdated:
            var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
            let showsIDs = self.viewModel.shows.ids()
            
            snapshot.appendSections([ .details, .castCredits, .shows ])
            snapshot.appendItems([ Identifier.details.rawValue ], toSection: .details)
            snapshot.appendItems([ Identifier.castCredits.rawValue ], toSection: .castCredits)
            snapshot.appendItems(showsIDs, toSection: .shows)
            
            if showsIDs.count == 0 {
                snapshot.appendItems([ Identifier.emptyCast.rawValue ], toSection: .castCredits)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.dataSource?.apply(snapshot)
            }
        case .reloadShow(let id):
            guard
                var snapshot = self.dataSource?.snapshot(),
                snapshot.indexOfItem(id) != nil else { return }

            snapshot.reconfigureItems([ id ])

            self.dataSource?.apply(snapshot, animatingDifferences: false)
        }
    }
    
    private func loadDetails() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([ .details, .castCredits ])
        snapshot.appendItems([ Identifier.details.rawValue ], toSection: .details)
        snapshot.appendItems([ Identifier.castCredits.rawValue, Identifier.loadingCast.rawValue ],
                             toSection: .castCredits)
        
        self.dataSource?.apply(snapshot)
    }
    
    private func handleShowCellEvent(_ event: ShowCellEvent, at indexPath: IndexPath) {
        switch event {
        case .favoriteChanged:
            self.viewModel.showFavoritedChanged(at: indexPath.row)
        }
    }

}

// MARK: -

extension PeopleDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let show = self.viewModel.shows[indexPath.row]
        let detailsViewModel = ShowDetailsViewModel(show: show)
        let detailsVC = ShowDetailsViewController(viewModel: detailsViewModel)

        self.navigationController?.pushViewController(detailsVC, animated: true)
    }

}
