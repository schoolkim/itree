//
//  ViewController.swift
//  Itree
//
//  Created by HAKKYU KIM on 2022/05/17.
//

import UIKit
import Then

// MARK: ViewController

class HomeViewController: BaseViewController {
    @IBOutlet weak var addToDoButton: UIButton!
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var topicContainerView: UIView!
    
    // MARK: Internal
    
    weak var topicViewController: TopicViewController?
    var collectionViewDataSource: UICollectionViewDiffableDataSource<Section, Todo>!
    var selectedFilter: Filter!
    var contentConfiguration: UIListContentConfiguration!
    var addTodoButtonBottomConstraint: NSLayoutConstraint?
    var coreDataStore = CoreDataStore.shared
    var filteredDataStore = [Todo]()
    var date: Date!
    
    var isSearchControllerFiltering: Bool {
        guard let searchController = self.navigationItem.searchController,
              let searchBarText = self.navigationItem.searchController?.searchBar.text else { return false }
        
        let isActive = searchController.isActive
        let hasText = searchBarText.isEmpty == false
        return isActive && hasText
    }
    
    var topicDataStore: [Filter] = {
        Filter.allCases
    }()
    
    var collectionViewCellSecondaryTextFormatter = DateFormatter().then {
        $0.dateStyle = .none
        $0.dateFormat = "yyyy년 MM월 dd일 HH시 mm분"
    }
    
    var dateLabelTextFormatter = DateFormatter().then {
        $0.timeStyle = .none
        $0.dateFormat = "yyyy/MM/dd - HH:mm "
    }
    
    var notificationDateFormatter = DateFormatter().then {
        $0.dateStyle = .none
        $0.dateFormat = "yyyy년 MM월 dd일 HH시 mm분 ss초"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTodoButtonBottomConstraint = addToDoButton.bottomAnchor.constraint(equalTo: bottomStackView.topAnchor, constant: -8)
        addTodoButtonBottomConstraint?.priority = .defaultHigh
        bottomStackView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        topicViewController?.applyInitialData(items: topicDataStore)
        let label = createTitleLabel()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
        let addTodoButtonBottomKeyboardConstraint = addToDoButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -8)
        
        addTodoButtonBottomKeyboardConstraint.do {
            $0.priority = .defaultLow
            $0.isActive = true
        }
        
        dateLabel.do {
            $0.textColor = .label
            $0.font = UIFont.boldSystemFont(ofSize: 15)
            $0.text = ""
        }
        
        addToDoButton.do {
            $0.layer.cornerRadius = 0.5 * addToDoButton.bounds.width
            $0.clipsToBounds = true
        }
        
        createDatePickerView()
        setupSearchController()
        configureCollectionViewLayout()
        configureCollectionViewDataSource()
        
        var snapshot = collectionViewDataSource.snapshot()
        snapshot.appendSections([.Main])
        coreDataStore.updateTodo()
        snapshot.appendItems(sort())
        collectionViewDataSource.apply(snapshot)
        
