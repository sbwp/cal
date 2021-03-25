//
//  Date.swift
//
//  Created by Sabrina Bea on 2/29/20.
//  Copyright © 2020 Sabrina Bea. All rights reserved.
//

import Foundation

// MARK: Get details
extension Date {
    var dayOfWeek: Weekday {
        weekDayMatchingIndex(Calendar.current.component(.weekday, from: self) - 1)
    }
    
    var weekDayName: String {
        DateFormatter().weekdaySymbols[Calendar.current.component(.weekday, from: self) - 1]
    }
    
    var dayOfMonth: Int {
        Calendar.current.dateComponents([.day], from: self).day!
    }
    
    // Month as a one-indexed integer
    var hour: Int {
        Calendar.current.dateComponents([.hour], from: self).hour!
    }
    
    // Month as a one-indexed integer
    var month: Int {
        Calendar.current.dateComponents([.month], from: self).month!
    }
    
    var year: Int {
        Calendar.current.dateComponents([.year], from: self).year!
    }
    
    private var monthIndex: Int {
        month - 1
    }
}

// MARK: Repeating Event Matchers
extension Date {
    var isWeekend: Bool {
        isA(.sunday) || isA(.saturday)
    }
    
    var isWeekday: Bool {
        !isWeekend
    }
    
    func isA(_ weekday: Weekday) -> Bool {
        this(weekday) == self
    }
    
    func isSameDay(as date: Date) -> Bool {
        noon == date.noon
    }
    
    func isSameDayOfWeek(as date: Date) -> Bool {
        date.isA(self.dayOfWeek)
    }
    
    func isInSameWeek(as date: Date) -> Bool {
        this(Date.firstDayOfWeek).isSameDay(as: date.this(Date.firstDayOfWeek))
    }
    
    func isInSameMonth(as date: Date) -> Bool {
        year == date.year && month == date.month
    }
    
    func isInSameYear(as date: Date) -> Bool {
        year == date.year
    }
    
    func coincidesBiweekly(with date: Date) -> Bool {
        if (!isSameDayOfWeek(as: date)) {
            return false
        }
        
        let distance = distanceFrom(date, in: [.day]).day ?? 1
        return distance % 14 == 0
    }
    
    // Note: Semimonthly, Monthly, and Bimonthly cannot exist with dates above 28 (or 14/15 for semi).
    func coincidesSemimonthly(with date: Date) -> Bool {
        self.dayOfMonth % 15 == date.dayOfMonth % 15
    }
    
    // Note: Semimonthly, Monthly, and Bimonthly cannot exist with dates above 28 (or 14/15 for semi).
    func sameDayOfMonth(as date: Date) -> Bool {
        self.dayOfMonth == date.dayOfMonth
    }
    
    // Note: Semimonthly, Monthly, and Bimonthly cannot exist with dates above 28 (or 14/15 for semi).
    func coincidesBimonthly(with date: Date) -> Bool {
        self.dayOfMonth == date.dayOfMonth && self.month % 2 == date.month % 2
    }
    
    // Note Quarterly and Semiannually cannot exist with dates of 31 or above 28 if they occur in February.
    func coincidesQuarterly(with date: Date) -> Bool {
        self.dayOfMonth == date.dayOfMonth && self.month % 3 == date.month % 3
    }
    
    // Note Quarterly and Semiannually cannot exist with dates of 31 or above 28 if they occur in February.
    func coincidesSemiannually(with date: Date) -> Bool {
        self.dayOfMonth == date.dayOfMonth && self.month % 6 == date.month % 6
    }
    
    func sameDayOfYear(as date: Date) -> Bool {
        let myComponents = Calendar.current.dateComponents([.day, .month], from: self)
        let otherComponents = Calendar.current.dateComponents([.day, .month], from: date)
        
        return myComponents.day == otherComponents.day && myComponents.month == otherComponents.month
    }
}

// MARK: Get Related Dates
// Note: Calendar.current.date(bySetting: .month, value: 1, of: date) means January (months 1-12, not 0-11)
extension Date {
    static func practicalToday() -> Date {
        let now = Date()
        return now.hour < 4 ? now.addDays(-1).noon : now.noon
    }
    
