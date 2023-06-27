//
//  SecondViewController.swift
//  TodoList
//
//  Created by Кирилл Казаков on 24.06.2023.
//

import UIKit

class SecondViewContoller: UIViewController, UITextViewDelegate {
    
    let titleLabel = UILabel()
    let buttonDismiss = UIButton()
    let buttonSave = UIButton()
    let textView = UITextView()
    let tableView = UITableView()
    let deleteButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        buttonDismiss.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(buttonDismiss)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture))
        
        buttonDismiss.addGestureRecognizer(tapRecognizer)
        buttonDismiss.setTitle("Отменить", for: .normal)
        buttonDismiss.setTitleColor(UIColor.blue, for: .normal)
        
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
        buttonSave.setTitleColor(UIColor.blue, for: .normal)
        
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
        textView.text = "Что надо сделать?"
        textView.font = .systemFont(ofSize: 20)
        textView.textColor = UIColor.lightGray
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
        
        NSLayoutConstraint.activate([
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 20),
            tableView.widthAnchor.constraint(equalToConstant: 360),
            tableView.heightAnchor.constraint(equalToConstant: 500)
        ])
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(deleteButton)
        
        deleteButton.setTitle("Удалить", for: .normal)
        deleteButton.setTitleColor(UIColor.red, for: .normal)
        deleteButton.backgroundColor = UIColor.white
        deleteButton.layer.cornerRadius = 16
        
        NSLayoutConstraint.activate([
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            deleteButton.widthAnchor.constraint(equalToConstant: 360),
            deleteButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
    }
    
    @objc func handleTapGesture(sender: UITapGestureRecognizer) {
        dismiss(animated: true)
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
}

extension SecondViewContoller: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }
}

extension SecondViewContoller: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "importance", for: indexPath) as! ImportanceSegControlCell
            return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dateSwitch", for: indexPath) as! DateSwitcherCell
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "calendar", for: indexPath) as! CalendarCell
            return cell
        }
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
        importanceSwitcher.insertSegment(withTitle: "!!", at: 2, animated: true)
        importanceSwitcher.selectedSegmentIndex = 1
        importanceSwitcher.backgroundColor = UIColor.lightGray
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

class DateSwitcherCell: UITableViewCell {
    let switcher = UISwitch()
    let label = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        label.text = "Сделать до"
        label.textColor = UIColor.black
        label.font = .systemFont(ofSize: 17)
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            label.heightAnchor.constraint(equalToConstant: 40),
            label.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        switcher.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(switcher)
        switcher.isOn = false
        switcher.onTintColor = UIColor.green
        
        NSLayoutConstraint.activate([
            switcher.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            switcher.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 175),
            switcher.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
//            switcher.heightAnchor.constraint(equalToConstant: 40)
        ])
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
        calendarView.tintColor = UIColor.black
        calendarView.backgroundColor = UIColor.white
//        NSLayoutConstraint.activate([
//            calendarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            calendarView.centerXAnchor.constraint(equalTo: contentView.ce),
//            calendarView.leadingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 175),
//            calendarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
//          switcher.heightAnchor.constraint(equalToConstant: 40)
//        ])
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
