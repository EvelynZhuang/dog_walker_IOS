//
//  TableViewCell.swift
//  itp342FinalProject
//
//  Created by admin on 2021/5/3.
// Yifan Zhuang zhuangyi@usc.edu


import UIKit
import Firebase

protocol tableView{
    func onClickCell(database: DatabaseReference, notMine: Bool, host: String?, index: IndexPath?)
}


class TableViewCell: UITableViewCell {
    var celldelegate: tableView?
    var index: IndexPath?
    var notMine = false
    var registered: Bool?
    var hostUser: String?
    let database = Database.database().reference()
    
    @IBOutlet weak var button: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func didTapButton(_ sender: Any) {
        celldelegate?.onClickCell(database: database, notMine: notMine, host:hostUser, index:index)
    }
}
