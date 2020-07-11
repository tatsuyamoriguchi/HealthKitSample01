//
//  HKBiologicalSex+StringRepresentation.swift
//  HealthKitSample01
//
//  Created by Tatsuya Moriguchi on 7/11/20.
//  Copyright © 2020 Tatsuya Moriguchi. All rights reserved.
//

import HealthKit

extension HKBiologicalSex {
  
  var stringRepresentation: String {
    switch self {
    case .notSet: return "Unknown"
    case .female: return "Female"
    case .male: return "Male"
    case .other: return "Other"
    default:
        return "Unclassified"
    }
  }
}
