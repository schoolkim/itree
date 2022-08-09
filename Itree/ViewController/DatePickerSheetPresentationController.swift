//
//  DatePickerSheetPresentationController.swift
//  Itree
//
//  Created by HAKKYU KIM on 2022/07/19.
//

import Foundation
import UIKit
import SnapKit

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
        datePicker.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.snp.bottom).offset(30)
            make.top.equalTo(view.snp.top).offset(30)
        }
        
        setupSheet()
        addNavigationBarButtonItem()
    }
    
    private func setupSheet() {
        isModalInPresentation = true
        if let sheet = sheetPresentationController {
            sheet.do {
                $0.detents = [.medium()]
                $0.selectedDetentIdentifier = .medium
                $0.largestUndimmedDetentIdentifier = .medium
                $0.prefersScrollingExpandsWhenScrolledToEdge = false
                $0.prefersGrabberVisible = true
            }
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
        
        navigationItem.do {
            $0.leftBarButtonItem = cancelButton
            $0.leftBarButtonItem?.tintColor = .black
            $0.rightBarButtonItem = completedButton
            $0.rightBarButtonItem?.tintColor = .black
        }
    }
}
