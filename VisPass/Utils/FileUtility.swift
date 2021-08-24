//
//  FileUtility.swift
//  VisPass
//
//  Created by Nevzat TUFEKCI.
//
// Inspired from https://stackoverflow.com/questions/37344822/saving-image-and-then-loading-it-in-swift-ios

import Foundation
import UIKit

class FileUtility {
    
    static let sharedInstance = FileUtility()
    
    func getDocumentsDirectory(directory: FileManager.SearchPathDirectory) -> URL {
        return FileManager.default.urls(for: directory, in: .userDomainMask).first!
    }
    
    @discardableResult
    func writeImgetoResources(directory: FileManager.SearchPathDirectory, image: UIImage, imageName: String) -> Bool {
        var binaryImageData: Data?
        binaryImageData = image.pngData()
        let filename = getDocumentsDirectory(directory: directory).appendingPathComponent(imageName)
        do {
            try binaryImageData?.write(to: filename)
            return true
        }
        catch let error as NSError {
            print(error)
            return false
        }
    }
    
    func readImageFromResources(directory: FileManager.SearchPathDirectory, imageName: String) -> UIImage? {
        return UIImage(contentsOfFile: getDocumentsDirectory(directory: directory).appendingPathComponent(imageName).path ) ?? nil
    }

}
