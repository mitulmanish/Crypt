//
//  SelectDateViewController.swift
//  Crypt
//
//  Created by Mitul Manish on 21/1/19.
//  Copyright © 2019 Mitul Manish. All rights reserved.
//

import UIKit

class SelectDateViewController: UIViewController {

    var dateChanged: ((Date) -> ())?

    @IBOutlet weak var doneButton: CurvedButton!
    @IBOutlet weak var datePicker: UIDatePicker!

    let selection = UISelectionFeedbackGenerator()
    private let selectedDate: Date
    
    init(selectedDate: Date) {
        self.selectedDate = selectedDate
        super.init(nibName: nil, bundle: .main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.setValue(UIColor.white, forKey: "textColor")
        datePicker.setDate(selectedDate, animated: false)
        datePicker.maximumDate = Date()
    }

    override func viewDidLayoutSubviews() {
        view.round(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 8)
    }

    @IBAction func dateChanged(_ sender: UIDatePicker) {
        dateChanged?(sender.date)
        selection.selectionChanged()
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
