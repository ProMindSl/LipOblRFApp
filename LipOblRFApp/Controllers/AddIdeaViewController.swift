//
//  AddIdeaViewController.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 14/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import UIKit
import MapKit

class AddIdeaViewController: UITableViewController
{

    // outlets
    @IBOutlet weak var tfIdeaScope: UITextField!
    @IBOutlet weak var tfMapSearch: UITextField!
    @IBOutlet weak var mvIdeaLocation: MKMapView!
    @IBOutlet weak var tfIdeaTitle: UITextField!
    @IBOutlet weak var tfIdeaTxtBody: UITextField!
    @IBOutlet weak var btnAddIdea: UIButton!
    @IBOutlet weak var btnAddFiles: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    
    // type picker vars
    var picker: TypePickerView?
    var pickerAccessory: UIToolbar?
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initUI()
        
    }
    
    /*
     *   -------- Public func ----------
    **/
    
    
    /*
     *   -------- Privete func ----------
    **/
    private func initUI()
    {
        // init picker
        picker = TypePickerView()
        picker?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        picker?.backgroundColor = UIColor.white
        picker?.data = ["Бизнес", "Благо­­устрой­­ство", "Борьба с коррупцией", "Демография", "Дороги и транспорт"]
        
        tfIdeaScope.inputView = picker
        
        pickerAccessory = UIToolbar()
        pickerAccessory?.autoresizingMask = .flexibleHeight
        
        //this customization is optional
        pickerAccessory?.barStyle = .default
        pickerAccessory?.barTintColor = UIColor.blue
        pickerAccessory?.backgroundColor = UIColor.blue
        pickerAccessory?.isTranslucent = false
        var frame = pickerAccessory?.frame
        frame?.size.height = 44.0
        pickerAccessory?.frame = frame!
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(AddIdeaViewController.cancelBtnClicked(_:)))
        cancelButton.tintColor = UIColor.white
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) //a flexible space between the two buttons
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(AddIdeaViewController.doneBtnClicked(_:)))
        doneButton.tintColor = UIColor.white
        //Add the items to the toolbar
        pickerAccessory?.items = [cancelButton, flexSpace, doneButton]
        tfIdeaScope.inputAccessoryView = pickerAccessory
        

        
    }

    /**
     Called when the cancel button of the `pickerAccessory` was clicked. Dismsses the picker
     */
    @objc func cancelBtnClicked(_ button: UIBarButtonItem?)
    {
        tfIdeaScope?.resignFirstResponder()
    }
    
    /**
     Called when the done button of the `pickerAccessory` was clicked. Dismisses the picker and puts the selected value into the textField
     */
    @objc func doneBtnClicked(_ button: UIBarButtonItem?)
    {
        tfIdeaScope?.resignFirstResponder()
        tfIdeaScope.text = picker?.selectedValue
    }
    
}
