//
//  CalendarManager.swift
//  CleanerPlus
//
//  Created by Nikita Velichko on 8/22/22.
//

import UIKit
import SwiftUI
import EventKit
import Foundation

class CalendarManager: NSObject, ObservableObject {
    
    var calendarEvents: [String: [String]] = [String: [String]]()
    @Published var progressText: String = "please wait..."
    @Published var showLoadingView: Bool = false
    @Published var reloadIndexPath: IndexPath = IndexPath(row: 0, section: Int.max)
    
    private var events: [EKEvent] = [EKEvent]()
    private let eventStore: EKEventStore = EKEventStore()
    
    var selectedEvents: [String] {
        calendarEvents.compactMap { $0.value }
            .filter({ $0.contains(where: { $0.contains("selected") })})
            .flatMap({ $0 }).filter({ $0.contains("selected") })
    }
    
    func event(forId identifier: String, year: String) -> EKEvent? {
        let eventId = identifier.replacingOccurrences(of: "-selected-\(year)", with: "")
        return events.filter { $0.eventIdentifier == eventId }.first(where: { $0.year == year })
    }
    
    func requestCalendarPermission() {
        showLoadingView = true
        eventStore.requestAccess(to: .event) { accessGranted, _ in
            DispatchQueue.main.async {
                if accessGranted { self.fetchEvents() } else {
                    self.showLoadingView = false
                }
            }
        }
    }
    
    func fetchEvents() {
        let fourYearsAgo = Calendar.current.date(byAdding: .year, value: -4, to: Date())!
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let predicate = eventStore.predicateForEvents(withStart: fourYearsAgo, end: yesterday, calendars: nil)
        events = eventStore.events(matching: predicate)
        processEvents()
    }
    
    private func processEvents() {
        let eventsGroup = Dictionary(grouping: events, by: \.year)
        eventsGroup.forEach { year, eventsList in
            if eventsList.count > 0 {
                calendarEvents[year] = eventsList.compactMap { $0.eventIdentifier }
            }
        }
        DispatchQueue.main.async { self.showLoadingView = false }
    }
}

// MARK: - Delete selected events
extension CalendarManager {

    func deleteSelectedEvents(completion: @escaping () -> Void) {
        selectedEvents.forEach { eventId in
            if let year = eventId.components(separatedBy: "-selected-").last,
               let event = event(forId: eventId, year: year) {
                do {
                    try eventStore.remove(event, span: .thisEvent)
                    if let eventIndex = events.firstIndex(of: event) {
                        events.remove(at: eventIndex)
                        var yearlyEvents = calendarEvents[year]
                        yearlyEvents?.removeAll(where: { $0 == eventId })
                        calendarEvents[year] = yearlyEvents
                    }
                    completion()
                } catch { }
            }
        }
    }
}

// MARK: - Event extension
extension EKEvent {
    var year: String {
        startDate.string(format: "yyyy")
    }
}
