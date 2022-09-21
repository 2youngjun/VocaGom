//
//  CalendarViewController.swift
//  Nadam
//
//  Created by 이영준 on 2022/09/21.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController {
    
    //MARK: Variables
    
    private lazy var headerDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 M월"
        return dateFormatter
    }()
    
    private var currentPage: Date?
    private lazy var today: Date = {
        return Date()
    }()
    var wordAppendedDate = [String]()
    
    //MARK: IBOutlet Variables
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var calendarBackgroundView: UIView!
    
    //MARK: IBOutlet Function
    override func viewDidLoad() {
        super.viewDidLoad()
        self.styleFunction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.calendarView.scope = .month
        self.dateLabel.text = self.headerDateFormatter.string(from: calendarView.currentPage)
        
        self.calendarCurrentPageDidChange(self.calendarView)
        self.calendarView.reloadData()
    }
    
    @IBAction func tapPrevButton(_ sender: UIButton) {
        self.scrollCurrentPage(isPrev: true)
    }
    
    @IBAction func tapNextButton(_ sender: UIButton) {
        self.scrollCurrentPage(isPrev: false)
    }
    
    //MARK: Style Function
    private func styleFunction(){
        self.configureBackGroundView()
        self.configureCalendarView()
    }
    
    private func configureBackGroundView() {
        self.dateLabel.font = UIFont.NFont.noSearchedTextFont
        self.view.backgroundColor = UIColor.NColor.background
        self.calendarBackgroundView.layer.cornerRadius = 10.0
        self.calendarBackgroundView.backgroundColor = UIColor.NColor.white
    }
    
    private func configureCalendarView() {
        self.calendarView.delegate = self
        self.calendarView.dataSource = self
        self.wordAppendedDate = CoreDataManager.shared.isSelectedMonthWord(date: Date())
        
        self.calendarView.appearance.weekdayFont = UIFont.NFont.wordListWordSynoym
        self.calendarView.appearance.weekdayTextColor = UIColor.NColor.black
        
        self.calendarView.scrollEnabled = false
        self.calendarView.headerHeight = 0
        
        self.calendarView.appearance.subtitleOffset = CGPoint(x: 0, y: 0.8)
        
        self.calendarView.appearance.titleDefaultColor = UIColor.NColor.black
        
        self.calendarView.appearance.todayColor = UIColor.NColor.subBlue.withAlphaComponent(0.5)
        self.calendarView.appearance.selectionColor = UIColor.NColor.subBlue
        
        self.calendarView.calendarWeekdayView.weekdayLabels[0].text = "SUN"
        self.calendarView.calendarWeekdayView.weekdayLabels[1].text = "MON"
        self.calendarView.calendarWeekdayView.weekdayLabels[2].text = "TUE"
        self.calendarView.calendarWeekdayView.weekdayLabels[3].text = "WED"
        self.calendarView.calendarWeekdayView.weekdayLabels[4].text = "THU"
        self.calendarView.calendarWeekdayView.weekdayLabels[5].text = "FRI"
        self.calendarView.calendarWeekdayView.weekdayLabels[6].text = "SAT"
        
    }
    
    private func scrollCurrentPage(isPrev: Bool) {
        let currentCalendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = isPrev ? -1 : 1
        
        self.currentPage = currentCalendar.date(byAdding: dateComponents, to: self.currentPage ?? self.today)
        self.calendarView.setCurrentPage(self.currentPage!, animated: true)
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        self.dateLabel.text = self.headerDateFormatter.string(from: calendar.currentPage)
        
        self.wordAppendedDate = CoreDataManager.shared.isSelectedMonthWord(date: calendar.currentPage)
        self.calendarView.reloadData()
    }
}

extension CalendarViewController: FSCalendarDelegate {
    
}

extension CalendarViewController: FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let selectedDate: String = CoreDataManager.shared.changeSelectedDateToString(date)
        var count = 0
        if self.wordAppendedDate.contains(selectedDate) {
            count += 1
        }
        return count
    }
}

extension CalendarViewController: FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        let selectedDate: String = CoreDataManager.shared.changeSelectedDateToString(date)
        var colorSet = [UIColor]()
        if self.wordAppendedDate.contains(selectedDate) {
            colorSet.append(UIColor.NColor.orange)
        }
        return colorSet
    }
}
