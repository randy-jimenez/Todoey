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
        navBar.backgroundColor = color
        navBar.barTintColor = color
        navBar.tintColor = contrastColor
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: contrastColor]
        navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: contrastColor]
    }
}
