//
//  Date.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 2/4/22.
//

import Foundation


extension Date {
    func toStringDateShort() -> String {
        let iDay: String = String(getDayComponent(dateIn: self))
        let iMonth: String = String(getMonthComponent(dateIn: self))
        let iYear: String = String(getYearComponent(dateIn: self))
        let strYear:String = String(iYear.suffix(2))
        
        return  iMonth + "/" + iDay + "/" + strYear
    }
}

extension Date {
    func toStringDateLong() -> String {
        let iDay: String = String(getDayComponent(dateIn: self))
        let iMonth: Int = getMonthComponent(dateIn: self)
        let iYear: String = String(getYearComponent(dateIn: self))
        let strMonth: String = getTheMonth(mon: iMonth)
        
        return strMonth + " " + iDay + ", " + iYear
    }
}
