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
    
    init(context: Context) {
        super.init(nibName: nil, bundle: nil)
        self.context = context
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var datePicker: UIDatePicker!
    var dateString: String!
    var okButtonClicked: Bool = false
    var context: Context!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = context.title
        datePicker = context.datePicker
        
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
        guard let dateLabel = HomeViewController.create().dateLabel,
              let textField = HomeViewController.create().textField else { return }

        if self.okButtonClicked {
            dateLabel.isHidden = false
            dateLabel.text = dateString
            textField.placeholder = "할 일을 입력해주세요"
            okButtonClicked = false
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
        let viewController = HomeViewController.create()
        let completedButton = UIBarButtonItem(title: "OK", primaryAction: .init(handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.okButtonClicked = true
            viewController.date = self.datePicker.date
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
