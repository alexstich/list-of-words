//
//  DataProviderConfiguration.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 18.02.24.
//

import Foundation

struct DataProviderConfiguration 
{
    let fileURL: URL
    
    static var shared: DataProviderConfiguration = {
        
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
              let fileName = plist["fileName"] as? String,
              let fileExtension = plist["fileExtension"] as? String else {
            fatalError("An error occurred during loading Config.plist")
        }
        
        if let fileUrl = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent(fileName + "." + fileExtension) {
            
            return DataProviderConfiguration(fileURL: fileUrl)
        }

        fatalError("An error occurred during loading Config.plist")
    }()
}
