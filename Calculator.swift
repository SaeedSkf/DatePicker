//
//  Calculator.swift
//  Jabama
//
//  Created by Saeed on 6/6/20.
//  Copyright © 2020 Jabama. All rights reserved.
//

import Foundation

struct Calcutator {
    
    static func startWeekDayNumber(calendar: Calendar, date: Date) -> Int {
        let startWeekDay = calendar.component(.weekday, from: date)
        return startWeekDay == 7 ? 0 : startWeekDay
    }
    
    private static func getStatus(_ date: Date, delegate: CollectionViewProtocol) -> SelectionStatus {
        func checkStatus(from: Date?, to: Date?) -> SelectionStatus {
            if from == date {
                return .start
            } else if to == date {
                return .end
            } else {
                return .none
            }
        }
        
        guard let from = delegate.fromDate, let to = delegate.toDate else {
            return checkStatus(from: delegate.fromDate, to: delegate.toDate)
        }
        
        let max = from > to ? from : to
        let min = from < to ? from : to
        
        if min < date , date < max {
            return .middle
        } else {
            return checkStatus(from: min, to: max)
        }
    }
    
    static func getSelectionStatus(for date: Date, delegate: CollectionViewProtocol) -> SelectionStatus {
        let now = Date()
        let result = delegate.calendar.compare(now, to: date, toGranularity: .day)
        switch result {
        case .orderedAscending, .orderedSame:
            return getStatus(date, delegate: delegate)
        case .orderedDescending:
            return .disabled
        }
    }
    
    static func getIndexPath(delegate: CollectionViewProtocol, from date: Date) -> IndexPath? {
        guard let topData = delegate.dataSource.first?.days.first else {
            return nil
        }
        
        let year = delegate.calendar.component(.year, from: topData)
        let month = delegate.calendar.component(.month, from: topData)
        
        guard let topDate = delegate.calendar.date(from: DateComponents(year: year, month: month)) else {
            return nil
        }
        
        let components = delegate.calendar.dateComponents([.month, .day], from: topDate, to: date)
        guard let section = components.month, let row = components.day else {
            return nil
        }
        
        let component = delegate.calendar.dateComponents([.year, .month], from: date)
        let startOfMonth = delegate.calendar.date(from: component)!
        let startWeekDay = startWeekDayNumber(calendar: delegate.calendar, date: startOfMonth)
        
        return IndexPath(row: row+startWeekDay, section: section)
    }
    
    static func calculateIndexPaths(delegate: CollectionViewProtocol) -> Set<IndexPath>? {
        guard let from = delegate.fromDate, let to = delegate.toDate else {
            return nil
        }
        
        let max = from > to ? from : to
        var min = from < to ? from : to
        
        var indexPaths = Set<IndexPath>()
        while (min <= max) {
            let indexPath = getIndexPath(delegate: delegate, from: min)!
            indexPaths.insert(indexPath)
            min = delegate.calendar.date(byAdding: .day, value: 1, to: min)!
        }
        
        return indexPaths
    }
}
