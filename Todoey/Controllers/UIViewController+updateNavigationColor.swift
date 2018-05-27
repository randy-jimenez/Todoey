//
//  ColoredNavigationViewController.swift
//  Todoey
//
//  Created by Randy on 5/25/18.
//  Copyright © 2018 Randy Jimenez. All rights reserved.
//

import ChameleonFramework
import UIKit

extension UIViewController {
    func updateNavigationColor(withColor color: UIColor) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError()
        }
        let contrastColor = ContrastColorOf(color, returnFlat: true)

        if contrastColor == UIColor.flatWhite() {
            UIApplication.shared.statusBarStyle = .lightContent
        } else {
            UIApplication.shared.statusBarStyle = .default
        }

        navBar.shadowImage = UIImage()
        navBar.backgroundColor = color
        navBar.barTintColor = color
        navBar.tintColor = contrastColor
        navBar.titleTextAttributes = [.foregroundColor: contrastColor]
        navBar.largeTitleTextAttributes = [.foregroundColor: contrastColor]
    }
}
