//
//  MainViewController.swift
//  StudyReport042020
//
//  Created by Thanh Nguyen Xuan on 5/8/20.
//  Copyright © 2020 Thanh Nguyen Xuan. All rights reserved.
//

import UIKit

enum Country {
    case vietnam
    case japan
    case china
    case korea

    func toString() -> String {
        switch self {
        case .vietnam:
            return "Vietnam 🇻🇳"
        case .japan:
            return "Japan 🇯🇵"
        case .china:
            return "China 🇨🇳"
        case .korea:
            return "Korea 🇰🇷"
        }
    }
}

struct Section {
    var country: Country
    var students: [Student]
}

struct Student: Hashable {
    var name: String
    var country: Country

    // override
    func hash(into hasher: inout Hasher) {
        // Combine thêm name và country để hash value unique
        hasher.combine(name)
        hasher.combine(country)
    }
}

class MainViewController: UIViewController {

    @IBOutlet private weak var studentsTableView: UITableView!

    private var diffableDataSource: StudentTableViewDiffableDataSource!

    private var items: [Student] = []
    private var sections: [Section] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupView()
        buildAndApplySnapshot()
    }

    private func setupData() {
        items = [
            Student(name: "Nguyen Xuan Thanh", country: .vietnam),
            Student(name: "Ikehara Arisu", country: .japan),
            Student(name: "Park Ji Sung", country: .korea),
            Student(name: "Qing Shan", country: .china),
            Student(name: "Kuno Yuka", country: .japan),
            Student(name: "Shimada Tomiko", country: .japan),
            Student(name: "Ying Yue", country: .china),
            Student(name: "Le Thu Trang", country: .vietnam),
            Student(name: "Nguyen Minh Vuong", country: .vietnam),
        ]

        let groupedDict = Dictionary(grouping: items, by: { $0.country })
        sections = groupedDict.map({Section(country: $0.key, students: $0.value)})
    }

    private func setupView() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Shuffle", style: .plain, target: self, action: #selector(shuffleButtonTapped))
        studentsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "StudentCell")
        diffableDataSource = StudentTableViewDiffableDataSource(tableView: studentsTableView) { tableView, indexPath, student -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath)
            cell.textLabel?.text = student.name
            return cell
        }
    }

    @objc private func shuffleButtonTapped() {
        sections = sections.map({
            Section(country: $0.country, students: $0.students.shuffled())
        }).shuffled()
        buildAndApplySnapshot()
    }

    private func buildAndApplySnapshot() {
        // Tạo mới snapshot
        var snapShot = NSDiffableDataSourceSnapshot<Country, Student>()
        // Set list section
        snapShot.appendSections(sections.map({ $0.country }))
        sections.forEach({
            // Set list item cho mỗi section
            snapShot.appendItems($0.students, toSection: $0.country)
        })
        // Apply snapshot mới vào table view với animation
        diffableDataSource.apply(snapShot, animatingDifferences: true, completion: nil)
    }
    
}

class StudentTableViewDiffableDataSource: UITableViewDiffableDataSource<Country, Student> {

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return snapshot().sectionIdentifiers[section].toString()
    }

}
