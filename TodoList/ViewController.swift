//
//  ViewController.swift
//  TodoList
//
//  Created by Кирилл Казаков on 21.06.2023.
//

import UIKit
import CocoaLumberjackSwift

class ViewController: UIViewController {
    private func setupNavBar() {
        self.navigationItem.title = "Мои дела"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.directionalLayoutMargins.leading = 32
    }
    var todoItem1 = TodoItem(
        id: "1",
        text: "Помыть машину",
        importance: Importance.important,
        deadline: nil,
        isDone: false,
        createAt: Date(),
        dateEdit: Date()
    )
    
    var todoItem2 = TodoItem(
        id: "2",
        text: "Убраться в доме",
        importance: Importance.unimportant,
        deadline: Date(),
        isDone: false,
        createAt: Date(),
        dateEdit: Date()
    )
    
    var todoItem3 = TodoItem(id: "3",text: "Купить сыр",importance: Importance.ordinary,deadline: nil,isDone: true,createAt: Date(),dateEdit: Date())
    var todoItem4 = TodoItem(id: "4",text: "Купить сыр",importance: Importance.ordinary,deadline: nil,isDone: true,createAt: Date(),dateEdit: Date())
    var todoItem5 = TodoItem(id: "5",text: "Купить сыр",importance: Importance.ordinary,deadline: nil,isDone: true,createAt: Date(),dateEdit: Date())
    var todoItem6 = TodoItem(id: "6",text: "Купить сыр",importance: Importance.ordinary,deadline: nil,isDone: true,createAt: Date(),dateEdit: Date())
    var todoItem7 = TodoItem(id: "7",text: "Купить сыр",importance: Importance.ordinary,deadline: nil,isDone: true,createAt: Date(),dateEdit: Date())
    var todoItem8 = TodoItem(id: "8",text: "Купить сыр",importance: Importance.ordinary,deadline: nil,isDone: true,createAt: Date(),dateEdit: Date())
    var todoItem9 = TodoItem(id: "9",text: "Купить сыр",importance: Importance.ordinary,deadline: nil,isDone: true,createAt: Date(),dateEdit: Date())
    var todoItem10 = TodoItem(id: "10",text: "Купить сыр",importance: Importance.ordinary,deadline: nil,isDone: true,createAt: Date(),dateEdit: Date())
    var todoItem11 = TodoItem(id: "11",text: "Купить сыр",importance: Importance.ordinary,deadline: nil,isDone: true,createAt: Date(),dateEdit: Date())
    var listAll: [TodoItem] = []
    var listIsNotDone: [TodoItem] = []
    var flag = false
    var collection: [TodoItem] = []
    
    let titleLabel = UILabel()
    let doneTasksLabel = UILabel()
    let showDoneTasksButton = UIButton()
    let heightForRow: CGFloat = 67
    
