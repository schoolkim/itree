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

enum Filter: String {
    case All = "All"
    case Today = "Today"
    case Week = "This Week"
    case Month = "This Month"
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
