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
    func updateNavigationColor(color: UIColor) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError()
        }
        let contrastColor = ContrastColorOf(color, returnFlat: true)
        navBar.barTintColor = color
        navBar.tintColor = contrastColor
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: contrastColor]
        navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: contrastColor]
    }
}
