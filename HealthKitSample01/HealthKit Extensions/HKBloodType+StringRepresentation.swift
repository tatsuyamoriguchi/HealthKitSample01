//
//  HKBloodType+StringRepresentation.swift
//  HealthKitSample01
//
//  Created by Tatsuya Moriguchi on 7/11/20.
//  Copyright © 2020 Tatsuya Moriguchi. All rights reserved.
//

import HealthKit

extension HKBloodType {
  
  var stringRepresentation: String {
    switch self {
    case .notSet: return "Unknown"
    case .aPositive: return "A+"
    case .aNegative: return "A-"
    case .bPositive: return "B+"
    case .bNegative: return "B-"
    case .abPositive: return "AB+"
    case .abNegative: return "AB-"
    case .oPositive: return "O+"
    case .oNegative: return "O-"
    default:
        return "Unclassified"
    }
  }
}
