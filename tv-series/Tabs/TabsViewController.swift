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
        
        let listTab = UITabBarItem(title: "Shows",
                                   image: UIImage(systemName: "tv"),
                                   selectedImage: UIImage(systemName: "tv.fill"))
        let listVC = ShowsListViewController()
        let navVC = UINavigationController(rootViewController: listVC)
        navVC.tabBarItem = listTab
        
        let favoriteTab = UITabBarItem(title: "Favorites",
                                   image: UIImage(systemName: "heart"),
                                   selectedImage: UIImage(systemName: "heart.fill"))
        let favoriteVC = FavoriteListViewController()
        let favoriteNavVC = UINavigationController(rootViewController: favoriteVC)
        favoriteNavVC.tabBarItem = favoriteTab
        
        let settingsTab = UITabBarItem(title: "Settings",
                                   image: UIImage(systemName: "gearshape"),
                                   selectedImage: UIImage(systemName: "gearshape.fill"))
        let settingsVC = SettingsViewController()
        let settingsNavVC = UINavigationController(rootViewController: settingsVC)
        settingsNavVC.tabBarItem = settingsTab

        self.tabBar.backgroundColor = .systemGroupedBackground
        self.tabBar.isTranslucent = false
        self.tabBar.tintColor = UIColor(hex: "#242424")
        self.viewControllers = [ navVC, favoriteNavVC, settingsNavVC ]
        
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
    
    private func showLock() {
        let viewModel = PinViewModel(isSetup: false)
        let vc = PinViewController(viewModel: viewModel)
        vc.modalPresentationStyle = .fullScreen
        
        vc.onClose = { [ weak self ] status in
            guard status == .unlocked else { return }
            self?.viewModel.unlocked()
        }
        
        self.present(vc, animated: true)
    }

}
