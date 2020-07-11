//
//  ProfileTableViewController.swift
//  HealthKitSample01
//
//  Created by Tatsuya Moriguchi on 7/10/20.
//  Copyright © 2020 Tatsuya Moriguchi. All rights reserved.
//

import UIKit
import HealthKit

class ProfileTableViewController: UITableViewController {

    // Properties
    private enum ProfileSection: Int {
      case ageSexBloodType
      case weightHeightBMI
      case readHealthKitData
      case saveBMI
    }
    
    private enum ProfileDataError: Error {
      
      case missingBodyMassIndex
      
      var localizedDescription: String {
        switch self {
        case .missingBodyMassIndex:
          return "Unable to calculate body mass index with available profile data."
        }
      }
    }
    
    
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var bloodTypeLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var bodyMassLabel: UILabel!
    
    
    
    private let userHealthProfile = UserHealthProfile()
    
    private func updateHealthInfo() {
      loadAndDisplayAgeSexAndBloodType()
      loadAndDisplayMostRecentWeight()
      loadAndDisplayMostRecentHeight()
    }
    
    
    

    private func loadAndDisplayAgeSexAndBloodType() {
        
        do {
            let userAgeSexAndBloodType = try ProfileDataStore.getAgeSexAndBloodType()
            
            userHealthProfile.age = userAgeSexAndBloodType.age
            userHealthProfile.biologicalSex = userAgeSexAndBloodType.bilogicalSex
            userHealthProfile.bloodType = userAgeSexAndBloodType.bloodType
            
            updateLabels()
            
        } catch let error {
            self.displayAlert(for: error)
        }
    }
    private func loadAndDisplayMostRecentHeight() {
        
        // 1. User HealthKit to create the Height Sampel Type.
        //guard let heightSampleType = HKSampleType.quantityType(forIdentifier: .height) else {
        guard let heightSampleType = HKObjectType.quantityType(forIdentifier: .height) else {
            print("Height Sample Type is no longer available in HealthKit.")
            return
        }
        
        ProfileDataStore.getMostRecentSample(for: heightSampleType) {
            (sample, error) in
            guard let sample = sample else {
                if let error = error {
                    self.displayAlert(for: error)
                }
                return
            }
            
            // 2. Convert the height sample to meters, save to the profile model,
            // and update the user interface.
            let heightInMeters = sample.quantity.doubleValue(for: HKUnit.meter())
            self.userHealthProfile.heightInMeters = heightInMeters
            self.updateLabels()
        }

    }
    
    private func loadAndDisplayMostRecentWeight() {

//        guard let weightSampleType = HKSampleType.guantityType(forIdentifier:  .bodyMass)
  
//        guard let weightSampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)
          guard let weightSampleType = HKObjectType.quantityType(forIdentifier: .bodyMass)  else {
            print("Body Mass Sample Type is no longer available in HealthKit.")
                return
                
        }
        
        ProfileDataStore.getMostRecentSample(for: weightSampleType) {
            (sample, error) in
            
            guard let sample = sample else {
                if let error = error {
                    self.displayAlert(for: error)
                }
                return
            }
            
            let weightInKilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            self.userHealthProfile.weightInKilograms = weightInKilograms
            self.updateLabels()
            
        }
    }
    
        
    private func saveBodyMassIndexToHealthKit() {
        guard let bodyMassIndex = userHealthProfile.bodyMassIndex else {
            displayAlert(for: ProfileDataError.missingBodyMassIndex)
            return
        }
             
        //ProfileDataStore.saveBodyMassIndexSample(bodyMassIndex: bodyMassIndex, date: Date())
        saveBodyMassIndexSample(bodyMassIndex: bodyMassIndex, date: Date())
        
    }
    
    
    func saveBodyMassIndexSample(bodyMassIndex: Double, date: Date) {
        
        // 1. Make sure the body mass type exists
        guard let bodyMassIndexType =  HKQuantityType.quantityType(forIdentifier: .bodyMassIndex) else {
            fatalError("Body Mass Index Type is no longer availble in HealthKit")
        }
        
        // 2. Use the Count HKUnit to create a body mass quantity.
        let bodyMassQuantity = HKQuantity(unit: HKUnit.count(), doubleValue: bodyMassIndex)
        let bodyMassIndexSample = HKQuantitySample(type: bodyMassIndexType, quantity: bodyMassQuantity, start: date, end: date)
        
        // 3. Save the same to HealthKit
        HKHealthStore().save(bodyMassIndexSample) { (success, error)  in
            if let error = error {
                let message = "Error Saving BMI Sample: \(error.localizedDescription)"
                self.messsageResult(message)
                
            } else {
                let message = "Successfully saved BMI Sample."
                self.messsageResult(message)
            }
        }
    }

    fileprivate func messsageResult(_ message: String) {
        DispatchQueue.main.async {
            self.displaySavingAlert(message: message)
            print(message)
        }
    }

    func displaySavingAlert(message: String) {
        
        let alert = UIAlertController(title: "Saving BMI Sample to HealthKit",
                                      message: message,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "O.K.",
                                      style: .default,
                                      handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }

    
    
    private func displayAlert(for error: Error) {
      
      let alert = UIAlertController(title: nil,
                                    message: error.localizedDescription,
                                    preferredStyle: .alert)
      
      alert.addAction(UIAlertAction(title: "O.K.",
                                    style: .default,
                                    handler: nil))
      
      present(alert, animated: true, completion: nil)
    }

    
    private func updateLabels() {
        if let age = userHealthProfile.age {
            ageLabel.text = "\(age)"
        }
        
        if let biologicalSex = userHealthProfile.biologicalSex {
            genderLabel.text = biologicalSex.stringRepresentation
        }
        
        if let bloodType = userHealthProfile.bloodType {
            bloodTypeLabel.text = bloodType.stringRepresentation
        }
        
        if let weight = userHealthProfile.weightInKilograms {
            let weightFormatter = MassFormatter()
            weightFormatter.isForPersonMassUse = true
            weightLabel.text = weightFormatter.string(fromKilograms: weight)
        }
        
        if let height = userHealthProfile.heightInMeters {
            let heightFormatter = LengthFormatter()
            heightFormatter.isForPersonHeightUse = true
            heightLabel.text = heightFormatter.string(fromMeters: height)
        }
        
        if let bodyMassIndex = userHealthProfile.bodyMassIndex {
            bodyMassLabel.text = String(format: "%.02f", bodyMassIndex)
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
      guard let section = ProfileSection(rawValue: indexPath.section) else {
        fatalError("A ProfileSection should map to the index path's section")
      }
      
      switch section {
      case .saveBMI:
        saveBodyMassIndexToHealthKit()
        
      case .readHealthKitData:
        updateHealthInfo()
        
      default: break
      }
    }
    
}