        selectedFilter = .all
        textField.placeholder = "날짜와 시간을 선택해주세요"
    }
    
    @IBSegueAction func segueTopicViewController(_ coder: NSCoder) -> TopicViewController? {
        let viewController = TopicViewController(coder: coder)
        viewController?.eventDelegate = self
        topicViewController = viewController
        return viewController
    }
    
    @IBAction func tappedAddToDoButton(_ sender: Any) {
        guard let text = dateLabel.text else { return }
        
        if !textField.isFirstResponder {
            textField.becomeFirstResponder()
            dateLabel.isHidden = text.isEmpty
            UIView.animate(withDuration: 0.5) { [weak self] in
                guard let self = self else { return }
                
                self.addToDoButton.transform = .init(rotationAngle: 45 / 180 * .pi)
            }
        }
        else {
            textField.resignFirstResponder()
            UIView.animate(withDuration: 0.5) { [weak self] in
                guard let self = self else { return }
                
                self.addToDoButton.transform = .identity
            }
            
            dateLabel.text = ""
            
            textField.do {
                $0.text = ""
                $0.placeholder = "날짜와 시간을 선택해주세요"
            }
        }
    }
    
    @objc
    func tappedDateButton() {
        showDatePickerSheetPresentationController(context: .datePicker)
    }
    
    @objc
    func tappedTodayButton() {
        showDatePickerSheetPresentationController(context: .todayPicker)
    }
    
    @objc
    func tappedDoneButton() {
        guard let dateLabelText = dateLabel.text,
              let textFieldText = textField.text else { return }
       
        if dateLabelText.isEmpty {
            presentAlertController("날짜와 시간을 선택해주세요")
        }
        else if textFieldText.isEmpty {
            textField.text = ""
            presentAlertController("할 일을 입력해주세요")
        } else {
            coreDataStore.createTodo(text: textFieldText, date: date)
            dateLabel.text = ""
            
            textField.do {
                $0.resignFirstResponder()
                $0.text = ""
                $0.placeholder = "날짜와 시간을 선택해주세요"
            }
            
            UIView.animate(withDuration: 0.5) { [weak self] in
                guard let self = self else { return }
                
                self.addToDoButton.transform = .identity
            }
            dateLabel.isHidden = true
            configureSnapshot(selectedFilter)
        }
    }
    
    func presentAlertController(_ title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "확인", style: .cancel)
        alert.addAction(cancel)
        present(alert, animated: false)
    }
    
    func configureSnapshot(_ selectedFilter: Filter) {
        var snapshot = collectionViewDataSource.snapshot()
        snapshot.deleteItems(coreDataStore.fetchTodo())
        switch selectedFilter {
        case .all:
            snapshot.appendItems(sort())
        case .today:
            snapshot.appendItems(filteredToday(sort()))
        case .week:
            snapshot.appendItems(filteredWeek(sort()))
        case .month:
            snapshot.appendItems(filteredMonth(sort()))
        }
        collectionViewDataSource.apply(snapshot)
    }
    
    func createTitleLabel() -> UILabel {
        let label = UILabel()
        
        label.do {
            $0.textColor = .label
            $0.text = "Itree"
            $0.font = UIFont(name: "Unreal_science_yuni", size: 40)
        }
        
        return label
    }
    
    func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func showDatePickerSheetPresentationController(context: Context) {
        let viewController = DatePickerSheetPresentationController(context: context)
        viewController.delegate = self
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    func configureCollectionViewLayout() {
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        layoutConfig.backgroundColor = .systemBackground
        layoutConfig.trailingSwipeActionsConfigurationProvider = {
            [weak self] indexPath in
            guard let self = self else { return nil }
            
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
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
            
            let isPinnedAction = self.changeFixedAction("Pin", indexPath)
            let unPinnedAction = self.changeFixedAction("UnPin", indexPath)
            return self.collectionViewDataSource.itemIdentifier(for: indexPath)?.fix ?? false
                ? UISwipeActionsConfiguration(actions: [deleteAction, unPinnedAction])
                : UISwipeActionsConfiguration(actions: [deleteAction, isPinnedAction])
        }
        
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        collectionView.collectionViewLayout = listLayout
    }
    
    func changeFixedAction(_ title: String, _ indexPath: IndexPath) -> UIContextualAction {
        let changeFixedAction = UIContextualAction(style: .normal, title: title) { [weak self] _, _, completion in
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
        return changeFixedAction
    }
    
    func configureCollectionViewDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Todo>.init { [weak self] cell, _, itemIdentifier in
            
            guard let self = self else { return }
            
            self.contentConfiguration = cell.defaultContentConfiguration()
            self.contentConfiguration.imageProperties.tintColor = .label
            self.contentConfiguration.image = itemIdentifier.fix ? UIImage(systemName: "pin.fill") : nil
            self.contentConfiguration.text = nil
            self.contentConfiguration.attributedText = nil
            
            if itemIdentifier.completed {
                self.contentConfiguration.attributedText = itemIdentifier.content?.strikeThrough()
            }
            else {
                self.contentConfiguration.text = itemIdentifier.content
                self.contentConfiguration.attributedText = nil
            }
            
            if let todoAt = itemIdentifier.todoAt {
                self.contentConfiguration.secondaryText = itemIdentifier.fix ? "Every Day" : self.collectionViewCellSecondaryTextFormatter.string(from: todoAt)
            }
            self.contentConfiguration.secondaryTextProperties.color = .secondaryLabel
            cell.contentConfiguration = self.contentConfiguration
        }
        
        collectionViewDataSource = .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            
            return cell
        }
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
    
    override func willChangeKeyboard(isHidden: Bool) {
        bottomStackView.isHidden = isHidden
        addTodoButtonBottomConstraint?.isActive = !isHidden
    }
}

// MARK: TopicViewControllerEvent

extension HomeViewController: TopicViewControllerEvent {
    func topic(_ viewController: TopicViewController, didSelectedItem: Filter) {
        guard let text = self.navigationItem.searchController?.searchBar.text else { return }
        
        var snapshot = collectionViewDataSource.snapshot()
        snapshot.deleteItems(coreDataStore.fetchTodo())
        setFilteredSnapshot(text, snapshot: &snapshot, filter: didSelectedItem)
        collectionViewDataSource.apply(snapshot)
    }
    
