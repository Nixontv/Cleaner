//
//  CalendarViewController.swift
//  CleanerPlus
//
//  Created by Nikita Velichko on 8/22/22.
//

import UIKit
import Combine

class CalendarViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingStackView: UIStackView!
    @IBOutlet weak var progressLabel: UILabel!
    private let calendarManager: CalendarManager = CalendarManager()
    private var subscriptions: Set<AnyCancellable> = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Old Events"
        registerObservers()
        prepareTableView()
        prepareNavigationButtons()
        calendarManager.requestCalendarPermission()
    }

    private func prepareTableView() {
        tableView.register(UINib(nibName: "CalendarTableViewCell", bundle: .main), forCellReuseIdentifier: "cell")
        tableView.contentInset = .init(top: -20, left: 0, bottom: 0, right: 0)
    }
    
    private func registerObservers() {
        calendarManager.$showLoadingView.sink { [weak self] showLoading in
            self?.loadingStackView.isHidden = !showLoading
            if showLoading == false { self?.tableView.reloadData() }
        }.store(in: &subscriptions)

        calendarManager.$progressText.sink { [weak self] progress in
            self?.progressLabel.text = progress
        }.store(in: &subscriptions)
        
        calendarManager.$reloadIndexPath.sink { [weak self] indexPath in
            if self?.calendarManager.calendarEvents.count ?? 0 > indexPath.section {
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }.store(in: &subscriptions)
    }
    
    private func prepareNavigationButtons() {
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: self, action: #selector(exitFlow))
        navigationItem.rightBarButtonItem = closeButton
        
        let deleteButton = UIBarButtonItem(image: UIImage(systemName: "trash.fill"), style: .done, target: self, action: #selector(deleteSelectedEvents))
        navigationItem.leftBarButtonItem = deleteButton
    }
    
    @objc private func exitFlow() {
        dismiss(animated: true)
    }
    
    @objc private func deleteSelectedEvents() {
        let selectedCount = calendarManager.selectedEvents.count
        if selectedCount == 0 {
            presentAlert(title: "No Events Selected", message: "You must select the events that you want to delete")
        } else {
            presentAlert(title: "Delete Selected Events", message: "Are you sure you want to delete \(selectedCount) selected events?", primaryAction: .Cancel, secondaryAction: .init(title: "Delete", style: .destructive, handler: { _ in
                self.calendarManager.deleteSelectedEvents { [weak self] in
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            }))
        }
    }
}

// MARK: - Table view implementation
extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        calendarManager.calendarEvents.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = Array(calendarManager.calendarEvents.keys.sorted())[section]
        return calendarManager.calendarEvents[key]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let key = Array(calendarManager.calendarEvents.keys.sorted())[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let eventCell = cell as? CalendarTableViewCell, let eventId = calendarManager.calendarEvents[key]?[indexPath.row] {
            eventCell.configure(eventId: eventId, year: key, manager: calendarManager)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = Array(calendarManager.calendarEvents.keys.sorted())[indexPath.section]
        guard let eventId = calendarManager.calendarEvents[key]?[indexPath.row] else { return }
        let selected = "-selected-\(key)"
        if eventId.contains("selected") {
            calendarManager.calendarEvents[key]?[indexPath.row] = eventId.replacingOccurrences(of: selected, with: "")
        } else {
            calendarManager.calendarEvents[key]?[indexPath.row] = "\(eventId)\(selected)"
        }
        calendarManager.reloadIndexPath = indexPath
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