    var noon: Date {
        var hour = Calendar.current.component(.hour, from: self)
        var date = self
        if hour == 12 {
            date = date.add(-1, .hour)
            hour = 11
        }
        var direction = Calendar.SearchDirection.backward
        if hour < 12 {
            direction = .forward
        }
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self, direction: direction)!
    }
    
    var tomorrow: Date {
        addDays(1)
    }
    
    var yesterday: Date {
        addDays(-1)
    }
    
    var firstDayOfMonth: Date {
        if Calendar.current.component(.day, from: self) == 1 {
            return self
        }
        return Calendar.current.date(bySetting: .day, value: 1, of: self)!.addMonths(-1)
    }
    
    var lastDayOfYear: Date {
        let december = Calendar.current.date(bySetting: .month, value: 12, of: self)!
        return Calendar.current.date(bySetting: .day, value: 31, of: december)!
    }
    
    // This isn't very pretty
    func nextOccurrenceOfDayOfMonth(_ day: Int, includeSelf: Bool = false) -> Date? {
        let thisMonthDate = Calendar.current.date(bySetting: .day, value: day, of: self)
        if let thisMonthDate = thisMonthDate, dayOfMonth > day || !includeSelf && dayOfMonth == day {
            if month == 12 {
                guard let partial = Calendar.current.date(bySetting: .year, value: year + 1, of: thisMonthDate) else {
                    return nil
                }
                return Calendar.current.date(bySetting: .month, value: 1, of: partial)
            } else {
                return Calendar.current.date(bySetting: .month, value: month + 1, of: thisMonthDate)
            }
        } else {
            return thisMonthDate
        }
    }
    
    func nextAnniversary(of date: Date, includeSelf: Bool = false) -> Date? {
        let thisYearDate = Date.from(year: self.year, month: date.month, day: date.dayOfMonth)
        if let thisYearDate = thisYearDate, self > date || !includeSelf && self == date {
            return Calendar.current.date(bySetting: .year, value: year + 1, of: thisYearDate)
        } else {
            return thisYearDate
        }
    }
    
    func addDays(_ days: Int) -> Date  {
        add(days, .day)
    }
    
    func addMonths(_ months: Int) -> Date  {
        add(months, .month)
    }
    
    func addYears(_ years: Int) -> Date  {
        add(years, .year)
    }
    
    func add(_ value: Int, _ unit: Calendar.Component) -> Date {
        Calendar.current.date(byAdding: unit, value: value, to: self)!
    }
    
    func weekOf() -> [Date] {
        let start = this(Date.firstDayOfWeek)
        return [0, 1, 2, 3, 4, 5, 6].map { number in
            start.addDays(number)
        }
    }
    
    func this(dayOfMonth: Int) -> Date {
        let first = Calendar.current.date(bySetting: .day, value: 1, of: self)!.addMonths(-1)
        if dayOfMonth == 1 {
            return first
        }
        return Calendar.current.date(bySetting: .day, value: dayOfMonth, of: first)!
    }
    
    func this(_ weekday: Weekday) -> Date {
        previous(Date.firstDayOfWeek, considerToday: true).next(weekday, considerToday: true)
    }
    
    func next(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        get(.next,
            weekday,
            considerToday: considerToday)
    }
    
    func previous(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        get(.previous,
            weekday,
            considerToday: considerToday)
    }
    
    func nextWeekendDay(considerToday: Bool = false) -> Date {
        let saturday = next(.saturday, considerToday: considerToday)
        let sunday = next(.sunday, considerToday: considerToday)
        return saturday < sunday ? saturday : sunday
    }
    
    func nextWeekday(considerToday: Bool = false) -> Date {
        let nextDay = considerToday ? self : tomorrow
        let nextDayOfWeek = nextDay.dayOfWeek // Avoid recomputing for checking saturday and sunday
        
        return nextDayOfWeek == .saturday || nextDayOfWeek == .sunday ? nextDay.next(.monday) : nextDay
    }
}

// MARK: Distance
extension Date {
    static func daysBetween(_ start: Date, and end: Date) -> Int {
        distanceBetween(start, and: end, in: [.day]).day!
    }
    
