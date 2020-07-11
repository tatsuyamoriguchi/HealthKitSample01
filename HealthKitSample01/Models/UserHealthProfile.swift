//
//  UserHealthProfile.swift
//  HealthKitSample01
//
//  Created by Tatsuya Moriguchi on 7/10/20.
//  Copyright © 2020 Tatsuya Moriguchi. All rights reserved.
//

import HealthKit

class UserHealthProfile {
    var age: Int?
    var biologicalSex:HKBiologicalSex?
    var bloodType: HKBloodType?
    var heightInMeters: Double?
    var weightInKilograms: Double?
    
    var bodyMassIndex: Double? {
        guard let weightInKilograms = weightInKilograms, let heightInMeters = heightInMeters, heightInMeters > 0  else {
            return nil
        }
        return (weightInKilograms/(heightInMeters*heightInMeters))
    }
    
}
