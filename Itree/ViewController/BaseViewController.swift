//
//  BaseViewController.swift
//  Itree
//
//  Created by HAKKYU KIM on 2022/07/18.
//

import UIKit

// MARK: BaseViewController

class BaseViewController: UIViewController {
    private(set) var isHiddenKeyboard: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(_willShowKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_willHideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    private func _willShowKeyboard(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        isHiddenKeyboard = false
        willShowKeyboard(frame: keyboardFrame.cgRectValue)
        willChangeKeyboard(isHidden: false)
    }
    
    @objc
    func willShowKeyboard(frame: CGRect) {
        
    }
    
    @objc
    private func _willHideKeyboard() {
        isHiddenKeyboard = true
        willHideKeyboard()
        willChangeKeyboard(isHidden: true)
    }
    
    @objc
    func willHideKeyboard() {
        
    }
    
    func willChangeKeyboard(isHidden: Bool) {
        
    }
    
}


