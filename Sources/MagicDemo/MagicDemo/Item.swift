//
//  Item.swift
//  MagicApp
//
//  Created by Angel on 2024/9/25.
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
