//
//  BolusProgressTableViewCell.swift
//  LoopUI
//
//  Created by Pete Schwamb on 3/11/19.
//  Copyright © 2019 LoopKit Authors. All rights reserved.
//

import Foundation
import LoopKit
import HealthKit



public class BolusProgressTableViewCell: UITableViewCell {

    @IBOutlet weak var progressLabel: UILabel!

    @IBOutlet weak var stopSquare: UIView! {
        didSet {
            stopSquare.layer.cornerRadius = 3
        }
    }

    @IBOutlet weak var progressIndicator: RingProgressView!

    public var totalUnits: Double? {
        didSet {
            updateProgress()
        }
    }

    public var deliveredUnits: Double? {
        didSet {
            updateProgress()
        }
    }

    public var unit: HKUnit?

    private lazy var gradient = CAGradientLayer()

    private var doseTotalUnits: Double?

    lazy var quantityFormatter: QuantityFormatter = {
        let formatter = QuantityFormatter()
        formatter.numberFormatter.minimumFractionDigits = 2
        return formatter
    }()

    override public func awakeFromNib() {
        super.awakeFromNib()

        gradient.frame = bounds
        gradient.colors = [UIColor.white.cgColor, UIColor.cellBackgroundColor.cgColor]
        backgroundView?.layer.insertSublayer(gradient, at: 0)
        updateProgressColor()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        gradient.frame = bounds
    }

    public override func tintColorDidChange() {
        super.tintColorDidChange()
        updateProgressColor()
    }

    private func updateProgressColor() {
        progressIndicator.startColor = tintColor
        progressIndicator.endColor = tintColor
        stopSquare.backgroundColor = tintColor
    }

    private func updateProgress() {
        if let totalUnits = totalUnits, let unit = unit {
            let totalUnitsQuantity = HKQuantity(unit: unit, doubleValue: totalUnits)
            let totalUnitsString = quantityFormatter.string(from: totalUnitsQuantity, for: unit) ?? ""

            if let deliveredUnits = deliveredUnits {
                let deliveredUnitsQuantity = HKQuantity(unit: unit, doubleValue: deliveredUnits)
                let deliveredUnitsString = quantityFormatter.string(from: deliveredUnitsQuantity, for: unit) ?? ""

                progressLabel.text = String(format: NSLocalizedString("Bolused %1$@ of %2$@", comment: "The format string for bolus progress. (1: delivered volume)(2: total volume)"), deliveredUnitsString, totalUnitsString)

                let progress = deliveredUnits / totalUnits
                UIView.animate(withDuration: 0.3) {
                    self.progressIndicator.progress = progress
                }
            } else {
                progressLabel.text = String(format: NSLocalizedString("Bolusing %1$@", comment: "The format string for bolus in progress showing total volume. (1: total volume)"), totalUnitsString)
            }
        }
    }
}

extension BolusProgressTableViewCell: NibLoadable { }
