//
//  SecondViewController.swift
//  TodoList
//
//  Created by Кирилл Казаков on 24.06.2023.
//

import UIKit
import CocoaLumberjackSwift

class SecondViewContoller: UIViewController, UITextViewDelegate, DateSwitcherCellDelegate {
    var item: TodoItem?
    var viewContoller: ViewController
    init(item: TodoItem? = nil, viewController: ViewController) {
        self.item = item
        self.viewContoller = viewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let heightForRow: CGFloat = 67
    let heightForRowCalendar: CGFloat = 330
    
    let titleLabel = UILabel()
    let buttonDismiss = UIButton()
    let buttonSave = UIButton()
    let textView = UITextView()
    let tableView = UITableView()
    let deleteButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "Background")
        initHideKeyboard()
        buttonDismiss.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(buttonDismiss)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture))
        
        buttonDismiss.addGestureRecognizer(tapRecognizer)
        buttonDismiss.setTitle("Отменить", for: .normal)
        buttonDismiss.setTitleColor(UIColor(named: "PlusButton"), for: .normal)
        
        NSLayoutConstraint.activate([
            buttonDismiss.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            buttonDismiss.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            buttonDismiss.widthAnchor.constraint(equalToConstant: 100),
            buttonDismiss.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Дело"
        titleLabel.font = .boldSystemFont(ofSize: 20)
        self.view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 60),
            titleLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        buttonSave.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(buttonSave)
        buttonSave.setTitle("Сохранить", for: .normal)
        buttonSave.setTitleColor(UIColor(named: "PlusButton"), for: .normal)
        buttonSave.addTarget(self, action: #selector(saveButtonAction), for: .touchDown)
        NSLayoutConstraint.activate([
            buttonSave.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10),
            buttonSave.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 30),
            buttonSave.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            buttonSave.widthAnchor.constraint(equalToConstant: 60),
            buttonSave.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(textView)
        textView.delegate = self
        if let item = item {
            textView.text = item.text
            textView.textColor = UIColor.black
            deleteButton.setTitleColor(UIColor.red, for: .normal)
            deleteButton.isEnabled = true
            buttonSave.setTitleColor(UIColor(named: "PlusButton"), for: .normal)
            buttonSave.isEnabled = true
        }
        else {
            textView.text = "Что надо сделать?"
            textView.textColor = UIColor.lightGray
            deleteButton.setTitleColor(UIColor.lightGray, for: .normal)
            deleteButton.isEnabled = false
            buttonSave.setTitleColor(UIColor.lightGray, for: .normal)
            buttonSave.isEnabled = false
        }
        textView.font = .systemFont(ofSize: 18)
        let range = NSMakeRange(textView.text.count - 1, 0)
        textView.scrollRangeToVisible(range)
        textView.textContainer.lineFragmentPadding = 20
//        textView.textContainer.lineBreakMode = .byTruncatingTail
        textView.layer.cornerRadius = 20
        
        NSLayoutConstraint.activate([
            textView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            textView.widthAnchor.constraint(equalToConstant: 360),
            textView.heightAnchor.constraint(equalToConstant: 120)
        ])
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 20
        tableView.register(ImportanceSegControlCell.self, forCellReuseIdentifier: "importance")
        tableView.register(DateSwitcherCell.self, forCellReuseIdentifier: "dateSwitch")
        tableView.register(CalendarCell.self, forCellReuseIdentifier: "calendar")
        tableView.backgroundColor = UIColor(named: "Background")
        
        
        NSLayoutConstraint.activate([
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 20),
            tableView.widthAnchor.constraint(equalToConstant: 360),
            tableView.heightAnchor.constraint(equalToConstant: 500)
        ])
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(deleteButton)
        
        deleteButton.setTitle("Удалить", for: .normal)

        deleteButton.backgroundColor = UIColor.white
        deleteButton.layer.cornerRadius = 16
        deleteButton.addTarget(self, action: #selector(deleteButtonAction), for: .touchUpInside)
        NSLayoutConstraint.activate([
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -20),
            deleteButton.widthAnchor.constraint(equalToConstant: 360),
            deleteButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func onSwitchCellEvent() {
        let cell1 = tableView.cellForRow(at: IndexPath(row: 1, section: 0))
        let switcherCell = cell1 as! DateSwitcherCell
        let cell2 = tableView.cellForRow(at: IndexPath(row: 2, section: 0))
        let calendarCell = cell2 as! CalendarCell
        if switcherCell.switcher.isOn == true {
            switcherCell.label.topAnchor.constraint(equalTo: switcherCell.contentView.topAnchor, constant: 20).isActive = true
            //В этом условии не работают констреинты (но в else работают), пока не разобрался почему.
            let dateStringFormatter = DateFormatter()
            dateStringFormatter.dateFormat = "d MMMM yyyy"
            dateStringFormatter.locale = Locale(identifier: "ru_RU")
            let date = (Date().unixTimestamp + 108000000).date
            switcherCell.dateLabel.text = dateStringFormatter.string(from: date)
            switcherCell.dateLabel.isHidden = false
            calendarCell.calendarView.isHidden = false
            calendarCell.backgroundColor = UIColor.white
//            deleteButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -20).isActive = true //То же самое
        }
        else {
            switcherCell.label.centerYAnchor.constraint(equalTo: switcherCell.contentView.centerYAnchor).isActive = true
            calendarCell.calendarView.isHidden = true
            calendarCell.backgroundColor = UIColor(named: "Background")
//            deleteButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -350).isActive = true
            switcherCell.dateLabel.isHidden = true
        }
    }
    
    @objc func handleTapGesture(sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text != "" {
            buttonSave.isEnabled = true
            buttonSave.setTitleColor(UIColor(named: "PlusButton"), for: .normal)
        }
        else {
            buttonSave.isEnabled = false
            buttonSave.setTitleColor(UIColor.lightGray, for: .normal)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {

        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {

        if textView.text == "" {
            textView.text = "Что надо сделать?"
            textView.textColor = UIColor.lightGray
        }
    }
    
    @objc func saveButtonAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Уведомление", message: "Сохранение прошло успешно", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        //доделаю
//        var todoItem: TodoItem
//        if let item = item {
//            todoItem = TodoItem(
//                id: item.id,
//                text: textView.text,
//                importance: Importance.important,
//                deadline: Date(),
//                isDone: false,
//                createAt: Date(),
//                dateEdit: Date()
//            )
//        }
//        else {
//
//        }
        alertController.addAction(alertAction)
        self.present(alertController, animated: true)
        DDLogInfo("Выполнено сохранение.")
    }
    
    @objc func deleteButtonAction(_ sender: Any) {
        if let item = item {
            viewContoller.filecache.deleteItem(item.id)
            viewContoller.updateData()
            DDLogInfo("Удаление прошло успешно!")
            dismiss(animated: true)
        }
        else {
            let alertController = UIAlertController(title: "Ошибка", message: "Не удалось удалить задачу", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true)
            DDLogError("Ошибка удаления задачи!")
        }

        
    }
    
}

extension SecondViewContoller: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return heightForRow
        }
        else if indexPath.row == 1 {
            return heightForRow
        }
        else {
            return heightForRowCalendar
        }
    }
}

extension SecondViewContoller: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "importance", for: indexPath) as! ImportanceSegControlCell
            switch item?.importance {
            case .important:
                cell.importanceSwitcher.selectedSegmentIndex = 2
            case .unimportant:
                cell.importanceSwitcher.selectedSegmentIndex = 0
            default:
                cell.importanceSwitcher.selectedSegmentIndex = 1
            }
            return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dateSwitch", for: indexPath) as! DateSwitcherCell
            cell.delegate = self
            if let deadline = item?.deadline {
                cell.switcher.setOn(true, animated: true)
                let dateStringFormatter = DateFormatter()
                dateStringFormatter.dateFormat = "d MMMM yyyy"
                dateStringFormatter.locale = Locale(identifier: "ru_RU")
                cell.dateLabel.text = dateStringFormatter.string(from: deadline)
            }
            else {
//                cell.label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
                cell.switcher.setOn(false, animated: true)
            }
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "calendar", for: indexPath) as! CalendarCell
            return cell
        }
    }
}

