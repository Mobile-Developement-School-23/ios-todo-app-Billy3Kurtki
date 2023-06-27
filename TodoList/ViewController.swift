//
//  ViewController.swift
//  TodoList
//
//  Created by Кирилл Казаков on 21.06.2023.
//

import UIKit

class ViewController: UIViewController {

   
    var todoItem1 = TodoItem(
        id: "1",
        text: "Помыть машину",
        importance: Importance.important,
        deadline: Date(),
        isDone: false,
        createAt: Date(),
        dateEdit: Date()
    )
    
    var todoItem2 = TodoItem(
        id: "2",
        text: "Убраться в доме",
        importance: Importance.unimportant,
        deadline: Date(),
        isDone: true,
        createAt: Date(),
        dateEdit: Date()
    )
    var flag = false
    var collection: [TodoItem] = []
    
    let titleLabel = UILabel()
    let doneTasksLabel = UILabel()
    let showDoneTasksButton = UIButton()
    let heightForRow: CGFloat = 67
    
    let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    let addButton: UIButton = {
        let button = UIButton()
        let smallConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .large)
        let largeBoldDoc = UIImage(systemName: "plus", withConfiguration: smallConfig)
        button.setImage(largeBoldDoc, for: .normal)
        button.backgroundColor = UIColor.blue
        button.tintColor = UIColor.white
        button.layer.cornerRadius = 26
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 6
        
        return button
    }()
    
    let data = ["Work1", "Work2", "Work3", "Work4", "Work5", "Work6", "Work7", "Work8", "Work9", "Work10", "Work11"]
    let identifier = "cell"
    
    var filecache = FileCache()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filecache.addItem(todoItem1)
        filecache.addItem(todoItem2)
        filecache.saveAllJsonFile(fileName: "jsonfile")
        filecache.getAllFromJson(fileName: "jsonfile")
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(titleLabel)
        
        titleLabel.text = "Мои дела"
        titleLabel.font = .boldSystemFont(ofSize: 40)
        titleLabel.textColor = UIColor.black
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 34).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 110).isActive = true
        
        doneTasksLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(doneTasksLabel)
        let countDone = filecache.toDoList.filter({$0.isDone == true}).count
        doneTasksLabel.text = "Выполнено - \(countDone)"
        doneTasksLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 34).isActive = true
        doneTasksLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 55).isActive = true
        doneTasksLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
        doneTasksLabel.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        showDoneTasksButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(showDoneTasksButton)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleShowDoneTasks))
        showDoneTasksButton.setTitle("Показать", for: .normal)
        
        showDoneTasksButton.addGestureRecognizer(tapRecognizer)
        showDoneTasksButton.setTitleColor(UIColor.blue, for: .normal)
        showDoneTasksButton.leadingAnchor.constraint(equalTo: doneTasksLabel.trailingAnchor, constant: 110).isActive = true
        showDoneTasksButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        showDoneTasksButton.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 55).isActive = true
        
        self.view.addSubview(tableView)
        
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15.0).isActive = true
        tableView.topAnchor.constraint(equalTo: doneTasksLabel.bottomAnchor, constant: 10).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.0).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: heightForRow * 3).isActive = true
//        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0).isActive = true
        tableView.layer.cornerRadius = 20
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = .init(top: 20, left: 65, bottom: 20, right: 0)
        tableView.register(CustomCell.self, forCellReuseIdentifier: identifier)
        
        
        
        self.view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 750).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 52).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        addButton.centerXAnchor.constraint(equalTo: self.tableView.centerXAnchor).isActive = true
        addButton.addTarget(self, action: #selector(self.showCreateView(sender: )), for:.touchUpInside)
        
        self.view.backgroundColor = UIColor.gray
    }


    @objc func btnAction() {

    }
    
    func tappedCell() {}
    
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
    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRow
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !flag {
            return filecache.toDoList.filter({$0.isDone == false}).count
        }
        else {
            return filecache.toDoList.count
        }
//        if !flag {
//            let listCount = filecache.toDoList.filter({$0.isDone == false}).count
//            tableView.heightAnchor.constraint(equalToConstant: heightForRow * CGFloat(listCount)).isActive = true
//            tableView.updateConstraints()
//            return listCount
//        }
//        else {
//            let listCount = filecache.toDoList.count
//            tableView.heightAnchor.constraint(equalToConstant: heightForRow * CGFloat(listCount)).isActive = true
//            tableView.updateConstraints()
//            return listCount
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        if filecache.toDoList[indexPath.row].isDone {
            cell.circleImage.image = UIImage(systemName: "checkmark.circle.fill")
            cell.circleImage.backgroundColor = UIColor.white
            cell.circleImage.tintColor = UIColor.green
            let attributedText = NSAttributedString(
                string: filecache.toDoList[indexPath.row].text,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            cell.taskLabel.attributedText = attributedText
            cell.taskLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 18).isActive = true
            cell.dateLabel.isHidden = true
            cell.calendarImage.isHidden = true
        }
        else {
            if filecache.toDoList[indexPath.row].importance == Importance.important {
                cell.circleImage.image = UIImage(systemName: "circle")
                cell.circleImage.tintColor = UIColor.red
            }
            else {
                cell.circleImage.image = UIImage(systemName: "circle")
                cell.circleImage.tintColor = UIColor.gray
            }
            cell.taskLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10).isActive = true
            cell.taskLabel.text = filecache.toDoList[indexPath.row].text
        }
        
        cell.taskLabel.text = filecache.toDoList[indexPath.row].text
        if let deadline = filecache.toDoList[indexPath.row].deadline {
            let dateStringFormatter = DateFormatter()
            dateStringFormatter.dateFormat = "dd MMMM"
            dateStringFormatter.locale = Locale(identifier: "ru_RU")
            cell.dateLabel.text = dateStringFormatter.string(for: deadline)
        }
        cell.button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        cell.button.tintColor = UIColor.gray
        return cell
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        tappedCell()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            objects.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [
//            tappedCell(forRowAt: indexPath)
        ])
    }
    
    @objc func showCreateView(sender: Any) {
        let secondVC = SecondViewContoller()
        if let sheet = secondVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.preferredCornerRadius = 20
            sheet.prefersEdgeAttachedInCompactHeight = true
        }
        present(secondVC, animated: true)
    }
    
}

class CustomCell: UITableViewCell {

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
        
        taskLabel.translatesAutoresizingMaskIntoConstraints = false
        taskLabel.font = UIFont.systemFont(ofSize: 17)
        
        contentView.addSubview(taskLabel)
        
        NSLayoutConstraint.activate([
            taskLabel.leadingAnchor.constraint(equalTo: circleImage.trailingAnchor, constant: 15),
//            taskLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
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

