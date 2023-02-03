//
//  DittoInfoViewController.swift
//  ToDo
//
//  Created by kndoshn on 2020/07/02.
//  Copyright © 2020 DittoLive Incorporated. All rights reserved.
//

import UIKit
import DittoSwift
import DittoPresenceViewer
import DittoExportLogs
import SwiftUI

public struct DittoInfoViewFactory {
    private init() {}
    static func create(ditto: Ditto, bundle: Bundle = Bundle.main) -> DittoInfoViewController {
        let vc = DittoInfoViewController.instantiate()
        vc.ditto = ditto
        vc.bundle = bundle
        return vc
    }
}

fileprivate enum CellInfo: String, CaseIterable {
    case presenceView = "Presence View"
    case sdkInfo = "Ditto SDK Info"
    case prolonged = "Prolonged Background Sync"
    case exportLogs = "Export Logs"


    var index: Int {
        return CellInfo.allCases.firstIndex(of: self)!
    }

    var accessoryType: UITableViewCell.AccessoryType {
        switch self {
        case .presenceView, .sdkInfo:
            return .disclosureIndicator
        case .prolonged:
            return BackgroundSync.shared.isOn ? .checkmark : .none
        case .exportLogs:
            return.none
        }
    }
}

final class DittoInfoViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    fileprivate var ditto: Ditto!
    fileprivate var bundle: Bundle!

    fileprivate static func instantiate() -> Self {
        let sb = UIStoryboard(name: String(describing: "DittoInfoView"), bundle: Bundle(for: DittoInfoViewController.self))
        let vc = sb.instantiateViewController(withIdentifier: String(describing: self))
        return vc as! Self

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.navigationItem.largeTitleDisplayMode = .never
            self.navigationController?.navigationBar.prefersLargeTitles = false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: true)
        }
    }
}

extension DittoInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CellInfo.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dittoInfoCell", for: indexPath)
        let info = toInfo(indexPath)
        cell.textLabel?.text = info.rawValue
        cell.accessoryType = info.accessoryType

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let info = toInfo(indexPath)
        switch info {
        case .presenceView:
            present(DittoPresenceView(ditto: ditto).viewController, animated: true) {
                if let selected = tableView.indexPathForSelectedRow {
                    tableView.deselectRow(at: selected, animated: true)
                }
            }
        case .sdkInfo:
            let storyboard = UIStoryboard(name: "DittoInfoView", bundle: Bundle(for: DittoInfoViewController.self))
            let destination = storyboard.instantiateViewController(withIdentifier: "DittoSDKInfoViewController") as! DittoSDKInfoViewController
            destination.ditto = ditto
            navigationController?.pushViewController(destination, animated: true)
        case .prolonged:
            BackgroundSync.shared.isOn = !BackgroundSync.shared.isOn
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .exportLogs:
            shareDittoLogs()
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UILabel()
        let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        footer.text = "App Version: \(version)(\(build))"
        footer.textAlignment = .center
        footer.textColor = .darkGray
        return footer
    }

    private func toInfo(_ indexPath: IndexPath) -> CellInfo {
        return CellInfo.allCases[indexPath.row]
    }
    
    private func shareDittoLogs() {
        let alert = UIAlertController(title: "Export Logs", message: "Compressing the logs may take a few seconds.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Export", style: .default) { [weak self] _ in
            self?.exportLogs()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }
    
    private func exportLogs() {
        
        let vc = UIHostingController(rootView: ExportLogs())

        present(vc, animated: true)
    }
}
