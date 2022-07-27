//
//  DatePickerSheetPresentationController.swift
//  Itree
//
//  Created by HAKKYU KIM on 2022/07/19.
//

import Foundation
import UIKit

protocol UIDatePickerSheetProtocol: AnyObject {
    func tappedOKButton(_ viewController: DatePickerSheetPresentationController)
}

// MARK: DatePickerSheetPresentationController

class DatePickerSheetPresentationController: UIViewController {
    
    init(context: Context) {
        super.init(nibName: nil, bundle: nil)
        self.context = context
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var date: Date!
    var datePicker: UIDatePicker!
    var okButtonClicked: Bool = false
    var context: Context!
    var homeViewController: HomeViewController?
    var delegate: UIDatePickerSheetProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = context.title
        datePicker = context.datePicker
        homeViewController = HomeViewController.create()
        
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
            self.date = self.datePicker.date
            self.dismiss(animated: true, completion: nil)
            self.delegate?.tappedOKButton(self)
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
