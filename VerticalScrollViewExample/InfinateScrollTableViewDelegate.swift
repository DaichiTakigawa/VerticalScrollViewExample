//
//  InfinateScrollTableViewDelegate.swift
//  VerticalScrollViewExample
//
//  Created by takigawa on 2021/05/28.
//

import UIKit

protocol InfinateScrollTableViewDelegate: UITableViewDelegate {

    func infinateScrollViewWillLayoutSubviews(view: InfinateScrollTableView)
}
