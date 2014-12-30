//
//  GlobalConstants.swift
//  PromApp
//
//  Created by Scott Krulcik on 12/18/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

import Foundation

//MARK: Cells
let profileCellHeight:Double = 190.0
let dressCellHeight:Double = 80.0
let headerHeight:CGFloat = 20.0

let dressCellNibName = "DressCell"
let dressCellID = "DressCell"
let profCellNibName = "ProfileCellLayout"
let profCellID = "ProfileCell"
let objectCellNibName = "ObjectCell"
let objectCellID = "ObjectCell"

//MARK: Keys - will be replaced when Swift model is implemented
let defaultName:String = "FirstName Last"
let dressKey:String = "dresses"
let promKey:String = "proms"
let nameKey:NSString = NSString(string: "name")
let userDataKey:String = "profile"
let picURLKey:NSString = NSString(string:"pictureURL")
let fbIDKey:String = "id"
let Prom_dressKey = "dresses"
let Dress_desingerKey = "designer"
let Dress_styleNumKey = "styleNumber"
let Dress_promKey = "prom"
let Dress_colorKey = "color"
let Dress_imageKey = "image"

//MARK: Images
let MAX_IMG_WIDTH = 400
let MAX_IMG_HEIGHT = 600

//MARK: Fonts
let smallFontSize:CGFloat = 16.0
let largeFontSize:CGFloat = 28.0

//MARK: Segues
let EditDressSegue = "EditDress"
let EditPromSegueID = "EditProm"
let NewPromSegueID = "NewProm"
let PromFromListSegueID = "ViewPromFromList"
let PromFromMapSegueID = "ViewPromFromMap"
let PromFromProfileID = "ViewPromFromProfile"
let DressesFromPromID = "ShowDressesFromProm"

//MARK: Queries
let arbitraryHighLimit = 3000
//Searchable tables will load a few, and incrementally more when user taps "load more"
let searchLimit = 10
let searchIncrement = 10
let stdQueryLimit = 25