//
//  Date+DateTools.swift
//  DateTools
//
// Copyright 2015 Codewise sp. z o.o. Sp. K.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

public enum DateAgoFormat {
    case short
    case week
    case long
    case longUsingNumericDates
    case longUsingNumericTimes
    case longUsingNumericDatesAndTimes
}

public enum DateAgoValues {
    case yearsAgo
    case monthsAgo
    case weeksAgo
    case daysAgo
    case hoursAgo
    case minutesAgo
    case secondsAgo
}

struct DateToolsLocalizedStrings {
    static func stringFor(key: String) -> String {
        let bundle: Bundle = Bundle.init(identifier: "DateTools")!
        return NSLocalizedString(key, tableName: "DateTools", bundle: bundle, comment: "")
    }
}

public extension Date {
    public static func dateWith(year: Int = 1970, month: Int = 1, day: Int = 1, hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date {
        var components = DateComponents()
        
        components.year   = year
        components.month  = month
        components.day    = day
        components.hour   = hour
        components.minute = minute
        components.second = second
        
        return Calendar.current.date(from: components)!
    }
    
    // MARK: - Time ago since date
    public func timeAgo(useNumericDates numericDates: Bool, useNumericTimes numericTimes: Bool) -> String {
        var timeAgo: String
        if numericDates && numericTimes {
            timeAgo = self.timeAgo(withFormat: .longUsingNumericDatesAndTimes)
        } else if (numericDates) {
            timeAgo = self.timeAgo(withFormat: .longUsingNumericDates)
        } else if (numericTimes) {
            timeAgo = self.timeAgo(withFormat: .longUsingNumericTimes)
        } else {
            timeAgo = self.timeAgo(withFormat: .long)
        }
        
        return timeAgo
    }

    public func timeAgo(withFormat format: DateAgoFormat) -> String {
        let calendar = Calendar.current
        let now = Date()
        var earliest = (now < self) ? now : self
        var latest = (earliest == self) ? now : self;
        
        // Compare date and time if the delta is less than 24 hours
        // Otherwise, only compare the date
        let upToHours: Set<Calendar.Component> = [Calendar.Component.second, Calendar.Component.minute, Calendar.Component.hour]
        var difference: DateComponents = calendar.dateComponents(upToHours, from: earliest, to: latest)
        
        var string: String?
        
        if (difference.hour! < 24) {
            if (difference.hour! >= 1) {
                string = self.localizedString(format: format, valueType: .hoursAgo, value: difference.hour!)
            } else if (difference.minute! >= 1) {
                string = self.localizedString(format: format, valueType: .minutesAgo, value: difference.minute!)
            } else {
                string = self.localizedString(format: format, valueType: .secondsAgo, value: difference.second!)
            }
        } else {
            let bigUnits: Set<Calendar.Component> = [Calendar.Component.timeZone, Calendar.Component.day, Calendar.Component.weekOfYear, Calendar.Component.month, Calendar.Component.year]
            
            let earliestComponents = calendar.dateComponents(bigUnits, from: earliest)
            earliest = calendar.date(from: earliestComponents)!
            
            let latestComponents = calendar.dateComponents(bigUnits, from: latest)
            latest = calendar.date(from: latestComponents)!
            
            difference = calendar.dateComponents(bigUnits, from: earliest, to: latest)
            
            if (difference.year! >= 1) {
                string = self.localizedString(format: format, valueType: .yearsAgo, value: difference.year!)
            } else if (difference.month! >= 1) {
                string = self.localizedString(format: format, valueType: .monthsAgo, value: difference.month!)
            } else if (difference.weekOfYear! >= 1) {
                string = self.localizedString(format: format, valueType: .weeksAgo, value: difference.weekOfYear!)
            } else {
                string = self.localizedString(format: format, valueType: .daysAgo, value: difference.day!)
            }
            
        }
        
        return string!
    }
    
    public func localizedString(format: DateAgoFormat, valueType: DateAgoValues, value: Int) -> String? {
        let isShort: Bool = format == .short
        let isNumericDate = format == .longUsingNumericDates || format == .longUsingNumericDatesAndTimes
        let isNumericTime = format == .longUsingNumericTimes || format == .longUsingNumericDatesAndTimes
        let isWeek = format == .week
        
        var string: String?
        
        switch valueType {
        case .yearsAgo:
            if isShort {
                string = self.logicLocalizedString(fromFormat: "%%d%@y", withValue: value)
            } else if value >= 2 {
                string = self.logicLocalizedString(fromFormat: "%%d %@years ago", withValue: value)
            } else if isNumericDate {
                string = DateToolsLocalizedStrings.stringFor(key: "1 year ago")
            } else {
                return DateToolsLocalizedStrings.stringFor(key: "Last year")
            }
        case .monthsAgo:
            if isShort {
                string = self.logicLocalizedString(fromFormat: "%%d%@M", withValue: value)
            } else if value >= 2 {
                string = self.logicLocalizedString(fromFormat: "%%d %@months ago", withValue: value)
            } else if isNumericDate {
                string = DateToolsLocalizedStrings.stringFor(key: "1 month ago")
            } else {
                return DateToolsLocalizedStrings.stringFor(key: "Last month")
            }
        case .weeksAgo:
            if isShort {
                string = self.logicLocalizedString(fromFormat: "%%d%@w", withValue: value)
            } else if value >= 2 {
                string = self.logicLocalizedString(fromFormat: "%%d %@weeks ago", withValue: value)
            } else if isNumericDate {
                string = DateToolsLocalizedStrings.stringFor(key: "1 week ago")
            } else {
                return DateToolsLocalizedStrings.stringFor(key: "Last week")
            }
        case .daysAgo:
            if isShort {
                string = self.logicLocalizedString(fromFormat: "%%d%@d", withValue: value)
            } else if value >= 2 {
                if (isWeek && value <= 7) {
                    let dayDateFormatter = DateFormatter()
                    dayDateFormatter.dateFormat = "EEE"
                    let eee = dayDateFormatter.string(from: self)
                    string = DateToolsLocalizedStrings.stringFor(key: eee)
                } else {
                    string = self.logicLocalizedString(fromFormat: "%%d %@days ago", withValue: value)
                }
            } else if isNumericDate {
                string = DateToolsLocalizedStrings.stringFor(key: "1 day ago")
            } else {
                return DateToolsLocalizedStrings.stringFor(key: "Yesterday")
            }
        case .hoursAgo:
            if isShort {
                string = self.logicLocalizedString(fromFormat: "%%d%@h", withValue: value)
            } else if value >= 2 {
                string = self.logicLocalizedString(fromFormat: "%%d %@hours ago", withValue: value)
            } else if isNumericDate {
                string = DateToolsLocalizedStrings.stringFor(key: "1 hour ago")
            } else {
                return DateToolsLocalizedStrings.stringFor(key: "An hour ago")
            }
        case .minutesAgo:
            if isShort {
                string = self.logicLocalizedString(fromFormat: "%%d%@m", withValue: value)
            } else if value >= 2 {
                string = self.logicLocalizedString(fromFormat: "%%d %@minutes ago", withValue: value)
            } else if isNumericDate {
                string = DateToolsLocalizedStrings.stringFor(key: "1 minute ago")
            } else {
                return DateToolsLocalizedStrings.stringFor(key: "A minute ago")
            }
        case .secondsAgo:
            if isShort {
                string = self.logicLocalizedString(fromFormat: "%%d%@s", withValue: value)
            } else if value >= 2 {
                string = self.logicLocalizedString(fromFormat: "%%d %@seconds ago", withValue: value)
            } else if isNumericDate {
                string = DateToolsLocalizedStrings.stringFor(key: "1 second ago")
            } else {
                return DateToolsLocalizedStrings.stringFor(key: "A second ago")
            }
        }
        
        return string
    }
    
    private func logicLocalizedString(fromFormat format: String, withValue value: Int) -> String {
        let localeFormat = String(format: format, self.getLocaleFormatUnderscores(withValue: Double(value)))
        return String(format: DateToolsLocalizedStrings.stringFor(key: localeFormat), value)
    }
    
    private func getLocaleFormatUnderscores(withValue value: Double) -> String {
        let localeCode = Bundle.main.preferredLocalizations.first
        
        // Overrides for Russian (ru) and Ukranian (uk)
        if (localeCode == "ru-RU" || localeCode == "uk") {
            let xy: Int = Int(floor(value).truncatingRemainder(dividingBy: 100))
            let y: Int = Int(floor(value).truncatingRemainder(dividingBy: 10))
            
            if (y == 0 || y > 4 || (xy > 10 && xy < 15)) {
                return ""
            }
            
            if (y > 1 && y < 5 && (xy < 10 || xy > 20)) {
                return "_"
            }
            
            if (y == 1 && xy != 11) {
                return "__"
            }
        }
        
        // Add more languages with specific translation rules here
        return ""
    }
    
    // MARK: - Adding components to date
    public func dateByAdding(years: Int) -> Date {
        return Calendar.current.dateByAdding(years: years, to: self)
    }
    
    public func dateByAdding(months: Int) -> Date {
        return Calendar.current.dateByAdding(months: months, to: self)
    }
    
    public func dateByAdding(weeks: Int) -> Date {
        return Calendar.current.dateByAdding(weeks: weeks, to: self)
    }
    
    public func dateByAdding(days: Int) -> Date {
        return Calendar.current.dateByAdding(days: days, to: self)
    }
    
    public func dateByAdding(hours: Int) -> Date {
        return Calendar.current.dateByAdding(hours: hours, to: self)
    }
    
    public func dateByAdding(minutes: Int) -> Date {
        return Calendar.current.dateByAdding(minutes: minutes, to: self)
    }
    
    public func dateByAdding(seconds: Int) -> Date {
        return Calendar.current.dateByAdding(seconds: seconds, to: self)
    }
    
    // MARK: - Subtracting components from date
    public func dateBySubtracting(years: Int) -> Date {
        return Calendar.current.dateBySubtracting(years: years, from: self)
    }
    
    public func dateBySubtracting(months: Int) -> Date {
        return Calendar.current.dateBySubtracting(months: months, from: self)
    }
    
    public func dateBySubtracting(weeks: Int) -> Date {
        return Calendar.current.dateBySubtracting(weeks: weeks, from: self)
    }
    
    public func dateBySubtracting(days: Int) -> Date {
        return Calendar.current.dateBySubtracting(days: days, from: self)
    }
    
    public func dateBySubtracting(hours: Int) -> Date {
        return Calendar.current.dateBySubtracting(hours: hours, from: self)
    }
    
    public func dateBySubtracting(minutes: Int) -> Date {
        return Calendar.current.dateBySubtracting(minutes: minutes, from: self)
    }
    
    public func dateBySubtracting(seconds: Int) -> Date {
        return Calendar.current.dateBySubtracting(seconds: seconds, from: self)
    }

    public func hoursFrom(date: Date) -> Double {
        return self.timeIntervalSince(date) / Double(SECONDS_IN_HOUR)
    }
    
    public func minutesFrom(date: Date) -> Double {
        return self.timeIntervalSince(date) / Double(SECONDS_IN_MINUTE)
    }
    
    public func secondsFrom(date: Date) -> Double {
        return self.timeIntervalSince(date)
    }
}
