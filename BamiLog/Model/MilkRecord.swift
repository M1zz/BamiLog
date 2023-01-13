//
//  MilkRecord.swift
//  BamiLog
//
//  Created by Roen White on 2023/01/14.
//

import Foundation

struct MilkRecord: Codable, Hashable, Identifiable {
    var id = UUID()
    let startTime: Date
    var startTimeDate: String? = nil
    
    var milkType: MilkType? = nil
    var milkQuantity: Int? = nil
    
    var sleepTime: Int? = nil
    
    var diaperPee: Bool? = nil
    var diaperPoo: Bool? = nil
    
    var feedingTime: Int? = nil
}

enum MilkType: Codable {
    case powder
    case natural
}
