//
//  TimeInterval.swift
//  Music-app
//
//  Created by Shirin on 24.09.2023.
//

import Foundation

extension TimeInterval {
    var minuteSecond: String {
        if isFinite && !isNaN {
            return String(format:"%02d:%02d", minute, second)
        } else {
            return "00:00"
        }
    }

    var minute: Int {
        if isFinite && !isNaN {
            return Int((self/60).truncatingRemainder(dividingBy: 60))
        } else {
            return 0
        }
    }
    
    var second: Int {
        if isFinite && !isNaN {
            return Int(truncatingRemainder(dividingBy: 60))
        } else {
            return 0
        }
    }
}


