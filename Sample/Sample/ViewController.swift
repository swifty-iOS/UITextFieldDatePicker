//
//  ViewController.swift
//  Sample
//
//  Created by Manish Bhande on 08/01/17.
//  Copyright © 2017 Manish Bhande. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textFieldDate: UITextFieldDatePicker!
    @IBOutlet weak var textFieldTime: UITextFieldDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.setupTime()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup(){
        self.textFieldDate.datePicker.minimumDate = Date().addingTimeInterval(10*24*60*60*(-1))
        self.textFieldDate.datePicker.maximumDate = Date().addingTimeInterval(10*24*60*60)
        
        self.textFieldDate.setLeftButton("Cancel", style: .close) {
            self.textFieldDate.defaultSelectedDate = nil
            self.textFieldDate.showDefaultDate()
        }
        
        self.textFieldDate.setRightButton("Done", style: .default) {
           self.textFieldDate.defaultSelectedDate = self.textFieldDate.selectedDate
            self.textFieldDate.showDefaultDate()
            self.textFieldDate.closePicker()
        }
    }
    
    
    func setupTime(){
        
        self.textFieldTime.datePicker.datePickerMode = .time
        self.textFieldTime.dateFormatDisplay = "HH:mm:ss"
        
        self.textFieldTime.setLeftButton("Cancel", style: .close) {
            self.textFieldTime.showDefaultDate()
        }
        
        self.textFieldTime.setRightButton("Done", style: .default) {
            self.textFieldTime.defaultSelectedDate = self.textFieldDate.selectedDate
            self.textFieldTime.showDefaultDate()
            self.textFieldTime.closePicker()
        }
    }
    
    
    
}

