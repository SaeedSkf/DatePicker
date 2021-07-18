//
//  CollectionViewDataSource.swift
//  Jabama
//
//  Created by Saeed on 6/5/20.
//  Copyright © 2020 Jabama. All rights reserved.
//

import UIKit

final class CollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    var delegate: CollectionViewProtocol!
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        delegate.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let model = delegate.dataSource[section]
        return model.days.count + model.startWeekDay
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = delegate.dataSource[indexPath.section]
        if model.startWeekDay <= indexPath.row {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: delegate.cellIdentifier, for: indexPath) as! SSDatePickerDayCell
            
            let date = model.days[indexPath.row - model.startWeekDay]
            let status = Calcutator.getSelectionStatus(for: date, delegate: delegate)
            cell.configure(date: date, calendar: delegate.calendar, status: status)
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
            cell.backgroundColor = .clear
            
            return cell
        }
    }
    
    // MARK - Reusable Views
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: delegate.headerIdentifier, for: indexPath) as! SSDatePickerReusableView
        
        if let date = delegate.dataSource[indexPath.section].days.first {
            view.configure(startDate: date, calendar: delegate.calendar)
        }
        
        return view
    }
    
}
