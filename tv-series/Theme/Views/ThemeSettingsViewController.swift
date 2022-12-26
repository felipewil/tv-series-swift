//
//  ThemeSettingsViewController.swift
//  tv-series
//
//  Created by Felipe Leite on 26/12/22.
//

import UIKit
import Combine

class ThemeSettingsViewController: UIViewController {

    private struct Consts {
        static let estimatedRowSize: CGFloat = 44.0
    }
    
    private enum Section: Int {
        case list
    }

    // MARK: Properties

    private let viewModel = ThemeSettingsViewModel()
    private var dataSource: UITableViewDiffableDataSource<Section, String>?
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

        return tableView
    }()
    
    // MARK: Public methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.title = "Theme"
        self.setup()
        self.dataSource = makeDataSource()
        self.dataSource?.defaultRowAnimation = .fade
        self.tableView.dataSource = self.dataSource
        self.loadThemes()
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
    
    private func makeDataSource() -> UITableViewDiffableDataSource<Section, String> {
        return UITableViewDiffableDataSource(tableView: self.tableView) { tableView, indexPath, itemIdentifier in
            let theme = self.viewModel.theme(at: indexPath.row)
            let cell = UITableViewCell()
            cell.accessoryType = self.viewModel.isCurrentTheme(theme) ? .checkmark : .none
            
            var config = cell.defaultContentConfiguration()
            
            config.text = theme.title
            cell.contentConfiguration = config
            
            return cell
        }
    }

    private func loadThemes() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()

        snapshot.appendSections([ .list ])
        snapshot.appendItems(self.viewModel.allThemes().map { $0.rawValue }, toSection: .list)

        self.dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    private func reloadThemes() {
        guard var snapshot = self.dataSource?.snapshot() else { return }

        snapshot.reloadItems(self.viewModel.allThemes().map { $0.rawValue })

        self.dataSource?.apply(snapshot)
    }

}

// MARK: -

extension ThemeSettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.viewModel.themeSelected(at: indexPath.row)
        self.reloadThemes()
    }

}