    let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
//        table.backgroundColor = UIColor(named: "Background")
        return table
    }()
    
    let addButton: UIButton = {
        let button = UIButton()
        let smallConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .large)
        let largeBoldDoc = UIImage(systemName: "plus", withConfiguration: smallConfig)
        button.setImage(largeBoldDoc, for: .normal)
        button.backgroundColor = UIColor(named: "PlusButton")
        button.tintColor = UIColor.white
        button.layer.cornerRadius = 26
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 6
        
        return button
    }()
    
    let identifier = "cell"
    
    var filecache = FileCache()
    var countDone: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationBar.prefersLargeTitles = true
        DDLog.add(DDOSLogger.sharedInstance)

        let fileLogger: DDFileLogger = DDFileLogger()
        fileLogger.rollingFrequency = 60 * 60 * 24
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
        
        filecache.addItem(todoItem1)
        filecache.addItem(todoItem2)
        filecache.addItem(todoItem3)
        filecache.addItem(todoItem4)
        filecache.addItem(todoItem5)
        filecache.addItem(todoItem6)
        filecache.addItem(todoItem7)
        filecache.addItem(todoItem8)
        filecache.addItem(todoItem9)
        filecache.addItem(todoItem10)
        filecache.addItem(todoItem11)
        filecache.saveAllJsonFile(fileName: "jsonfile")
        filecache.getAllFromJson(fileName: "jsonfile")
        updateListIsNotDone()
        updateAll()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(titleLabel)
        
        titleLabel.text = "Мои дела"
        titleLabel.font = .boldSystemFont(ofSize: 40)
        titleLabel.textColor = UIColor.black
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 34).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 110).isActive = true
        
        doneTasksLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(doneTasksLabel)
        countDone = filecache.toDoList.filter({$0.isDone == true}).count
        doneTasksLabel.text = "Выполнено - \(countDone)"
        doneTasksLabel.textColor = UIColor.lightGray
        doneTasksLabel.font = .systemFont(ofSize: 16)
        doneTasksLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 34).isActive = true
        doneTasksLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 55).isActive = true
        doneTasksLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
        doneTasksLabel.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        showDoneTasksButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(showDoneTasksButton)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleShowDoneTasks))
        showDoneTasksButton.setTitle("Показать", for: .normal)
        
        showDoneTasksButton.addGestureRecognizer(tapRecognizer)
        showDoneTasksButton.setTitleColor(UIColor(named: "PlusButton"), for: .normal)
        showDoneTasksButton.leadingAnchor.constraint(equalTo: doneTasksLabel.trailingAnchor, constant: 110).isActive = true
        showDoneTasksButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        showDoneTasksButton.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 55).isActive = true
        
        self.view.addSubview(tableView)
        tableView.largeContentTitle = "Мои дела"
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15.0).isActive = true
        tableView.topAnchor.constraint(equalTo: doneTasksLabel.bottomAnchor, constant: 10).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
