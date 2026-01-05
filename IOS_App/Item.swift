//
//  Item.swift
//  IOS_App
//
//  Created by Ayush Shetty on 05/01/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
