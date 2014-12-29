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
    var proms:Array<SKProm>{
        get{
            if let objects = objectForKey(promKey) as? Array<SKProm>{
                return objects
            }
            return []
        }
    }
    
    
    func isFollowingProm(prom:SKProm)->Bool{
        //return contains(proms as Array<PFObject>, prom as PFObject)
        //FIXME: The following is a temporary patch until SKPromFinder is permanently replaced
        for existing in proms{
            if existing.equalTo(prom) {
                return true
            }
        }
        return false
    }
    func hasSpecificDress(dress:SKDress)->Bool{
        let obj = dress as PFObject //PFObjects are definitely Equatable (necessary for contains)
        if let objects = objectForKey(dressKey) as? Array<PFObject>{
            return contains(objects, obj)
        }
        return false
    }
    func hasDressWithData(dress:SKDress)->Bool{
        for existing in self.dresses{
            if existing.isSimilar(dress){
                return true
            }
        }
        return false
    }
}
