//
//  UserExt.swift
//  PromApp
//
//  Created by Scott Krulcik on 12/28/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

extension PFUser{
    var dresses:Array<SKDress>{
        get{
            if let objects = objectForKey(dressKey) as? Array<SKDress>{
                return objects
            }
            return []
        }
    }
    var proms: [SKProm] {
        get{
            if let objects = objectForKey(promKey) as? Array<SKProm>{
                return objects
            }
            return []
        }
    }
    
    
    func isFollowingProm(prom: SKProm) -> Bool {
        let promObj = prom as PFObject
        let promObjs = proms as [PFObject]
        return promObjs.contains(promObj)
    }

    func hasSpecificDress(dress: SKDress) -> Bool {
        let obj = dress as PFObject //PFObjects are definitely Equatable (necessary for contains)
        if let objects = objectForKey(dressKey) as? [PFObject]{
            return objects.contains(obj)
        }
        return false
    }

    func hasDressWithData(dress: SKDress) -> Bool {
        for existing in self.dresses{
            if existing.isSimilar(dress){
                return true
            }
        }
        return false
    }
}
