//
//  ItreeModel.swift
//  Itree
//
//  Created by HAKKYU KIM on 2022/06/30.
//

import UIKit

enum Section {
    case Main
}

enum Filter: CaseIterable {
    case all, today, week, month
    
    var title: String {
        switch self {
        case .all: return "All"
        case .today: return "Today"
        case .week: return "This Week"
        case .month: return "This Month"
        }
    }
}

enum Context {
    case todayPicker, datePicker
    
    var title: String {
        switch self {
        case .todayPicker: return "Time"
        case .datePicker: return "Date"
        }
    }
    
    var datePicker: UIDatePicker {
        let myDatePicker: UIDatePicker = UIDatePicker()
        myDatePicker.timeZone = NSTimeZone.local
        myDatePicker.tintColor = .black
        switch self {
        case .todayPicker:
            myDatePicker.datePickerMode = .time
            return myDatePicker
        case .datePicker:
            myDatePicker.preferredDatePickerStyle = .inline
            return myDatePicker
        }
    }
}

extension Date {
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    var week: Int {
        return Calendar.current.component(.weekOfYear, from: self)
    }
    
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
}

extension String {
    func strikeThrough() -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        attributeString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
        attributeString.addAttribute(.foregroundColor, value: UIColor.gray, range: NSMakeRange(0, attributeString.length))
        return attributeString
    }
}

extension UIViewController {
    class var identifier: String {
        return String(describing: Self.self)
    }

    class func create() -> Self {
        UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: identifier) { coder in
            Self.init(coder: coder)
        }
    }
}