extension SecondViewContoller: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func initHideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissMyKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissMyKeyboard(){
        view.endEditing(true)
    }
}

class ImportanceSegControlCell: UITableViewCell {

    let taskLabel = UILabel()
    let importanceSwitcher = UISegmentedControl()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        taskLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(taskLabel)
        
        taskLabel.text = "Важность"
        taskLabel.textColor = UIColor.black
        taskLabel.font = .systemFont(ofSize: 17)
        
        NSLayoutConstraint.activate([
            taskLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            taskLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            taskLabel.heightAnchor.constraint(equalToConstant: 40),
            taskLabel.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        importanceSwitcher.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(importanceSwitcher)
        
        importanceSwitcher.insertSegment(with: UIImage(systemName: "arrow.down"), at: 0, animated: true)
        importanceSwitcher.insertSegment(withTitle: "нет", at: 1, animated: true)
//        var attributedString = NSAttributedString(string: "!!", attributes: [.foregroundColor: UIColor(named: "Red"), .font: UIFont(name: .localizedName(of: .utf8), size: 14)])
        importanceSwitcher.insertSegment(withTitle: "!!", at: 2, animated: true)
        importanceSwitcher.selectedSegmentIndex = 1
        importanceSwitcher.backgroundColor = UIColor(named: "BackgroundSG")
        importanceSwitcher.selectedSegmentTintColor = UIColor.white
        
        NSLayoutConstraint.activate([
            importanceSwitcher.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            importanceSwitcher.leadingAnchor.constraint(equalTo: taskLabel.trailingAnchor, constant: 75),
            importanceSwitcher.heightAnchor.constraint(equalToConstant: 36),
            importanceSwitcher.widthAnchor.constraint(equalToConstant: 150)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol DateSwitcherCellDelegate: AnyObject {
    func onSwitchCellEvent()
}

class DateSwitcherCell: UITableViewCell {
    weak var delegate: DateSwitcherCellDelegate?
    
    let switcher = UISwitch()
    let label = UILabel()
    let dateLabel = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        label.text = "Сделать до"
        label.textColor = UIColor.black
        label.font = .systemFont(ofSize: 17)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            label.heightAnchor.constraint(equalToConstant: 40),
            label.widthAnchor.constraint(equalToConstant: 100)
        ])
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)
        dateLabel.textColor = UIColor(named: "PlusButton")
        dateLabel.font = .systemFont(ofSize: 14)
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateLabel.heightAnchor.constraint(equalToConstant: 40),
//            dateLabel.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        switcher.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(switcher)
        switcher.onTintColor = UIColor(named: "Green")
        switcher.addTarget(self, action: #selector(switchValueDidChange), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            switcher.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            switcher.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 175),
            switcher.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
//            switcher.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc func switchValueDidChange(sender:UISwitch!) {
        delegate?.onSwitchCellEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



class CalendarCell: UITableViewCell {
    let calendarView = UICalendarView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(calendarView)
        
        let gregorianCalendar = Calendar(identifier: .gregorian)
        calendarView.calendar = gregorianCalendar
        calendarView.tintColor = .white
        calendarView.availableDateRange = DateInterval(start: .now, end: .distantFuture)
        
        calendarView.fontDesign = .rounded
        let selection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = selection
        calendarView.tintColor = UIColor(named: "PlusButton")
        calendarView.backgroundColor = UIColor.white
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            calendarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            calendarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            calendarView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CalendarCell: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        print(dateComponents)
    }
    func dateSelection(_ selection: UICalendarSelectionSingleDate, canSelectDate dateComponents: DateComponents?) -> Bool {
        true
    }
}

