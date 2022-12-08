//
//  BatteryTipsViewController.swift
//  CleanerPlus
//
//  Created by Nikita Velichko on 8/22/22.
//

import UIKit

class BatteryTipsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Battery Health Tips"
        prepareTableView()
        prepareNavigationButtons()
    }

    private func prepareTableView() {
        tableView.register(UINib(nibName: "TipsTableViewCell", bundle: .main), forCellReuseIdentifier: "cell")
    }
    
    private func prepareNavigationButtons() {
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: self, action: #selector(exitFlow))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    @objc private func exitFlow() {
        dismiss(animated: true)
    }
}

// MARK: - Table view implementation
extension BatteryTipsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        BatteryTipItem.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = BatteryTipItem.allCases[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let batteryTipCell = cell as? TipsTableViewCell {
            batteryTipCell.configure(item: item)
        }
        return cell
    }
}
