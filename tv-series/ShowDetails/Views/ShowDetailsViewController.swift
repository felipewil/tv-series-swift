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
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ShowDetailsCell.self, forCellReuseIdentifier: ShowDetailsCell.reuseIdentifier)

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
        self.tableView.dataSource = self.dataSource
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([ .details ])
        snapshot.appendItems([ 0 ])
        
        self.dataSource?.apply(snapshot)
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
                
            }
            
            return LoadingCell.dequeueReusableCell(from: tableView, for: indexPath)
        }
    }

}

// MARK: -

extension ShowDetailsViewController: UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scroll", scrollView.contentOffset)
        
        self.title = scrollView.contentOffset.y > 72.0 ? self.viewModel.name : nil
    }

}