    // Number of weeks between start and end, not including the week of start or the week of end
    static func fullWeeksBetween(_ start: Date, and end: Date) -> Int {
        distanceBetween(start.this(.monday).next(.monday), and: end.this(.monday), in: [.weekOfYear]).weekOfYear!
    }
    
    // Number of months between start and end, not including the month of start or the month of end
    static func fullMonthsBetween(_ start: Date, and end: Date) -> Int {
        distanceBetween(start.firstDayOfMonth.addMonths(1), and: end.firstDayOfMonth, in: [.month]).month!
    }
    
    // Number of years between start and end, not including the year of start or the year of end
    static func fullYearsBetween(_ start: Date, and end: Date) -> Int {
        end.year - start.year - 1
    }
    
    static func distanceBetween(_ start: Date, and end: Date, in components: Set<Calendar.Component> = [.day]) -> DateComponents {
        start.distanceFrom(end, in: components)
    }
    
    func distanceFrom(_ date: Date, in components: Set<Calendar.Component> = [.day]) -> DateComponents {
        let calendar = Calendar.current
        return calendar.dateComponents(components, from: self.noon, to: date.noon)
    }
}

// MARK: Weekday Helpers
extension Date {
    static var firstDayOfWeek: Weekday = .monday
    
    private func get(_ direction: SearchDirection,
             _ weekDay: Weekday,
             considerToday consider: Bool = false) -> Date {
        
        let dayName = weekDay.rawValue
        let weekdaysName = getWeekDaysInEnglish().map { $0.lowercased() }
        let searchWeekdayIndex = weekdaysName.firstIndex(of: dayName)! + 1
        let calendar = Calendar(identifier: .gregorian)
        
        if consider && calendar.component(.weekday, from: self) == searchWeekdayIndex {
            return self
        }
        
        var nextDateComponent = calendar.dateComponents([.hour, .minute, .second], from: self)
        nextDateComponent.weekday = searchWeekdayIndex
        
        return calendar.nextDate(after: self, matching: nextDateComponent, matchingPolicy: .nextTime, direction: direction.calendarSearchDirection)!
    }
    
    private func getWeekDaysInEnglish() -> [String] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar.weekdaySymbols
    }
    
    private func weekDayMatchingIndex(_ index: Int) -> Weekday {
        let weekDays: [Weekday] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        return weekDays[index]
    }
    
    enum Weekday: String {
        case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    }
    
    enum SearchDirection {
        case next
        case previous
        
        var calendarSearchDirection: Calendar.SearchDirection {
            switch self {
            case .next:
                return .forward
            case .previous:
                return .backward
            }
        }
    }
}

// MARK: Recurrence Helpers
extension Date {
    var isDistantFuture: Bool {
        return year == Date.distantFuture.year
    }
}

// MARK: Quick Formatting
extension Date {
    enum DateComponentLength {
        case none
        case short
        case long
        case full
        case variable
    }
    
    func formatted(fromTemplate template: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: Locale.current)
        
        return formatter.string(from: self)
    }
    
    func formatted(year: DateComponentLength = .short, month: DateComponentLength = .short, day: DateComponentLength = .short, weekday: DateComponentLength = .none) -> String {
        if (isDistantFuture) {
            return "Never"
        }
        
        var yearLength = year
        if year == .variable {
            yearLength = .none
            let thisYear = Date().year
            if (self.year != thisYear) {
                yearLength = self.year / 100 == thisYear / 100 ? .short : .long
            }
        }
        
        let weekTemplate = weekday == .none ? "" : weekday == .short ? "EEE" : "EEEE"
        let dayTemplate = day == .long ? "dd" : day == .none ? "" : "d"
        let monthTemplate = month == .full ? "MMMM" : month == .long ? "MM" : month == .short ? "M" : ""
        let yearTemplate = yearLength == .none ? "" : yearLength == .short ? "yy" : "yyyy"
        return formatted(fromTemplate: weekTemplate + dayTemplate + monthTemplate + yearTemplate)
    }
}

// MARK: Quick Initialization
extension Date {
    static func from(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        
        return Calendar.current.date(from: components)
    }
}
