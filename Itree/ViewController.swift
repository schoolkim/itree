//
//  ViewController.swift
//  Itree
//
//  Created by HAKKYU KIM on 2022/05/17.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var topicContainerView: UIView!
    @IBOutlet weak var addToDoButton: UIButton!
    @IBOutlet weak var textFieldContainerView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var topicViewController: TopicViewController?
    var collectionViewDataSource: UICollectionViewDiffableDataSource<Section, Todo>!
    
    var date: Date!
    
    var topicDataStore = ["All", "Today", "This Week", "This Month"]
    var selectedString: String!
    var contentConfiguration: UIListContentConfiguration!
    var coreDataStore = CoreDataStore.shared
    var filteredDataStore = [Todo]()
    var isFiltering: Bool {
        let searchController = self.navigationItem.searchController
        let isActive = searchController?.isActive ?? false
        let hasText = searchController?.searchBar.text?.isEmpty == false
        return isActive && hasText
    }
    
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.dateFormat = "yyyy년 MM월 dd일 HH시 mm분"
        return formatter
    }()
    
    var notificationDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.dateFormat = "yyyy년 MM월 dd일 HH시 mm분 ss초"
        return formatter
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        textFieldContainerView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        
        topicViewController?.applyInitialData(items: topicDataStore)
        let label = createTitleLabel()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
        
        dateLabel.textColor = .label
        dateLabel.font = UIFont.boldSystemFont(ofSize: 15)
        
        addToDoButton.layer.cornerRadius = 0.5 * addToDoButton.bounds.width
        addToDoButton.clipsToBounds = true

        createDatePickerView()
        setupSearchController()
        configureCollectionViewLayout()
        configureCollectionViewDataSource()
        
        var snapshot = collectionViewDataSource.snapshot()
        snapshot.appendSections([.Main])
        coreDataStore.updateTodo()
        snapshot.appendItems(sort())
        collectionViewDataSource.apply(snapshot)
        
        selectedString = "All"
        textField.placeholder = "날짜와 시간을 선택해주세요"
    }
    
    @IBSegueAction func segueTopicViewController(_ coder: NSCoder) -> TopicViewController? {
        let viewController = TopicViewController(coder: coder)
        viewController?.eventDelegate = self
        self.topicViewController = viewController
        return viewController
    }
    
    @IBAction func tappedAddToDoButton(_ sender: Any) {
        if !textField.isFirstResponder {
            textField.becomeFirstResponder()
            UIView.animate(withDuration: 0.5) {
                self.addToDoButton.transform = .init(rotationAngle: 45 / 180 * .pi)
            }
            
        } else {
            textField.resignFirstResponder()
            UIView.animate(withDuration: 0.5) {
                self.addToDoButton.transform = .identity
            }
            self.dateLabel.text = ""
            self.textField.text = ""
        }
    }

    @objc func tappedDateButton() {
        
        let myDatePicker = createDatePicker()
        let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n\n\n\t\t\t\t", message: nil, preferredStyle: .alert)
        alertController.view.addSubview(myDatePicker)
        let somethingAction = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            let formatter = DateFormatter()
            formatter.timeStyle = .none
            formatter.dateFormat = "yyyy/MM/dd - HH:mm "
            self.date = myDatePicker.date
            let date = formatter.string(from: myDatePicker.date)
            self.dateLabel.text = date
            self.textField.placeholder = "할 일을 입력해주세요"
            self.textField.becomeFirstResponder()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(somethingAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion:{})
    }
    
    @objc func tappedTodayButton() {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateFormat = "yyyy/MM/dd"
        dateLabel.text = formatter.string(from: .now)
        
        let todayAlert = UIAlertController(title: "시간을 선택해주세요\n\n", message: nil, preferredStyle: .alert)
        let todayPicker = UIDatePicker()
        todayPicker.datePickerMode = .time
        todayPicker.bounds = CGRect(x: 5, y: -55, width:200, height: 50)
        todayAlert.view.addSubview(todayPicker)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            let formatter = DateFormatter()
            formatter.timeStyle = .none
            formatter.dateFormat = " - HH:mm "
            self.date = todayPicker.date
            let date = formatter.string(from: todayPicker.date)
            self.dateLabel.text = (self.dateLabel.text ?? "") + date
            self.textField.placeholder = "할 일을 입력해주세요"
        }
        todayAlert.addAction(cancel)
        todayAlert.addAction(ok)
        self.present(todayAlert, animated: false)
    }
    
    @objc func tappedDoneButton() {
        guard let filterText = Filter(rawValue: selectedString) else { return }
        
        if self.dateLabel.text == "" {
            let alert = UIAlertController(title: "날짜와 시간을 선택해주세요", message: "", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "확인", style: .cancel)
            alert.addAction(cancel)
            self.present(alert, animated: false)
            return
        } else if self.textField.text == "" {
            textField.text = ""
            let alert = UIAlertController(title: "할 일을 입력해주세요", message: "", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "확인", style: .cancel)
            alert.addAction(cancel)
            self.present(alert, animated: false)
            return
        }
        
        let resultString = self.textField.text
        self.coreDataStore.createTodo(text: resultString ?? "", date: date)
        textField.resignFirstResponder()
        self.textField.text = ""
        UIView.animate(withDuration: 0.5) {
            self.addToDoButton.transform = .identity
        }
        
        configureSnapshot(filterText)
        self.dateLabel.text = ""
        self.textField.placeholder = "날짜와 시간을 선택해주세요"
    }
    
    func configureSnapshot(_ selectedString: Filter) {
        var snapshot = collectionViewDataSource.snapshot()
        snapshot.deleteItems(coreDataStore.fetchTodo())
        switch selectedString {
        case .All:
            snapshot.appendItems(self.sort())
        case .Today:
            snapshot.appendItems(filteredToday(self.sort()))
        case .Week:
            snapshot.appendItems(filteredWeek(self.sort()))
        case .Month:
            snapshot.appendItems(filteredMonth(self.sort()))
        }
        collectionViewDataSource.apply(snapshot)
    }
    
    func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .label
        label.text = "Itree"
        label.font = UIFont(name: "Unreal_science_yuni", size: 40)
        return label
    }
    
    func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
   
    func configureCollectionViewLayout() {
        
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        layoutConfig.backgroundColor = .systemBackground
        layoutConfig.trailingSwipeActionsConfigurationProvider = {
            [weak self] indexPath in
            
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completion in
                guard let self = self,
                      let selectedTodo = self.collectionViewDataSource.itemIdentifier(for: indexPath),
                      let uuid = self.collectionViewDataSource.itemIdentifier(for: indexPath)?.uuid?.uuidString else {
                    completion(false)
                    return
                }
                
                self.coreDataStore.deleteTodo(object: selectedTodo)
                
                var snapshot = self.collectionViewDataSource.snapshot()
                snapshot.deleteItems([selectedTodo])
                self.collectionViewDataSource.apply(snapshot, animatingDifferences: true) {
                    completion(true)
                }
                
                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [uuid])
            }
            
            let fixAction = UIContextualAction(style: .normal, title: "Fix") { [weak self] action, view, completion in
                guard let self = self,
                      let selectedTodo = self.collectionViewDataSource.itemIdentifier(for: indexPath) else {
                    completion(false)
                    return
                }
                
                selectedTodo.fix.toggle()
                selectedTodo.updateAt = Date()
                self.coreDataStore.saveContext()
                
                var snapshot = self.collectionViewDataSource.snapshot()
                snapshot.reconfigureItems([selectedTodo])
                snapshot.deleteItems(self.coreDataStore.fetchTodo())
                snapshot.appendItems(self.sort())
                self.collectionViewDataSource.apply(snapshot, animatingDifferences: true) {
                    self.collectionView.deselectItem(at: indexPath, animated: true)
                    completion(true)
                }
            }
            
            let unFixAction = UIContextualAction(style: .normal, title: "UnFix") { [weak self] action, view, completion in
                guard let self = self,
                      let selectedTodo = self.collectionViewDataSource.itemIdentifier(for: indexPath) else {
                    completion(false)
                    return
                }
                
                selectedTodo.fix.toggle()
                selectedTodo.updateAt = Date()
                self.coreDataStore.saveContext()
                
                var snapshot = self.collectionViewDataSource.snapshot()
                snapshot.reconfigureItems([selectedTodo])
                snapshot.deleteItems(self.coreDataStore.fetchTodo())
                snapshot.appendItems(self.sort())
                self.collectionViewDataSource.apply(snapshot, animatingDifferences: true) {
                    self.collectionView.deselectItem(at: indexPath, animated: true)
                    completion(true)
                }
            }
            
            return self?.collectionViewDataSource.itemIdentifier(for: indexPath)?.fix ?? false ? UISwipeActionsConfiguration(actions: [deleteAction, unFixAction]) : UISwipeActionsConfiguration(actions: [deleteAction, fixAction])
        }
        
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        collectionView.collectionViewLayout = listLayout
    }
    
    func configureCollectionViewDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Todo>.init { [weak self] cell, indexPath, itemIdentifier in
            
            guard let self = self else { return }
            
            self.contentConfiguration = cell.defaultContentConfiguration()
            self.contentConfiguration.imageProperties.tintColor = .black
            self.contentConfiguration.image = itemIdentifier.fix ? UIImage(systemName: "pin.fill") : nil
            
            if itemIdentifier.completed {
                self.contentConfiguration.attributedText = itemIdentifier.content?.strikeThrough()
            } else {
                self.contentConfiguration.text = itemIdentifier.content
                self.contentConfiguration.attributedText = nil
            }
            
            if let todoAt = itemIdentifier.todoAt {
                self.contentConfiguration.secondaryText = itemIdentifier.fix ? "Every Day" : self.dateFormatter.string(from: todoAt)
            }
            self.contentConfiguration.secondaryTextProperties.color = .secondaryLabel
            cell.contentConfiguration = self.contentConfiguration
        }
        
        collectionViewDataSource = .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            
            return cell
        }
    }
    
    func createDatePicker() -> UIDatePicker {
        let myDatePicker: UIDatePicker = UIDatePicker()
        myDatePicker.timeZone = NSTimeZone.local
        myDatePicker.preferredDatePickerStyle = .inline
        myDatePicker.frame = CGRect(x: 15, y: 15, width: 250, height: 350)
        myDatePicker.tintColor = .black
        return myDatePicker
    }
    
    func createDatePickerView() {
        let toolbar = UIToolbar()
        let calendarImage = UIImage(systemName: "calendar")
        let dateButton = UIBarButtonItem(image: calendarImage, style: .plain, target: nil, action: #selector(tappedDateButton))
        let todayButton = UIBarButtonItem(title: "today", style: .plain , target: nil, action: #selector(tappedTodayButton))
        let leftSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "done", style: .plain, target: nil, action: #selector(tappedDoneButton))
        var buttonList = [UIBarButtonItem]()
        
        buttonList.append(dateButton)
        buttonList.append(todayButton)
        buttonList.append(leftSpace)
        buttonList.append(doneButton)
        
        buttonList.forEach { bt in
            bt.tintColor = .black
        }
        
        toolbar.sizeToFit()
        toolbar.setItems(buttonList, animated: false)
        textField.inputAccessoryView = toolbar
    }
}

extension ViewController: TopicViewControllerEvent {
    func topic(_ viewController: TopicViewController, didSelectedItem: String) {
        guard let text = self.navigationItem.searchController?.searchBar.text,
              let filterText = Filter(rawValue: didSelectedItem) else { return }
        
        var snapshot = collectionViewDataSource.snapshot()
        snapshot.deleteItems(coreDataStore.fetchTodo())
        switch filterText {
        case .All:
            if self.navigationItem.searchController?.isActive ?? false {
                snapshot.appendItems(self.sort().filter { element in
                    let content = element.content ?? ""
                    return content.localizedCaseInsensitiveContains(text)
                })
            } else {
                snapshot.appendItems(self.sort())
            }
        case .Today:
            if self.navigationItem.searchController?.isActive ?? false {
                snapshot.appendItems(filteredToday(self.sort()).filter { element in
                    let content = element.content ?? ""
                    return content.localizedCaseInsensitiveContains(text)
                })
            } else {
                snapshot.appendItems(filteredToday(self.sort()))
            }
        case .Week:
            if self.navigationItem.searchController?.isActive ?? false {
                snapshot.appendItems(filteredWeek(self.sort()).filter { element in
                    let content = element.content ?? ""
                    return content.localizedCaseInsensitiveContains(text)
                })
            } else {
                snapshot.appendItems(filteredWeek(self.sort()))
            }
        case .Month:
            if self.navigationItem.searchController?.isActive ?? false {
                snapshot.appendItems(filteredMonth(self.sort()).filter { element in
                    let content = element.content ?? ""
                    return content.localizedCaseInsensitiveContains(text)
                })
            } else {
                snapshot.appendItems(filteredMonth(self.sort()))
            }
        }
        collectionViewDataSource.apply(snapshot)
    }
    
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedTodo = collectionViewDataSource.itemIdentifier(for: indexPath) else { return }
        
        selectedTodo.completed.toggle()
        selectedTodo.updateAt = Date()
        coreDataStore.saveContext()
        
        var snapshot = collectionViewDataSource.snapshot()
        snapshot.reconfigureItems([selectedTodo])
        collectionViewDataSource.apply(snapshot, animatingDifferences: true) {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        
    }
    
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = self.navigationItem.searchController?.searchBar.text,
              let filterText = Filter(rawValue: selectedString) else { return }
        
        if self.isFiltering || self.navigationItem.searchController?.isActive ?? false {
            self.addToDoButton.isHidden = true
            switch filterText {
            case .All:
                filteredDataStore = self.sort().filter { element in
                    let content = element.content ?? ""
                    return content.localizedCaseInsensitiveContains(text)
                }
            case .Today:
                filteredDataStore = filteredToday(self.sort()).filter { element in
                    let content = element.content ?? ""
                    return content.localizedCaseInsensitiveContains(text)
                }
            case .Week:
                filteredDataStore = filteredWeek(self.sort()).filter { element in
                    let content = element.content ?? ""
                    return content.localizedCaseInsensitiveContains(text)
                }
            case .Month:
                filteredDataStore = filteredMonth(self.sort()).filter { element in
                    let content = element.content ?? ""
                    return content.localizedCaseInsensitiveContains(text)
                }
            }
            var snapshot = collectionViewDataSource.snapshot()
            snapshot.deleteItems(coreDataStore.fetchTodo())
            snapshot.appendItems(filteredDataStore)
            collectionViewDataSource.apply(snapshot)
        } else {
            self.addToDoButton.isHidden = false
            var snapshot = collectionViewDataSource.snapshot()
            snapshot.deleteItems(coreDataStore.fetchTodo())
            switch filterText {
            case .All:
                snapshot.appendItems(self.sort())
            case .Today:
                snapshot.appendItems(filteredToday(self.sort()))
            case .Week:
                snapshot.appendItems(filteredWeek(self.sort()))
            case .Month:
                snapshot.appendItems(filteredMonth(self.sort()))
            }
            collectionViewDataSource.apply(snapshot)
        }
    }
}

extension ViewController {
    func filteredToday(_ array: [Todo]) -> [Todo] {
        return array.filter {
            ($0.todoAt?.day == Date().day && $0.todoAt?.month == Date().month) || $0.fix
        }
    }
    
    func filteredWeek(_ array: [Todo]) -> [Todo] {
        return array.filter {
            ($0.todoAt?.week == Date().week) || $0.fix
        }
    }
    
    func filteredMonth(_ array: [Todo]) -> [Todo] {
        return array.filter {
            ($0.todoAt?.month == Date().month) || $0.fix
        }
    }
    
    func sort() -> [Todo] {
        var array = coreDataStore.fetchTodo()
        array.sort { current, next in
            if current.fix && !next.fix {
                return true
            } else {
                return false
            }
        }
        return array
    }
}
