//
//  ViewController.swift
//  VerticalScrollViewExample
//
//  Created by takigawa on 2021/05/15.
//

import UIKit

class ViewController: UIViewController {

    private var list = Array(0..<30)
    private var isLoading = false

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.separatorStyle = .none
        view.delegate = self
        view.dataSource = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])
        
        
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 1, section: 0), at: .top, animated: false)
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count + 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if 0 < indexPath.row && indexPath.row <= list.count {
            cell.textLabel?.text = String(list[indexPath.row - 1])
        } else {
            let indicator = UIActivityIndicatorView()
            indicator.startAnimating()
            indicator.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(indicator)
            NSLayoutConstraint.activate([
                indicator.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
                indicator.centerYAnchor.constraint(equalTo: cell.centerYAnchor)
            ])
        }
        cell.tag = indexPath.row
        return cell
    }
}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !isLoading {
            if (list.count - indexPath.row) <= 1 {
                isLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
                    list += (list.last! + 1)...(list.last! + 10)
                    tableView.reloadData()
                    isLoading = false
                }
            } else if indexPath.row == 0 {
                isLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
                    list.insert(contentsOf: (list.first! - 10)...(list.first! - 1), at: 0)
                    let cell = tableView.visibleCells[0]
                    let row = cell.tag
                    let initalOffsetY = tableView.getOffsetY(indexPath: IndexPath(row: row, section: 0))
                    tableView.reloadData()
                    tableView.layoutIfNeeded()  // prevent blinks
                    let afterOffsetY = tableView.getOffsetY(indexPath: IndexPath(row: row+10, section: 0))
                    // contentOffsetに直接代入しなければならない、
                    // tableView.setContentOffset( CGPoint(x: 0, y: tableView.contentOffset.y + (afterOffsetY-initalOffsetY)), animated: false)
                    // だと、アニメーションがストップしてしまう。
                    tableView.contentOffset = CGPoint(x: 0, y: tableView.contentOffset.y + (afterOffsetY-initalOffsetY))
                    isLoading = false
                }
            }
        }
    }

}

private extension UITableView {
    func scroll(offsetToBottom: CGFloat) {
        let offsetY = contentSize.height - offsetToBottom
        let offset = CGPoint(x: contentOffset.x, y: offsetY)
        contentOffset = offset
    }
    
    func getOffsetY(indexPath: IndexPath) -> CGFloat {
        let rectOfCellInTableView = rectForRow(at: indexPath)
        // must convert rect in super view
        let rectOfCellInSuperview = convert(rectOfCellInTableView, to: superview)
        return rectOfCellInSuperview.origin.y
    }
}
