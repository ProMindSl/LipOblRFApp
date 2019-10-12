//
//  TypePickerView.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 17/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import UIKit

class TypePickerView: UIPickerView,
                      UIPickerViewDataSource,
                      UIPickerViewDelegate
{
    /*
     *   -------- Public vars ----------
    **/
    public var data: [String]?
    {
        didSet
        {
            super.delegate = self
            super.dataSource = self
            self.reloadAllComponents()
        }
    }
    
    public var textFieldBeingEdited: UITextField?
    
    public var selectedValue: String
    {
        get
        {
            if data != nil
            {
                return data![selectedRow(inComponent: 0)]
            }
            else
            {
                return ""
            }
        }
    }

    /*
     *   -------- Public func ----------
    **/
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if data != nil
        {
            return data!.count
        }
        else
        {
            return 0
        }
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if data != nil
        {
            return data![row]
        }
        else
        {
            return ""
        }
    }
    
    
    

}