    func setFilteredSnapshot(
        _ text: String,
        snapshot: inout NSDiffableDataSourceSnapshot<Section, Todo>,
        filter: Filter)
    {
        guard let searchController = self.navigationItem.searchController else { return }
        
        switch filter {
        case .all:
            if searchController.isActive {
                snapshot.appendItems(self.sort().filter { element in
                    let content = element.content ?? ""
                    return content.localizedCaseInsensitiveContains(text)
                })
            } else {
                snapshot.appendItems(self.sort())
            }
        case .today:
            if searchController.isActive {
                snapshot.appendItems(filteredToday(self.sort()).filter { element in
                    let content = element.content ?? ""
                    return content.localizedCaseInsensitiveContains(text)
                })
            } else {
                snapshot.appendItems(filteredToday(self.sort()))
            }
        case .week:
            if searchController.isActive {
                snapshot.appendItems(filteredWeek(self.sort()).filter { element in
                    let content = element.content ?? ""
                    return content.localizedCaseInsensitiveContains(text)
                })
            } else {
                snapshot.appendItems(filteredWeek(self.sort()))
            }
        case .month:
            if searchController.isActive {
                snapshot.appendItems(filteredMonth(self.sort()).filter { element in
                    let content = element.content ?? ""
                    return content.localizedCaseInsensitiveContains(text)
                })
            } else {
                snapshot.appendItems(filteredMonth(self.sort()))
            }
        }
    }
}

// MARK: UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedTodo = collectionViewDataSource.itemIdentifier(for: indexPath) else { return }
        
        selectedTodo.completed.toggle()
        selectedTodo.updateAt = Date()
        coreDataStore.saveContext()
        
        var snapshot = collectionViewDataSource.snapshot()
        snapshot.reloadItems([selectedTodo])
        collectionViewDataSource.apply(snapshot, animatingDifferences: true) {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
}

// MARK: UISearchResultsUpdating

extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchController = self.navigationItem.searchController,
              let text = self.navigationItem.searchController?.searchBar.text,
              let selectedFilter = self.selectedFilter else { return }
        
        if self.isSearchControllerFiltering || searchController.isActive {
            self.addToDoButton.isHidden = true
            self.textField.isHidden = true
            updateSearchResultsCases(text, filter: selectedFilter)
            var snapshot = collectionViewDataSource.snapshot()
            snapshot.deleteItems(coreDataStore.fetchTodo())
            snapshot.appendItems(filteredDataStore)
            collectionViewDataSource.apply(snapshot)
        }
        else {
            self.addToDoButton.isHidden = false
            self.textField.isHidden = false
            var snapshot = collectionViewDataSource.snapshot()
            snapshot.deleteItems(coreDataStore.fetchTodo())
            switch selectedFilter {
            case .all:
                snapshot.appendItems(self.sort())
            case .today:
                snapshot.appendItems(filteredToday(self.sort()))
            case .week:
                snapshot.appendItems(filteredWeek(self.sort()))
            case .month:
                snapshot.appendItems(filteredMonth(self.sort()))
            }
            collectionViewDataSource.apply(snapshot)
        }
    }
    
    func updateSearchResultsCases(_ text: String, filter: Filter) {
        switch filter {
        case .all:
            filteredDataStore = self.sort().filter { element in
                let content = element.content ?? ""
                return content.localizedCaseInsensitiveContains(text)
            }
        case .today:
            filteredDataStore = filteredToday(self.sort()).filter { element in
                let content = element.content ?? ""
                return content.localizedCaseInsensitiveContains(text)
            }
        case .week:
            filteredDataStore = filteredWeek(self.sort()).filter { element in
                let content = element.content ?? ""
                return content.localizedCaseInsensitiveContains(text)
            }
        case .month:
            filteredDataStore = filteredMonth(self.sort()).filter { element in
                let content = element.content ?? ""
                return content.localizedCaseInsensitiveContains(text)
            }
        }
    }
}

// MARK: Extension ViewController - UIDatePickerSheetProtocol

extension HomeViewController: UIDatePickerSheetProtocol {
    func tappedOKButton(_ viewController: DatePickerSheetPresentationController) {
        dateLabel.isHidden = false
        textField.placeholder = "할 일을 입력해주세요"
        dateLabel.text = dateLabelTextFormatter.string(from: viewController.date)
        date = viewController.date
    }
}

// MARK: Extension ViewController - filteredArray, sortedArray

extension HomeViewController {
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
            if current.fix, !next.fix {
                return true
            } else {
                return false
            }
        }
        return array
    }
}
