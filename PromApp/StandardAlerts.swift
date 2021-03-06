//
//  StandardAlerts.swift
//  PromApp
//
//  Created by Scott Krulcik on 12/27/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//


enum StandardAlertType{
    case MissingRequiredField
    case FailedSave
    case Default
    case LoginError
}

let titleForAlert:Dictionary<StandardAlertType, String!> = [
                        .MissingRequiredField:"Missing Required Field",
                        .FailedSave:"Could not save changes.",
                        .Default:"Alert",
                        .LoginError:"Login Error"
                    ]
let defaultMessage = "Something went wrong."

func throwAlert(fromPresenter presenter:UIViewController,
                    ofType type:StandardAlertType,
                    withArg str:String = defaultMessage){
    var title:String?
    var message:String?
    switch type{
        case .MissingRequiredField:
            title = titleForAlert[.MissingRequiredField]
            if str != defaultMessage {
                message = "\(str) is a required field."
            } else {
                message = "Missing a required field"
        }
        default:
            title = titleForAlert[type]
            message = "Something went wrong."
    }
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    let cancel = UIAlertAction(title: "Okay", style: .Cancel, handler: {
            (action:UIAlertAction!) in
            alert.dismissViewControllerAnimated(true, completion: nil)
        })
    alert.addAction(cancel)
    
    presenter.presentViewController(alert, animated: true, completion: nil)
}