//        tableView.layer.cornerRadius = 20
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = .init(top: 20, left: 65, bottom: 20, right: 0)
        tableView.register(CustomCell.self, forCellReuseIdentifier: identifier)
        tableView.backgroundColor = UIColor(named: "Background")
        tableView.layer.cornerRadius = 20
        tableView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        self.view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 750).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 52).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        addButton.centerXAnchor.constraint(equalTo: self.tableView.centerXAnchor).isActive = true
        addButton.addTarget(self, action: #selector(self.showCreateView(sender: )), for:.touchUpInside)
        
        self.view.backgroundColor = UIColor(named: "Background")
    }
    
    @objc func handleShowDoneTasks(sender: UITapGestureRecognizer) {
        flag.toggle()
        if !flag {
            showDoneTasksButton.setTitle("Показать", for: .normal)
        }
        else {
            showDoneTasksButton.setTitle("Скрыть", for: .normal)
        }
        tableView.reloadData()
    }
    
    func updateListIsNotDone() {
        listIsNotDone = filecache.toDoList.filter({$0.isDone == false})
    }
    
    func updateAll() {
        listAll = filecache.toDoList
    }
    
    func updateData() {
        updateListIsNotDone()
        updateAll()
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRow
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !flag {
            return listIsNotDone.count
        }
        else {
            return listAll.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "d MMMM"
        dateStringFormatter.locale = Locale(identifier: "ru_RU")
        cell.circleImage.image = UIImage(systemName: "circle")
        if !flag {
            let attributedText = NSAttributedString(string: listAll[indexPath.row].text)
            cell.taskLabel.attributedText = attributedText
            if let deadline = listIsNotDone[indexPath.row].deadline {
                let attributedText = NSAttributedString(string: dateStringFormatter.string(from: deadline))
                cell.dateLabel.attributedText = attributedText
                cell.dateLabel.isHidden = false
                cell.calendarImage.isHidden = false
                cell.taskLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10).isActive = true
                cell.importanceLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 15).isActive = true
                cell.impotranceImage.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 15).isActive = true
            }
            else {
                cell.dateLabel.isHidden = true
                cell.calendarImage.isHidden = true
                cell.taskLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
                cell.importanceLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
                cell.impotranceImage.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
            }
            if listIsNotDone[indexPath.row].importance == Importance.important {
                cell.impotranceImage.isHidden = true
                cell.importanceLabel.isHidden = false
                cell.circleImage.tintColor = UIColor(named: "Red")
                cell.importanceLabel.leadingAnchor.constraint(equalTo: cell.circleImage.trailingAnchor, constant: 15).isActive = true
                cell.taskLabel.leadingAnchor.constraint(equalTo: cell.importanceLabel.trailingAnchor, constant: 5).isActive = true
            }
            else {
                if listIsNotDone[indexPath.row].importance == Importance.unimportant {
                    cell.impotranceImage.isHidden = false
                    cell.importanceLabel.isHidden = true
                    cell.impotranceImage.leadingAnchor.constraint(equalTo: cell.circleImage.trailingAnchor, constant: 15).isActive = true
                    cell.taskLabel.leadingAnchor.constraint(equalTo: cell.impotranceImage.trailingAnchor, constant: 5).isActive = true
                }
                else {
                    cell.impotranceImage.isHidden = true
                    cell.importanceLabel.isHidden = true
                    cell.taskLabel.leadingAnchor.constraint(equalTo: cell.circleImage.trailingAnchor, constant: 15).isActive = true
                }
                cell.circleImage.tintColor = UIColor.lightGray
            }
            
        }
        else {
            if listAll[indexPath.row].isDone {
                cell.circleImage.image = UIImage(systemName: "checkmark.circle.fill")
                cell.circleImage.backgroundColor = UIColor.white
                cell.circleImage.tintColor = UIColor(named: "Green")
                let attributedText = NSAttributedString(
                    string: listAll[indexPath.row].text,
                    attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                                 .foregroundColor: UIColor.lightGray]
                )
                cell.taskLabel.attributedText = attributedText
                cell.taskLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
                cell.taskLabel.leadingAnchor.constraint(equalTo: cell.circleImage.trailingAnchor, constant: 15).isActive = true
                cell.importanceLabel.isHidden = true
                cell.impotranceImage.isHidden = true
                cell.calendarImage.isHidden = true
                cell.dateLabel.isHidden = true
            }
            else {
                if let deadline = listAll[indexPath.row].deadline {
                    let attributedText = NSAttributedString(string: dateStringFormatter.string(from: deadline))
                    cell.dateLabel.attributedText = attributedText
                    cell.dateLabel.isHidden = false
                    cell.calendarImage.isHidden = false
                    cell.taskLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10).isActive = true
                    cell.importanceLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 15).isActive = true
                    cell.impotranceImage.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 15).isActive = true
                }
                else {
                    cell.dateLabel.isHidden = true
                    cell.calendarImage.isHidden = true
                    cell.taskLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
                    cell.importanceLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
                    cell.impotranceImage.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
                }
                if listAll[indexPath.row].importance == Importance.important {
                    cell.impotranceImage.isHidden = true
                    cell.importanceLabel.isHidden = false
                    cell.circleImage.tintColor = UIColor(named: "Red")
                    cell.importanceLabel.leadingAnchor.constraint(equalTo: cell.circleImage.trailingAnchor, constant: 15).isActive = true
                    cell.taskLabel.leadingAnchor.constraint(equalTo: cell.importanceLabel.trailingAnchor, constant: 5).isActive = true
                }
                else {
                    if listAll[indexPath.row].importance == Importance.unimportant {
                        cell.impotranceImage.isHidden = false
                        cell.importanceLabel.isHidden = true
                        cell.impotranceImage.leadingAnchor.constraint(equalTo: cell.circleImage.trailingAnchor, constant: 15).isActive = true
                        cell.taskLabel.leadingAnchor.constraint(equalTo: cell.impotranceImage.trailingAnchor, constant: 5).isActive = true
                    }
                    else {
                        cell.impotranceImage.isHidden = true
                        cell.importanceLabel.isHidden = true
                        cell.taskLabel.leadingAnchor.constraint(equalTo: cell.circleImage.trailingAnchor, constant: 15).isActive = true
                    }
                    cell.circleImage.tintColor = UIColor.lightGray
                }
            }

        }
        cell.button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        cell.button.tintColor = UIColor.gray
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showDetails(filecache.toDoList[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let doneAction = UIContextualAction(style: .normal, title: "") { (action, view, bool) in
            let item = self.filecache.toDoList[indexPath.row]
            let todoItem = TodoItem(
                id: item.id,
                text: item.text,
                importance: item.importance,
                deadline: item.deadline,
                isDone: true,
                createAt: item.createAt,
                dateEdit: item.dateEdit
            )
            self.filecache.addItem(todoItem)
            self.updateListIsNotDone()
            self.updateAll()
            tableView.reloadData()
            self.countDone = self.filecache.toDoList.filter({$0.isDone == true}).count
            self.doneTasksLabel.text = "Выполнено - \(self.countDone)"
        }
        doneAction.image = UIImage(systemName: "checkmark.circle.fill")
        doneAction.image?.withTintColor(UIColor.white)
        doneAction.backgroundColor = UIColor(named: "Green")
        
        return UISwipeActionsConfiguration(actions: [doneAction])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "") { (action, view, bool) in
            if !self.flag {
                let id = self.listIsNotDone[indexPath.row].id
                self.filecache.deleteItem(id)
                self.updateData()
            }
            else {
                let id = self.listAll[indexPath.row].id
                self.filecache.deleteItem(id)
                self.updateData()
            }
            
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.image?.withTintColor(UIColor.white)
        deleteAction.backgroundColor = UIColor(named: "Red")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    @objc func showCreateView(sender: Any) {
        let secondVC = SecondViewContoller(viewController: self)
        if let sheet = secondVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.preferredCornerRadius = 20
            sheet.prefersEdgeAttachedInCompactHeight = true
        }
        present(secondVC, animated: true)
    }
    
    func showDetails(_ item: TodoItem) {
        let secondVC = SecondViewContoller(item: item, viewController: self)
        if let sheet = secondVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.preferredCornerRadius = 20
            sheet.prefersEdgeAttachedInCompactHeight = true
        }
        present(secondVC, animated: true)
    }
    
}

