//
//  Prom.swift
//  PromApp
//
//  Created by Scott Krulcik on 12/27/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

class Prom:PFObject, PFSubclassing{
    var schoolName = ""
    var address = ""
    var locationDescription = ""
    var time = ""
    var theme = ""
    var image:PFFile?
    var preciseLocation:PFGeoPoint?
    
    override init() {
        super.init()
    }
    
    //MARK: Class functions
    //MARK: PFSubclassing
    class func parseClassName() -> String! {
        return "Prom"
    }
    class func requiredKeys() -> Array<String>{
        return ["locationDescription","schoolName"]
    }
    
    //MARK: Dress Verification
    /* Checks with server to ensure this dress has not been registered for this prom yet */
    func verifyDesigner(designer:String, withStyle styleNumber:String)->Bool{
        let query = PFQuery(className: SKDress.parseClassName())
        query.whereKey("prom", equalTo: self)
        query.whereKey("designer", containsString: designer)
        query.whereKey("styleNumber", equalTo: styleNumber)
        let num_matches = query.countObjects()
        NSLog("Found %d matches for %@ %@. \n", num_matches, designer, styleNumber)
        return num_matches == 0
    }
    
    //MARK: Readability
    func readableInfo()->String{
        let info = String(format: "School:%@\nAddress:%@\nLocation:%@\nTime:%@\nTheme:%@\nCoordinates: \(self.preciseLocation?.description)", self.schoolName, self.address, self.locationDescription, self.time, self.theme)
        return info
    }
}
