//
//  PinSettingsViewController.swift
//  tv-series
//
//  Created by Felipe Leite on 25/12/22.
//

import UIKit
import Combine

class PinSettingsViewController: UIViewController {

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

    private let viewModel = PinSettingsViewModel()
    private var dataSource: UITableViewDiffableDataSource<Section, Int>?
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
        tableView.translatesAutoresizingMaskIntoConstraints = false

        return tableView
    }()
    
    // MARK: Public methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "PIN"
        self.setup()
        self.dataSource = makeDataSource()
        self.dataSource?.defaultRowAnimation = .fade
        self.tableView.dataSource = self.dataSource
        self.loadSettings()
        
        self.viewModel.eventPublisher
            .sink(receiveValue: self.handleEvent)
            .store(in: &self.cancellables)
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
            let settings = self.viewModel.options[indexPath.row]
            let cell = UITableViewCell()
            var config = cell.defaultContentConfiguration()
            
            config.text = settings.title
            cell.accessoryView = nil
            cell.selectionStyle = .none

            if settings == .pin {
                self.preparePinCell(cell)
            } else if settings == .fingerprint {
                config.textProperties.color = self.viewModel.isPinEnabled() ? UIColor.label : UIColor.systemGray
            }
            
            cell.contentConfiguration = config
            
            return cell
        }
    }

    private func loadSettings() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()

        snapshot.appendSections([ .list ])
        snapshot.appendItems(self.viewModel.options.map { $0.rawValue }, toSection: .list)

        self.dataSource?.apply(snapshot)
    }
    
    private func reloadSettings() {
        guard var snapshot = self.dataSource?.snapshot() else { return }

        snapshot.reloadItems(self.viewModel.options.map { $0.rawValue })

        self.dataSource?.apply(snapshot)
    }
    
    private func preparePinCell(_ cell: UITableViewCell) {
        let switchView = UISwitch(frame: .zero)
        switchView.addTarget(self, action: #selector(self.pinEnabled), for: .valueChanged)
        switchView.isOn = self.viewModel.isPinEnabled()
        
        cell.accessoryView = switchView
    }

    @objc private func pinEnabled(_ sender: UISwitch) {
        self.viewModel.pinEnabled(sender.isOn)
        self.reloadSettings()
    }
    
    private func handleEvent(_ event: PinSettingsEvent) {
        switch event {
        case .setupPin:
            let viewModel = PinViewModel(isSetup: true)
            let vc = PinViewController(viewModel: viewModel)
            vc.modalPresentationStyle = .fullScreen
            vc.onClose = { status in
                if status == .unlocked {
                    self.viewModel.confirmPinEnabled()
                }
                
                self.reloadSettings()
            }
            
            self.present(vc, animated: true)
        }
    }

}
