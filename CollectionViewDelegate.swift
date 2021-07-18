//
//  CollectionViewDelegate.swift
//  Jabama
//
//  Created by Saeed on 6/5/20.
//  Copyright © 2020 Jabama. All rights reserved.
//

import UIKit

final class CollectionViewDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var delegate: CollectionViewProtocol!
    
    private func calculate() -> Set<IndexPath> {
        guard let paths = Calcutator.calculateIndexPaths(delegate: delegate) else {
            fatalError()
        }
        return paths
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let month = delegate.dataSource[indexPath.section]
        
        if month.startWeekDay > indexPath.row {
            return
        }
        
        var itemsIndexPath = Set<IndexPath>()
        let date = month.days[indexPath.row - month.startWeekDay]
        
        guard Calcutator.getSelectionStatus(for: date, delegate: delegate) != .disabled else {
            return
        }
        
        if delegate.fromDate == nil {
            delegate.fromDate = date
            itemsIndexPath.insert(indexPath)
        } else if delegate.toDate == nil {
            guard let from = delegate.fromDate else {
                return
            }
            
            let max = from > date ? from : date
            let min = from < date ? from : date
            
            delegate.fromDate = min
            delegate.toDate = max
            
            itemsIndexPath = calculate()
        } else {
            itemsIndexPath = calculate()
            itemsIndexPath.insert(indexPath)
            
            delegate.fromDate = date
            delegate.toDate = nil
        }
        
        collectionView.performBatchUpdates({
            collectionView.reloadItems(at: itemsIndexPath.sorted())
            collectionView.layoutIfNeeded()
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = Int(collectionView.bounds.width/7.0)
        return CGSize(width: width, height: width)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let width = Int(collectionView.bounds.width/7.0)
        let padding = (collectionView.bounds.width-CGFloat(width*7))/2.0
        return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
    }
}
