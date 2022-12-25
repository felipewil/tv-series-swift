//
//  TabsViewController.swift
//  tv-series
//
//  Created by Felipe Leite on 24/12/22.
//

import UIKit

class TabsViewController: UITabBarController {

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

        self.tabBar.backgroundColor = .systemGroupedBackground
        self.tabBar.isTranslucent = false
        self.tabBar.tintColor = UIColor(hex: "#242424")
        self.viewControllers = [ navVC, favoriteNavVC ]
    }

}
