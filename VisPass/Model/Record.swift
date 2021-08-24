//
//  Record.swift
//  VisPass
//
//  Created by Nevzat TUFEKCI.
//

import Foundation

class Record: NSObject, NSCoding {

    var id: String?
    var title: String?
    var password: String?
    var additionalData: String?
    var imageAuthenticationEnabled: Bool?
    var imageAuthenticationHash: String?
    var imageName: String?
    var touchCount: Int?
    var createdDate: Date?

    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(title, forKey: "title")
        coder.encode(password, forKey: "password")
        coder.encode(additionalData, forKey: "additionalData")
        coder.encode(imageAuthenticationEnabled, forKey: "imageAuthenticationEnabled")
        coder.encode(imageAuthenticationHash, forKey: "imageAuthenticationHash")
        coder.encode(imageName, forKey: "imageName")
        coder.encode(touchCount, forKey: "touchCount")
        coder.encode(createdDate, forKey: "createdDate")
    }

    required init?(coder: NSCoder) {
        id = coder.decodeObject(forKey: "id") as? String ?? ""
        title = coder.decodeObject(forKey: "title") as? String ?? ""
        password = coder.decodeObject(forKey: "password") as? String ?? ""
        additionalData = coder.decodeObject(forKey: "additionalData") as? String ?? ""
        imageAuthenticationEnabled = coder.decodeObject(forKey: "imageAuthenticationEnabled") as? Bool ?? false
        imageAuthenticationHash = coder.decodeObject(forKey: "imageAuthenticationHash") as? String ?? ""
        imageName = coder.decodeObject(forKey: "imageName") as? String ?? ""
        touchCount = coder.decodeObject(forKey: "touchCount") as? Int ?? 0
        createdDate = coder.decodeObject(forKey: "createdDate") as? Date ?? Date()
        super.init()
    }
    
    override init() {
        super.init()
    }
    
    init(id: String?,
         title: String?,
         imageAuthenticationHash: String?,
         password: String?,
         additionalData: String?,
         imageName: String?,
         imageAuthenticationEnabled: Bool?,
         touchCount: Int?,
         createdDate: Date?) {
        super.init()
        self.id = id
        self.title = title
        self.imageAuthenticationHash = imageAuthenticationHash
        self.password = password
        self.additionalData = additionalData
        self.imageName = imageName
        self.imageAuthenticationEnabled = imageAuthenticationEnabled
        self.touchCount = touchCount
        self.createdDate = createdDate
    }
    
}
