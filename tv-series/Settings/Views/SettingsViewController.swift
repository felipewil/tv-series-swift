//
//  SettingsViewController.swift
//  tv-series
//
//  Created by Felipe Leite on 25/12/22.
//

import UIKit

class SettingsViewController: UIViewController {

    private struct Consts {
        static let estimatedRowSize: CGFloat = 44.0
    }
    
    private enum Section: Int {
        case list
    }
    
    private enum Identifiers: Int {
        case empty = -1
    }

    // MARK: Properties

    private let viewModel = SettingsViewModel()
    private var dataSource: UITableViewDiffableDataSource<Section, Int>?

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

        return tableView
    }()
    
    // MARK: Public methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "Settings"
        self.setup()
        self.dataSource = makeDataSource()
        self.dataSource?.defaultRowAnimation = .fade
        self.tableView.dataSource = self.dataSource
        self.loadSettings()
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
    
    private func makeDataSource() -> UITableViewDiffableDataSource<Section, Int> {
        return UITableViewDiffableDataSource(tableView: self.tableView) { tableView, indexPath, itemIdentifier in
            let settings = self.viewModel.settings(at: indexPath.row)
            let cell = UITableViewCell()
            cell.selectionStyle = settings.canSelect ? .default : .none
            
            var config = cell.defaultContentConfiguration()
            
            config.text = settings.title
            
            cell.contentConfiguration = config
            
            return cell
        }
    }
    
    private func loadSettings() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()

        snapshot.appendSections([ .list ])
        snapshot.appendItems(self.viewModel.settings().map { $0.rawValue }, toSection: .list)

        self.dataSource?.apply(snapshot)
    }

}

// MARK: -

extension SettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        guard
//            let identifier = self.dataSource?.itemIdentifier(for: indexPath),
//            let show = self.viewModel.show(withID: identifier) else { return }
//
//        let detailsViewModel = ShowDetailsViewModel(show: show)
//        let detailsVC = ShowDetailsViewController(viewModel: detailsViewModel)
//
//        self.navigationController?.pushViewController(detailsVC, animated: true)
    }

}