//
//  UITextFieldDatePicker.swift
//  UITextFieldDatePicker
//
//  Created by Manish Bhande on 07/01/17.
//  Copyright © 2017 Manish Bhande. All rights reserved.
//

import UIKit

enum UITextFieldDatePickerActionStyle : Int {
    case `default`
    case close
}



class UITextFieldDatePicker: UITextField {
    lazy fileprivate var dateformatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM YYYY HH:MM:SSz"
        return formatter
    }()
    
    var datePicker: UIDatePicker! {
        guard let picker = self.inputView as? UIDatePicker else {
            self.inputView = UIDatePicker()
            return self.inputView as! UIDatePicker
        }
        return picker
    }
    
    fileprivate var leftButton: PickerButton?
    fileprivate var rightButton: PickerButton?
    
    fileprivate var toolBar: UIToolbar {
        guard let inputView = self.inputAccessoryView as? UIToolbar else {
            let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
            toolbar.barStyle = .default
            toolbar.sizeToFit()
            return toolbar
        }
        return inputView
    }
    
    /* User access properties*/
    
    var dateFormatDisplay: String = "dd MMMM YYYY HH:MM:SSz" {
        didSet {
            self.dateformatter.dateFormat = dateFormatDisplay
            if self.defaultSelectedDate != nil {
                self.text = self.dateformatter.string(from: self.defaultSelectedDate!)
            }
        }
    }
    
    var defaultSelectedDate: Date?
    var selectedDate: Date { return self.datePicker.date }
}

extension UITextFieldDatePicker {
    
    func setLeftButton(_ title: String, style: UITextFieldDatePickerActionStyle, handler:((Void) -> Void)?) {
        
        let toolbar = self.toolBar
        self.leftButton = PickerButton(title: title, style: .plain, target: self, action:#selector(UITextFieldDatePicker.buttonAction))
        self.leftButton?.completionBlock = handler
        self.leftButton?.actionStyle = style
        if self.rightButton != nil {
            toolbar.items = [self.leftButton!, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),self.rightButton!]
        } else {
            toolbar.items = [self.leftButton!, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)]
        }
        toolbar.sizeToFit()
        self.inputAccessoryView = toolbar
    }
    
    func setRightButton(_ title: String, style: UITextFieldDatePickerActionStyle, handler:((Void) -> Void)?) {
        
        let toolbar = self.toolBar
        self.rightButton = PickerButton(title: title, style: .plain, target: self, action:#selector(UITextFieldDatePicker.buttonAction))
        self.rightButton?.completionBlock = handler
        self.rightButton?.actionStyle = style
        
        if self.leftButton != nil {
            toolbar.items = [self.leftButton!, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),self.rightButton!]
        } else {
            toolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),self.rightButton!]
        }
        toolbar.sizeToFit()
        self.inputAccessoryView = toolbar
    }
    
    @objc fileprivate func buttonAction(sender: PickerButton) {
        if sender.actionStyle == .close {
            self.closePicker()
        }
        sender.completionBlock?()
    }
    
    func showDefaultDate(){
        if self.defaultSelectedDate != nil {
            self.text = self.dateformatter.string(from: self.defaultSelectedDate!)
            
        } else { self.text = nil }
    }
    
    func closePicker(){ self.resignFirstResponder() }
}


extension UITextFieldDatePicker: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if self.defaultSelectedDate != nil {
            self.text = self.dateformatter.string(from: self.defaultSelectedDate!)
            self.datePicker.date = self.defaultSelectedDate!
            
        } else { self.text = nil }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        
    }
}

extension UITextFieldDatePicker {
    
    fileprivate struct KeyPath {
        static var Delegate: String { return "delegate" }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
        self.addObserver(self, forKeyPath: KeyPath.Delegate, options: .new, context: nil)
        self.datePicker.datePickerMode = .dateAndTime
    }
    
    // Disable paste
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(UIResponderStandardEditActions.paste(_:)) ? false : super.canPerformAction(action, withSender: sender)
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == KeyPath.Delegate {
            self.removeObserver(self, forKeyPath: KeyPath.Delegate, context: nil)
            self.delegate = self
            self.addObserver(self, forKeyPath: KeyPath.Delegate, options: .new, context: nil)
        }
    }
}


fileprivate class PickerButton: UIBarButtonItem {
    var completionBlock: ((Void)-> Void)?
    var actionStyle = UITextFieldDatePickerActionStyle.default
}
