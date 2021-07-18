//
//  JabamaCalendarView.swift
//  Jabama
//
//  Created by Saeed on 6/5/20.
//  Copyright © 2020 Jabama. All rights reserved.
//

import UIKit

public enum SelectionStatus {
    case none, disabled, start, middle, end
}

protocol CollectionViewProtocol {
    var dataSource: [Month] { get set }
    var fromDate: Date? { get set }
    var toDate: Date? { get set }
    var calendar: Calendar { get }
    var cellIdentifier: String { get }
    var headerIdentifier: String { get }
}

@objc public protocol SSDatePickerViewDelegate {
    @objc optional func SSDatePickerView(_ view: SSDatePickerView, onChangeFrom date: Date?)
    @objc optional func SSDatePickerView(_ view: SSDatePickerView, onChangeTo date: Date?)
}

public class SSDatePickerView: UIView, CollectionViewProtocol {
    
    public var delegate: SSDatePickerViewDelegate?
    
    var dataSource = [Month]()
    var selectedDates = [Date]()
    var cellIdentifier: String = "cell"
    var headerIdentifier: String = "header"
    
    var fromDate: Date? {
        didSet {
            delegate?.SSDatePickerView?(self, onChangeFrom: fromDate)
        }
    }
    
    var toDate: Date? {
        didSet {
            delegate?.SSDatePickerView?(self, onChangeTo: toDate)
        }
    }
    
    public var calendar: Calendar {
        configuration.calendar
    }
    
    public var from: Date? {
        fromDate
    }
    
    public var to: Date? {
        toDate
    }
    
    public var configuration = SSDatePickerConfiguration(start: Date(), end: Calendar.current.date(byAdding: .year, value: 1, to: Date())!, calendar: Calendar.current) {
        didSet {
            setupView()
        }
    }
    
    fileprivate func updateCollectionViewCells(_ itemsIndexPath: [IndexPath]) {
        DispatchQueue.main.async {
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadItems(at: itemsIndexPath)
                self.collectionView.layoutIfNeeded()
            })
        }
    }
    
    public func clear() {
        if let itemsIndexPath = Calcutator.calculateIndexPaths(delegate: self) {
            updateCollectionViewCells(itemsIndexPath.sorted())
        } else if let date = fromDate, let indexPath = Calcutator.getIndexPath(delegate: self, from: date) {
            updateCollectionViewCells([indexPath])
        }
        
        fromDate = nil
        toDate = nil
    }
    
    lazy private var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.headerReferenceSize = CGSize(width: bounds.width, height: 50)
        
        return flowLayout
    }()
    
    lazy private var collectionViewDataSource: CollectionViewDataSource = {
        let dataSource = CollectionViewDataSource()
        dataSource.delegate = self
        
        return dataSource
    }()
    
    lazy private var collectionViewDelegate: CollectionViewDelegate = {
        let delegate = CollectionViewDelegate()
        delegate.delegate = self
        
        return delegate
    }()
    
    lazy private var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = backgroundColor
        collection.dataSource = collectionViewDataSource
        collection.delegate = collectionViewDelegate
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
        
        return collection
    }()
    
    open func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
        cellIdentifier = identifier
    }
    
    open func register(_ nib: UINib?, forHeaderWithReuseIdentifier identifier: String) {
        collectionView.register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier)
        headerIdentifier = identifier
    }
    
    func dates(from fromDate: Date, to toDate: Date) -> [Date] {
        var dates: [Date] = []
        var date = fromDate

        while date <= toDate {
            dates.append(date)
            guard let newDate = configuration.calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = newDate
        }
        return dates
    }
    
    private func dataSourceCalculation() {
        guard let duration = configuration.calendar.dateComponents([.month], from: configuration.start, to: configuration.end).month, duration > 0 else {
            fatalError()
        }
        
        let startWeekNumber = calendar.component(Calendar.Component.month, from: configuration.start)
        
        var months = [Month]()
        for index in 0...duration - startWeekNumber {
            let date = configuration.calendar.date(byAdding: .month, value: index, to: configuration.start)!
            
            let component = configuration.calendar.dateComponents([.year, .month], from: date)
            let start = configuration.calendar.date(from: component)!
            let end = configuration.calendar.date(byAdding: DateComponents(month: 1, day: -1), to: start)!
            
            let startWeekDay = Calcutator.startWeekDayNumber(calendar: configuration.calendar, date: start)
            let dates = self.dates(from: start, to: end)
            let model = Month(startWeekDay: startWeekDay, days: dates)
            
            months.append(model)
        }
        
        dataSource = months
        
    }
    
    private func setupView() {
        addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        dataSourceCalculation()
    }
    
    // MARK: - Initiate class
    
    convenience init(frame: CGRect, configuration: SSDatePickerConfiguration) {
        self.init(frame: frame)
        self.configuration = configuration
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
}
