//
//  EqualityFunctions.swift
//  PromApp
//
//  Created by Scott Krulcik on 12/27/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

extension PFObject {
    public override func isEqual(object: AnyObject?) -> Bool {
        if let pfobject = object as? PFObject{
            //Ensure object is not null
            if let pfobjectId = pfobject.objectId{
                //objectId may be null if not yet saved
                return (self.objectId != nil && self.objectId == pfobjectId)
            }
        }
        return false
    }
}

