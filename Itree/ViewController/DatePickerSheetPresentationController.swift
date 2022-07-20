//
//  DatePickerSheetPresentationController.swift
//  Itree
//
//  Created by HAKKYU KIM on 2022/07/19.
//

import Foundation
import UIKit

// MARK: DatePickerSheetPresentationController

class DatePickerSheetPresentationController: UIViewController {
    lazy var datePicker: UIDatePicker = {
        let myDatePicker: UIDatePicker = UIDatePicker()
        myDatePicker.timeZone = NSTimeZone.local
        myDatePicker.preferredDatePickerStyle = .inline
        myDatePicker.tintColor = .black
        return myDatePicker
    }()
    
    lazy var dataFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateFormat = "yyyy/MM/dd - HH:mm "
        return formatter
    }()
    
    var okButtonClicked: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Date"
        
        view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 30),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 30)
        ])
        
        setupSheet()
        addNavigationBarButtonItem()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let dateLabel = ViewController.shared.dateLabel,
              let textField = ViewController.shared.textField else { return }
        
        if self.okButtonClicked {
            dateLabel.isHidden = false
            dateLabel.text = ViewController.dateString
            textField.placeholder = "할 일을 입력해주세요"
            okButtonClicked = false
        }
        else {
            return
        }
    }
    
    private func setupSheet() {
        isModalInPresentation = true
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.selectedDetentIdentifier = .medium
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersGrabberVisible = true
        }
    }
    
    private func addNavigationBarButtonItem() {
        let completedButton = UIBarButtonItem(title: "OK", primaryAction: .init(handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.okButtonClicked = true
            let datePickerdate = self.datePicker.date
            ViewController.date = datePickerdate
            ViewController.dateString = self.dataFormatter.string(from: datePickerdate)
            self.dismiss(animated: true, completion: nil)
        }))
        
        let cancelButton = UIBarButtonItem(title: "Cancel", primaryAction: .init(handler: { [weak self] _ in
            guard let self = self else { return }
        
            self.dismiss(animated: true, completion: nil)
        }))
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.leftBarButtonItem?.tintColor = .black
        navigationItem.rightBarButtonItem = completedButton
        navigationItem.rightBarButtonItem?.tintColor = .black
    }
}
