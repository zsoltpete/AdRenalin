//
//  QueueViewController.swift
//  AdRenalin
//
//  Created by Zsolt Pete on 2018. 10. 23..
//  Copyright © 2018. Zsolt Pete. All rights reserved.
//

import UIKit
import MBProgressHUD
import RxCocoa
import RxSwift

class QueueViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MBProgressHUD.showAdded(to: AppDelegate.shared.window!, animated: true)
        DataProvider.shared.getQueuePatient().subscribe(onNext: { patients in
            DataStore.shared.queuedPatients.accept(patients)
            MBProgressHUD.hide(for: AppDelegate.shared.window!, animated: true)
        }).disposed(by: disposeBag)
        self.bindTableView()
        self.tapTableView()
    }
    
    func bindTableView(){
        DataStore.shared.queuedPatients.bind(to: self.tableView.rx.items(cellIdentifier: Constants.Cells.QueueCell)){ (_,model, cell: QueueCell) in
            cell.titleLabel.text = model.name
        }.disposed(by: disposeBag)
    }
    
    func tapTableView(){
        self.tableView.rx.modelSelected(Patient.self).subscribe(onNext: { model in
            DataStore.shared.selectedQueuePatient.accept(model)
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }

}
