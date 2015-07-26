//
//  DressListForProm.swift
//  PromApp
//
//  Created by Scott Krulcik on 12/29/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//
import ParseUI

class DressListForProm:PFQueryTableViewController{
    var prom:SKProm?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //Define values for super's fields
        parseClassName = SKDress.parseClassName()
        textKey = Dress_desingerKey
        pullToRefreshEnabled = true
        paginationEnabled = true //Save bandwith by loading a few at a time
        objectsPerPage = UInt(stdQueryLimit)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = SKColor.TableBackground()
        tableView.registerNib(UINib(nibName: dressCellNibName, bundle: nil), forCellReuseIdentifier: dressCellID)
    }
    
    override func queryForTable() -> PFQuery! {
        if prom != nil {
            let query = PFQuery(className: SKDress.parseClassName())
            query.limit = stdQueryLimit
            query.whereKey(Dress_promKey, equalTo: prom!)
            return query
        } else {
            let query = super.queryForTable()
            return query
        }
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!, object: PFObject!) -> PFTableViewCell! {
        if let cell = tableView.dequeueReusableCellWithIdentifier(dressCellID) as? SKDressInfoTableViewCell {
            if let dressPointer = object as? SKDress{
                fillDressCell(cell, withDress: dressPointer)
                return cell
            }
        }
        return super.tableView(tableView, cellForRowAtIndexPath: indexPath, object: object)
    }
    
    //External methods to fill cells with Parse data asynchronously to preserve flow with poor connection
    func fillDressCell(cell:SKDressInfoTableViewCell, withDress dressPointer:SKDress){
        dressPointer.fetchIfNeededInBackgroundWithBlock({
            (dressObj:PFObject!, error:NSError!) in
            if let dress = dressObj as? SKDress {
                cell.designerLabel!.text = dress.designer
                cell.styleNumberLabel!.text = dress.styleNumber
                // Fill in dress picture over time
                let dressImageView = cell.dressPicView
                if let dressPicFile = dress.objectForKey("imageThumbnail") as? PFFile{
                    dressPicFile.getDataInBackgroundWithBlock({
                        (imageData:NSData!, error:NSError!) in
                        if(imageData != nil){
                            let dressImage:UIImage = UIImage(data: imageData!)!
                            dressImageView!.image = dressImage
                        } else{
                            NSLog("Error retrieving image data from dress. PFFile:%@ Error:%@", dressPicFile, error)
                        }
                    })
                }
            }
        })
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(dressCellHeight)
    }
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(dressCellHeight)
    }
    
    //TODO: Allow selection to go to a dress detail view
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
