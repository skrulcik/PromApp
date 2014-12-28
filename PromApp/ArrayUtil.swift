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
            return (self.objectId == pfobject.objectId)
        }
        return false
    }
}