class CustomCell: UITableViewCell {

    let impotranceImage = UIImageView()
    let importanceLabel = UILabel()
    let taskLabel = UILabel()
    let dateLabel = UILabel()
    let button = UIButton()
    var circleImage = UIImageView()
    var calendarImage = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        circleImage.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(circleImage)
        
        NSLayoutConstraint.activate([
            circleImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            circleImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            circleImage.widthAnchor.constraint(equalToConstant: 30),
            circleImage.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        impotranceImage.image = UIImage(systemName: "arrow.down")
        impotranceImage.tintColor = UIColor.lightGray
        impotranceImage.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(impotranceImage)

        NSLayoutConstraint.activate([
            impotranceImage.leadingAnchor.constraint(equalTo: circleImage.trailingAnchor, constant: 15),
            impotranceImage.heightAnchor.constraint(equalToConstant: 17),
            impotranceImage.widthAnchor.constraint(equalToConstant: 17),
            
        ])

        importanceLabel.text = "!!"
        importanceLabel.textColor = UIColor(named: "Red")
        importanceLabel.font = .systemFont(ofSize: 25)

        importanceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(importanceLabel)

        NSLayoutConstraint.activate([
            importanceLabel.leadingAnchor.constraint(equalTo: circleImage.trailingAnchor, constant: 15),
            importanceLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
        
        taskLabel.translatesAutoresizingMaskIntoConstraints = false
        taskLabel.font = UIFont.systemFont(ofSize: 17)
        
        contentView.addSubview(taskLabel)
        
        NSLayoutConstraint.activate([
//            taskLabel.leadingAnchor.constraint(equalTo: circleImage.trailingAnchor, constant: 15),
            taskLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        calendarImage.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(calendarImage)
        
        calendarImage.image = UIImage(systemName: "calendar")
        calendarImage.tintColor = UIColor.lightGray
        
        NSLayoutConstraint.activate([
            calendarImage.leadingAnchor.constraint(equalTo: circleImage.trailingAnchor, constant: 15),
            calendarImage.topAnchor.constraint(equalTo: taskLabel.topAnchor, constant: 28),
//            calendarImage.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textColor = UIColor.gray
        contentView.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: calendarImage.trailingAnchor, constant: 5),
            dateLabel.topAnchor.constraint(equalTo: taskLabel.topAnchor, constant: 25),
            dateLabel.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        button.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: taskLabel.trailingAnchor, constant: 30),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 25),
            button.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

