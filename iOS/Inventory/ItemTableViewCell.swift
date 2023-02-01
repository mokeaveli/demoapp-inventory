//
//  ItemTableViewCell.swift
//  Inventory
//
//  Created by Ditto on 6/27/18.
//  Copyright © 2018 Ditto. All rights reserved.
//

import UIKit
import Cartography

final class ItemViewModel {

    let itemId: Int
    let image: UIImage?
    let title: String
    let price: Double
    let detail: String
    var count: Int = 0

    init(itemId: Int, image: UIImage?, title: String, price: Double, detail: String) {
        self.itemId = itemId;
        self.image = image
        self.title = title
        self.price = price
        self.detail = detail
    }
}

protocol ItemTableViewCellDelegate: AnyObject {
    func plusButtonDidClick(itemId: Int)
    func minusButtonDidClick(itemId: Int)
}


final class ItemTableViewCell: UITableViewCell {

    static let REUSE_ID = "ItemTableViewCell"
    static let HEIGHT: CGFloat = 150

    weak var delegate: ItemTableViewCellDelegate?
    var item: ItemViewModel?

    lazy var itemImageView: UIImageView = {
        let i = UIImageView()
        i.backgroundColor = .gray
        i.contentMode = .scaleAspectFill
        i.layer.cornerRadius = 5.0
        i.layer.masksToBounds = true
        return i
    }()

    lazy var itemTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.numberOfLines = 0
        return label
    }()

    lazy var itemCounterLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 25)
        return label
    }()

    lazy var plusButton: UIButton = {
        let button = UIButton()
        button.setTitle("+", for: .normal)
        button.backgroundColor = Constants.Colors.mainColor
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        return button
    }()

    lazy var minusButton: UIButton = {
        let button = UIButton()
        button.setTitle("-", for: .normal)
        button.backgroundColor = Constants.Colors.mainColor
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        return button
    }()

    var currentCount: Int?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(itemImageView)
        contentView.addSubview(itemTitleLabel)
        contentView.addSubview(itemCounterLabel)

        contentView.addSubview(plusButton)
        contentView.addSubview(minusButton)

        selectionStyle = .none
        constrain([itemImageView, itemTitleLabel, plusButton, minusButton, itemCounterLabel]) { (proxies) in
            let itemImageView = proxies[0]
            let itemTitleLabel = proxies[1]
            let plusButton = proxies[2]
            let minusButton = proxies[3]
            let itemCounterLabel = proxies[4]

            itemImageView.left == itemImageView.superview!.left + 16
            itemImageView.top == itemImageView.superview!.top + 16
            itemImageView.height == 120
            itemImageView.width == 120

            plusButton.height == 40
            plusButton.width == 40
            plusButton.bottom == itemImageView.bottom
            plusButton.right == plusButton.superview!.right - 16

            minusButton.height == 40
            minusButton.width == 40
            minusButton.bottom == itemImageView.bottom
            minusButton.right == plusButton.left - 16

            itemCounterLabel.right == plusButton.right
            itemCounterLabel.left == minusButton.left
            itemCounterLabel.top == itemImageView.top
            itemCounterLabel.bottom == plusButton.top - 8

            itemTitleLabel.left == itemImageView.right + 8
            itemTitleLabel.top == itemImageView.top
            itemTitleLabel.bottom == itemImageView.bottom
            itemTitleLabel.right == itemCounterLabel.left - 8
        }

        plusButton.addTarget(self, action: #selector(plusButtonDidClick), for: .touchUpInside)
        minusButton.addTarget(self, action: #selector(minusButtonDidClick), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(item: ItemViewModel) {
        self.item = item
        itemImageView.image = item.image
        itemTitleLabel.attributedText = {
            let attributedText = NSMutableAttributedString()
            attributedText.append(NSAttributedString(string: item.title, attributes: [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 25)
                ]))
            attributedText.append(NSAttributedString(string: "\n\(item.detail.uppercased())", attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .light),
                NSAttributedString.Key.foregroundColor: UIColor(red: 127/255, green: 140/255, blue: 141/255, alpha: 1)
                ]))
            
            attributedText.append(NSAttributedString(string: "\n\(String(format: "$%.02f", item.price))", attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)
                ]))
            return attributedText
        }()
        updateItemCount(count: item.count)
    }

    func updateItemCount(count: Int) {
        itemCounterLabel.attributedText = {
            let attributedText = NSMutableAttributedString()
            attributedText.append(NSAttributedString(string: "Quantity", attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .light),
                NSAttributedString.Key.foregroundColor: UIColor(red: 127/255, green: 140/255, blue: 141/255, alpha: 1),
                NSAttributedString.Key.paragraphStyle: {
                    let p = NSMutableParagraphStyle()
                    p.alignment = .center
                    return p
                }()
            ]))
            attributedText.append(NSAttributedString(string: "\n\(count)", attributes: [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 25),
                NSAttributedString.Key.paragraphStyle: {
                    let p = NSMutableParagraphStyle()
                    p.alignment = .center
                    return p
                }()
            ]))
            return attributedText
        }()
    }

    func animateBackground() {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.allowUserInteraction, .transitionCrossDissolve], animations: {
            self.backgroundColor = Constants.Colors.lightHighlightColor
        }, completion: nil)
        UIView.animate(withDuration: 0.25, delay: 0.25, options: [.allowUserInteraction, .transitionCrossDissolve], animations: {
            self.backgroundColor = .white
        }, completion: nil)
    }

    @objc func plusButtonDidClick() {
        guard let delegate = self.delegate, let item = self.item else { return }
        delegate.plusButtonDidClick(itemId: item.itemId)
    }

    @objc func minusButtonDidClick() {
        guard let delegate = self.delegate, let item = self.item else { return }
        delegate.minusButtonDidClick(itemId: item.itemId)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.currentCount = nil
        self.item = nil
        self.backgroundColor = .white
    }
}
