//
//  TabsViewController.swift
//  tv-series
//
//  Created by Felipe Leite on 24/12/22.
//

import UIKit
import Combine

class TabsViewController: UITabBarController {

    // MARK: Properties
    
    private let viewModel = TabsViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: Public methods

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.backgroundColor = .systemGroupedBackground
        self.tabBar.isTranslucent = false
        self.tabBar.tintColor = .label
        self.viewControllers = [
            showsViewController(),
            favoritesViewController(),
            peopleViewController(),
            settingsViewController(),
        ]
        
        self.viewModel.$isLocked
            .dropFirst()
            .sink { isLocked in
                guard isLocked else { return }
                self.showLock()
            }
            .store(in: &self.cancellables)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel.checkIsLocked()
    }

    // MARK: Helpers

    private func showsViewController() -> UIViewController {
        let tab = UITabBarItem(title: "Shows",
                                   image: UIImage(systemName: "tv"),
                                   selectedImage: UIImage(systemName: "tv.fill"))
        let vc = ShowsListViewController()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.tabBarItem = tab
        
        return navVC
    }
    
    private func favoritesViewController() -> UIViewController {
        let tab = UITabBarItem(title: "Favorites",
                                   image: UIImage(systemName: "heart"),
                                   selectedImage: UIImage(systemName: "heart.fill"))
        let vc = FavoriteListViewController()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.tabBarItem = tab
        
        return navVC
    }
    
    private func peopleViewController() -> UIViewController {
        let tab = UITabBarItem(title: "People",
                                   image: UIImage(systemName: "person"),
                                   selectedImage: UIImage(systemName: "person.fill"))
        let vc = PeopleListViewController()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.tabBarItem = tab
        
        return navVC
    }

    private func settingsViewController() -> UIViewController {
        let tab = UITabBarItem(title: "Settings",
                                   image: UIImage(systemName: "gearshape"),
                                   selectedImage: UIImage(systemName: "gearshape.fill"))
        let vc = SettingsViewController()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.tabBarItem = tab
        
        return navVC
    }

    private func showLock() {
        self.viewModel.lock(viewControlelr: self)
    }

}
