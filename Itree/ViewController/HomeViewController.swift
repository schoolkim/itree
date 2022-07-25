//
//  ViewController.swift
//  Itree
//
//  Created by HAKKYU KIM on 2022/05/17.
//

import UIKit

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
    
    var isFiltering: Bool {
        guard let searchController = self.navigationItem.searchController,
              let searchBarText = self.navigationItem.searchController?.searchBar.text else { return false }
        
        let isActive = searchController.isActive
        let hasText = searchBarText.isEmpty == false
        return isActive && hasText
    }
    
    var topicDataStore: [Filter] = {
        Filter.allCases
    }()
    
    var collectionViewCellSecondaryTextFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.dateFormat = "yyyy년 MM월 dd일 HH시 mm분"
        return formatter
    }()
    
    var dateLabelTextFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateFormat = "yyyy/MM/dd - HH:mm "
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
        
        let addTodoButtonBottomKeyboardConstraint = addToDoButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -8)
        addTodoButtonBottomKeyboardConstraint.priority = .defaultLow
        addTodoButtonBottomKeyboardConstraint.isActive = true
        addTodoButtonBottomConstraint = addToDoButton.bottomAnchor.constraint(equalTo: bottomStackView.topAnchor, constant: -8)
        addTodoButtonBottomConstraint?.priority = .defaultHigh
        bottomStackView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        
        topicViewController?.applyInitialData(items: topicDataStore)
        let label = createTitleLabel()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
        
        dateLabel.textColor = .label
        dateLabel.font = UIFont.boldSystemFont(ofSize: 15)
        dateLabel.text = ""
        
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
        if !textField.isFirstResponder {
            textField.becomeFirstResponder()
            if dateLabel.text == "" {
                dateLabel.isHidden = true
            }
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
            textField.text = ""
            textField.placeholder = "날짜와 시간을 선택해주세요"
        }
    }
    
    // TODO: sheetPresentationController dismiss하고 나면 addTodoButton color 변경됨

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
        if dateLabel.text == "" {
            let alert = UIAlertController(title: "날짜와 시간을 선택해주세요", message: "", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "확인", style: .cancel)
            alert.addAction(cancel)
            present(alert, animated: false)
            return
        }
        else if textField.text == "" {
            textField.text = ""
            let alert = UIAlertController(title: "할 일을 입력해주세요", message: "", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "확인", style: .cancel)
            alert.addAction(cancel)
            present(alert, animated: false)
            return
        }
        
        let resultString = textField.text
        coreDataStore.createTodo(text: resultString ?? "", date: date)
        textField.resignFirstResponder()
        textField.text = ""
        dateLabel.text = ""
        textField.placeholder = "날짜와 시간을 선택해주세요"
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.addToDoButton.transform = .identity
        }
        configureSnapshot(selectedFilter)
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
        label.textColor = .label
        label.text = "Itree"
        label.font = UIFont(name: "Unreal_science_yuni", size: 40)
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
        let navigationController = UINavigationController(rootViewController: DatePickerSheetPresentationController(context: context))
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
            
            let fixAction = self.changeFixedAction("Fix", indexPath)
            let unFixAction = self.changeFixedAction("UnFix", indexPath)
            return self.collectionViewDataSource.itemIdentifier(for: indexPath)?.fix ?? false
                ? UISwipeActionsConfiguration(actions: [deleteAction, unFixAction])
                : UISwipeActionsConfiguration(actions: [deleteAction, fixAction])
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
            self.contentConfiguration.imageProperties.tintColor = .black
            self.contentConfiguration.image = itemIdentifier.fix ? UIImage(systemName: "pin.fill") : nil
            
            // TODO: fix된 상태로 completed로 바꾼 후 unfix하고 completed 풀면 strikeThrough 적용됨
            
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
        switch didSelectedItem {
        case .all:
            setFilteredSnapshot(text, &snapshot, .all)
        case .today:
            setFilteredSnapshot(text, &snapshot, .today)
        case .week:
            setFilteredSnapshot(text, &snapshot, .week)
        case .month:
            setFilteredSnapshot(text, &snapshot, .month)
        }
        collectionViewDataSource.apply(snapshot)
    }
    
    func setFilteredSnapshot(
        _ text: String,
        _ snapshot: inout NSDiffableDataSourceSnapshot<Section, Todo>,
        _ filter: Filter)
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
        snapshot.reconfigureItems([selectedTodo])
        collectionViewDataSource.apply(snapshot, animatingDifferences: true) {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
}

// MARK: UISearchResultsUpdating

extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = self.navigationItem.searchController?.searchBar.text,
              let selectedFilter = self.selectedFilter else { return }
        
        if self.isFiltering || self.navigationItem.searchController?.isActive ?? false {
            self.addToDoButton.isHidden = true
            switch selectedFilter {
            case .all:
                updateSearchResultsCases(text, .all)
            case .today:
                updateSearchResultsCases(text, .today)
            case .week:
                updateSearchResultsCases(text, .week)
            case .month:
                updateSearchResultsCases(text, .month)
            }
            
            var snapshot = collectionViewDataSource.snapshot()
            snapshot.deleteItems(coreDataStore.fetchTodo())
            snapshot.appendItems(filteredDataStore)
            collectionViewDataSource.apply(snapshot)
            
        }
        else {
            self.addToDoButton.isHidden = false
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
    
    func updateSearchResultsCases(_ text: String, _ filter: Filter) {
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
            if current.fix , !next.fix {
                return true
            } else {
                return false
            }
        }
        return array
    }
}
