//
//  UITextFieldPicker.swift
//  UITextFieldPicker
//
//  Created by Manish Bhande on 07/01/17.
//  Copyright © 2017 Manish Bhande. All rights reserved.
//

import UIKit

enum UITextFieldPickerActionStyle: Int {
    case `default`
    case close
}

class UITextFieldPicker: UITextField {

    fileprivate var picker: UIPickerView? {
        didSet {
            self.inputView = picker
            picker?.reloadAllComponents()
        }
    }

    fileprivate var leftButton: PickerButton?
    fileprivate var rightButton: PickerButton?
    fileprivate var trackSelection: ((String?) -> Void)?
    var dataSet: [String] = [] {
        didSet {
            self.picker?.reloadAllComponents()
        }
    }

    fileprivate var selectedIndex: Int = -1

    weak var pickerDelegate: (UIPickerViewDelegate & UIPickerViewDataSource)? {
        didSet {
            self.picker?.delegate = pickerDelegate ?? self
            self.picker?.dataSource = pickerDelegate ?? self
            self.picker?.reloadAllComponents()
        }
    }

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

    var autoUpdate = false
    var defaultSelectedString: String?
    var selectedString: String? {
        if self.selectedIndex>=0, self.selectedIndex<self.dataSet.count, self.pickerDelegate == nil {
            return self.dataSet[self.selectedIndex]
        }
        return nil
    }
}

extension UITextFieldPicker {

    func setupPicker() {
        self.delegate = self
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        self.picker = picker
    }

    func setLeftButton(_ title: String, style: UITextFieldPickerActionStyle, handler: ((Void) -> Void)?) {

        let toolbar = self.toolBar
        self.leftButton = PickerButton(title: title, style: .plain, target: self, action:#selector(UITextFieldPicker.buttonAction))
        self.leftButton?.completionBlock = handler
        self.leftButton?.actionStyle = style
        if self.rightButton != nil {
            toolbar.items = [self.leftButton!, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), self.rightButton!]
        } else {
            toolbar.items = [self.leftButton!, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)]
        }
        toolbar.sizeToFit()
        self.inputAccessoryView = toolbar
    }

    func setRightButton(_ title: String, style: UITextFieldPickerActionStyle, handler: ((Void) -> Void)?) {

        let toolbar = self.toolBar
        self.rightButton = PickerButton(title: title, style: .plain, target: self, action:#selector(UITextFieldPicker.buttonAction))
        self.rightButton?.completionBlock = handler
        self.rightButton?.actionStyle = style

        if self.leftButton != nil {
            toolbar.items = [self.leftButton!, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), self.rightButton!]
        } else {
            toolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), self.rightButton!]
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

    func showDefaultString() { self.text = self.defaultSelectedString }

    func closePicker() { self.resignFirstResponder() }

    func trackPickerSelection(handler:@escaping (String?) -> Void) { self.trackSelection = handler }
}

extension UITextFieldPicker: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.dataSet[row]
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.dataSet.count
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedIndex = row
        if self.autoUpdate {
            self.text = self.selectedString
        }
        self.trackSelection?(self.selectedString)
    }
}

extension UITextFieldPicker: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.selectedIndex = 0
        if let index = self.dataSet.index(of: self.defaultSelectedString ?? "") {
            self.selectedIndex = index
        }
        self.picker?.reloadAllComponents()
        self.picker?.selectRow(self.selectedIndex, inComponent: 0, animated: false)
        self.trackSelection?(self.selectedString)
        if self.autoUpdate {
            self.text = self.selectedString
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {

    }
}

extension UITextFieldPicker {

    fileprivate struct KeyPath {
        static var Delegate: String { return "delegate" }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.addObserver(self, forKeyPath: KeyPath.Delegate, options: .new, context: nil)
        self.setupPicker()
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
    var completionBlock: ((Void) -> Void)?
    var actionStyle = UITextFieldPickerActionStyle.default
}
