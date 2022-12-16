//
//  MedicineViewController.swift
//  dddavidkoProject
//
//  Created by Daria D on 9.12.2022.
//

import UIKit
import CoreData

final class MedicineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var tableView: UITableView!
    
    let addButton: UIButton = {
        let control = UIButton()
        control.backgroundColor = .blue
        control.setTitle("Add", for: .normal)
        control.setTitleColor(.white, for: .normal)
        control.titleLabel?.textAlignment = .center
        control.layer.cornerRadius = 15
        control.layer.masksToBounds = true
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    let titleLabel: UILabel = {
        let control = UILabel()
        control.text = "My meds kit"
        control.textAlignment = .left
        control.font = .systemFont(ofSize: 40, weight: .bold)
        control.textColor = .black
        return control
    }()
    
    let datePicker: UIDatePicker = {
        let control = UIDatePicker()
        control.datePickerMode = .date
        control.preferredDatePickerStyle = .wheels
        control.frame.size = CGSize(width: 0, height: 300)
        return control
    }()
    
    var dateInputTextField: UITextField!
    var date: Date?
    
    let cellId = "medCell"
    //var meds = [Medicine]()
    var meds = [Medicine]()
    let cellSpacingHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMeds()
        setupTableView()
        setupUI()
        
        addButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
    }
    
    private func getMeds() {
        let medFetch: NSFetchRequest<Medicine> = Medicine.fetchRequest()
        let sortByName = NSSortDescriptor(key: #keyPath(Medicine.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
            medFetch.sortDescriptors = [sortByName]
            do {
                let managedContext = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
                let results = try managedContext.fetch(medFetch)
                meds = results
            } catch let error as NSError {
                print("Fetch error: \(error) description: \(error.userInfo)")
            }
    }
    
    @objc
    private func addButtonPressed() {
        let alertController = setupAlertController()
        datePicker.addTarget(self, action: #selector(dateChange(datePicker:)), for: .valueChanged)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    private func setupAlertController() -> UIAlertController {
        let alertController = UIAlertController(title: "New medicine", message: "Enter the name and expiry date of the new medicine", preferredStyle: .alert)
        alertController.addTextField{
            (textField) in
            textField.placeholder = "Enter the name of the medicine"
        }
        alertController.addTextField{
            (textField) in
            self.dateInputTextField = textField
            textField.placeholder = "Enter the expiry date"
            textField.inputView = self.datePicker
        }
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alertController] (_) in
            let nameTextfield = alertController?.textFields![0]
            guard let name = nameTextfield?.text else {
                return
            }
            
            if name != "" && self.date != nil {
                //self.meds.append(Medicine(name: name, expiryDate: self.date!))
                let managedContext = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
                let newMed = Medicine(context: managedContext)
                newMed.setValue(name, forKey: #keyPath(Medicine.name))
                newMed.setValue(self.date, forKey: #keyPath(Medicine.expires))
                self.meds.append(newMed)
                AppDelegate.sharedAppDelegate.coreDataStack.saveContext()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        return alertController
    }
    
    @objc
    private func dateChange(datePicker: UIDatePicker) {
        dateInputTextField.text = datePicker.date.formatted(date: .numeric, time: .omitted)
        date = datePicker.date
    }
    
    private func setupTableView() {
        let rect = CGRect(x: 10, y: 110, width: view.frame.width - 30, height: view.frame.height - 110 - 40)
        tableView = UITableView(frame: rect)
        tableView.register(MedicineCell.self, forCellReuseIdentifier: cellId)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = 60
        tableView.showsVerticalScrollIndicator = true
        tableView.backgroundColor = .systemGray6
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return meds.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MedicineCell
        let currentMed = meds[indexPath.section]
        cell.nameLabel.text = currentMed.name
        cell.expiryDateLabel.text = currentMed.expires?.formatted(date: .numeric, time: .omitted)
        // todo colour expiry date
        changeExpiryDateLabelColor(label: cell.expiryDateLabel, expiryDate: currentMed.expires)
        
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        
        return cell
    }
    
    private func changeExpiryDateLabelColor(label: UILabel, expiryDate: Date?) {
        guard let expiryDate = expiryDate else { return }
        if expiryDate <= Date.now{
            label.textColor = .red
        } else {
            guard let daysLeft = Calendar.current.dateComponents([.day], from: Date.now, to: expiryDate).day else { return }
            guard let monthsLeft = Calendar.current.dateComponents([.month], from: Date.now, to: expiryDate).month else { return }
            if daysLeft < 7 {
                label.textColor = .orange
            } else if monthsLeft < 1 {
                label.textColor = .systemYellow
            } else {
                label.textColor = .systemGreen
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // note that indexPath.section is used rather than indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            AppDelegate.sharedAppDelegate.coreDataStack.managedContext.delete(self.meds[indexPath.section])
            meds.remove(at: indexPath.section)
            AppDelegate.sharedAppDelegate.coreDataStack.saveContext()
            tableView.deleteSections(IndexSet.init(integer: indexPath.section), with: .left)
            tableView.endUpdates()
        }
    }
    
    private func setupUI() {
        self.view.backgroundColor = .systemGray6
        self.view.addSubview(titleLabel)
        self.view.addSubview(tableView)
        self.view.addSubview(addButton)
        
        titleLabel.pinTop(to: self.view, 60)
        titleLabel.pinLeft(to: self.view, 10)
        
        //tableView.pinLeft(to: self.view, 10)
        //tableView.pinTop(to: self.view, 60)
        
        addButton.pin(to: self.view, [.left: 24, .right: 24])
        addButton.pinBottom(to: self.view, 20)
    }
}
