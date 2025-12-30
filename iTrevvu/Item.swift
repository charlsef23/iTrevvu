//
//  Item.swift
//  iTrevvu
//
//  Created by Carlos Esteve Fernández on 30/12/25.
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
