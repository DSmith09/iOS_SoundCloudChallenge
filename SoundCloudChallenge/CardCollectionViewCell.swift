//
//  CardCollectionViewCell.swift
//  SoundCloudChallenge
//
//  Created by David on 2/4/17.
//  Copyright © 2017 DSmith. All rights reserved.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    // MARK: View Variables
    var imageView: UIImageView!
  
    // MARK: Init
    override init(frame: CGRect) {
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        super.init(frame: frame)
        self.contentView.addSubview(imageView)
        self.contentView.backgroundColor = UIColor.clear
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Core Functions
    private func updateWithImage(card: TrackData?) {
        guard let cardData = card,
        let imageToView = cardData.image else {
            imageView.image = nil
            imageView.backgroundColor = UIColor.red
            return
        }
        imageView.image = imageToView
    }
    
    // Turns Card Face Up
    func TURN_UP(card: TrackData?) {
        UIView.transition(with: contentView, duration: 1, options: .transitionCrossDissolve, animations: {
            self.updateWithImage(card: card)
        }, completion: nil)
    }
    
    // Turns Card Face Down
    func TURN_DOWN_FOR_WHAT() {
        UIView.transition(with: contentView, duration: 1, options: .transitionCrossDissolve, animations: {
            self.updateWithImage(card: nil)
        }, completion: nil)
    }
    
    // Removes Card From the View
    func BYE_FELICIA() {
        UIView.animate(withDuration: 1, animations: {
            self.alpha = 0
        }, completion: {
            (result) in
            self.isHidden = true
        })
    }
    
    // MARK: Overridable Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        updateWithImage(card: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        updateWithImage(card: nil)
    }
}
