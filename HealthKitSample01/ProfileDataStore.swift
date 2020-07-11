//
//  ProfileDataStore.swift
//  HealthKitSample01
//
//  Created by Tatsuya Moriguchi on 7/10/20.
//  Copyright © 2020 Tatsuya Moriguchi. All rights reserved.
//

import HealthKit
import UIKit

class ProfileDataStore {
    
    class func getAgeSexAndBloodType() throws -> (age: Int, bilogicalSex: HKBiologicalSex, bloodType: HKBloodType) {
        
        let healthKitStore = HKHealthStore()
        
        do {
            // 1. Thie meethod throws an error if these data are not available.
            let birthdayComponents = try healthKitStore.dateOfBirthComponents()
            let biologicalSex = try healthKitStore.biologicalSex()
            let bloodType = try healthKitStore.bloodType()
            
            // 2. Use Calendar to calculate age.
            let today = Date()
            let calendar = Calendar.current
            let todayDateComponents = calendar.dateComponents([.year], from: today)
            let thisYear = todayDateComponents.year!
            let age = thisYear - birthdayComponents.year!
            
            // 3. Unwrap the wrappers
            let unwrappedBiologicalSex = biologicalSex.biologicalSex
            let unwrappedBloodType = bloodType.bloodType
            
            return (age, unwrappedBiologicalSex, unwrappedBloodType)
            
        }
    }
    
    class func getMostRecentSample(for sampleType: HKSampleType, completion: @escaping(HKQuantitySample?, Error?) -> Swift.Void) {
        
        // 1. Use HKQuery to load the most recent samples.
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let limit = 1
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            
            // 2. Always dispatch to the main thread when complete.
            DispatchQueue.main.async {
                
                guard let samples = samples, let mostRecentSample = samples.first as? HKQuantitySample else {
                    completion(nil, error)
                    return
                }
                completion(mostRecentSample, nil)
            }
        }
        
        HKHealthStore().execute(sampleQuery)
    }
    
    
// To avoid UIAlertView on a view which is not presented error, move this code to ProfileTableViewController as a func
//    class func saveBodyMassIndexSample(bodyMassIndex: Double, date: Date) {
//
//        // 1. Make sure the body mass type exists
//        guard let bodyMassIndexType =  HKQuantityType.quantityType(forIdentifier: .bodyMassIndex) else {
//            fatalError("Body Mass Index Type is no longer availble in HealthKit")
//        }
//
//        // 2. Use the Count HKUnit to create a body mass quantity.
//        let bodyMassQuantity = HKQuantity(unit: HKUnit.count(), doubleValue: bodyMassIndex)
//        let bodyMassIndexSample = HKQuantitySample(type: bodyMassIndexType, quantity: bodyMassQuantity, start: date, end: date)
//
//        // 3. Save the same to HealthKit
//        HKHealthStore().save(bodyMassIndexSample) { (success, error)  in
//            if let error = error {
//                let message = "Error Saving BMI Sample: \(error.localizedDescription)"
//                print(message)
//
//            } else {
//                let message = "Successfully saved BMI Sample."
//                print(message)
//
//            }
//        }
//
//
//    }
    
    
    
}
