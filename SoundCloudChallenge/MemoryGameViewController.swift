//
//  MemoryGameViewController.swift
//  SoundCloudChallenge
//
//  Created by David on 2/3/17.
//  Copyright © 2017 DSmith. All rights reserved.
//

import UIKit

class MemoryGameViewController: UIViewController {
    // MARK: Dependency Injection
    var dataStore : CardStore!
    
    // MARK: CollectionView
    fileprivate var collectionView: UICollectionView!
    
    // MARK: Constants
    fileprivate let COLUMNS: CGFloat = 4
    fileprivate let ROWS: CGFloat = 4
    fileprivate let SPACING: CGFloat = 5
    fileprivate let REUSE_IDENTIIFER = "CardCollectionViewCell"
    fileprivate let GAME_OVER_TITLE = "(╯°□°）╯︵ ┻━┻"
    fileprivate let GAME_OVER_MESSAGE = "Game Over!"
    fileprivate let OK_ALERT = "Ok"
    
    
    // MARK: Game Variables
    fileprivate var selectedIndices = [IndexPath]()
    fileprivate var pairs = 0
    
    // MARK: VC Functions
    override func viewDidLoad() {
        setup()
        startGame()
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: CollectionView Setup
// This extension is used to create the layout for the CollectionView and set to the ViewController
extension MemoryGameViewController {
    func setup() {
        let cardHeight: CGFloat = {
            return self.view.frame.height/ROWS - 2*SPACING
        }()
        let cardWidth: CGFloat =  {
            return cardHeight/1.452
        }()
        let collectionViewHeight: CGFloat = {
            return ROWS*(cardHeight + SPACING)
        }()
        let collectionViewWidth: CGFloat = {
            return COLUMNS*(cardWidth + 2*SPACING)
        }()
        let layout: UICollectionViewLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: SPACING, left: SPACING, bottom: SPACING, right: SPACING)
            layout.itemSize = CGSize(width: cardWidth, height: cardHeight)
            layout.minimumLineSpacing = SPACING
            return layout
        }()
    
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: collectionViewWidth, height: collectionViewHeight), collectionViewLayout: layout)
        collectionView.center = view.center
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.register(CardCollectionViewCell.self, forCellWithReuseIdentifier: REUSE_IDENTIIFER)
        self.view.addSubview(collectionView)
        self.view.backgroundColor = UIColor.black
    }
    
    func startGame() {
        collectionView.reloadData()
    }
}

// MARK: CollectionView DataSource
extension MemoryGameViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataStore.getCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: REUSE_IDENTIIFER, for: indexPath) as! CardCollectionViewCell
        cell.backgroundColor = UIColor.red
        return cell
    }
}

// MARK: CollectionView Delegation
extension MemoryGameViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard selectedIndices.count < 2 else {
            return
        }
        selectedIndices.append(indexPath)
        let cell = collectionView.cellForItem(at: indexPath) as! CardCollectionViewCell
        let card = dataStore.getTrackDataAtIndex(index: indexPath.row)
        cell.TURN_UP(card: card)
        guard selectedIndices.count == 2 else{
            return
        }
        let card1 = dataStore.getTrackDataAtIndex(index: selectedIndices[0].row)
        let card2 = dataStore.getTrackDataAtIndex(index: selectedIndices[1].row)
        
        guard card1?.id == card2?.id,
            selectedIndices[0].row != selectedIndices[1].row else {
                turnCardsDown()
                return
        }
        pairs += 1
        removeCards()
        if isFinished() {
            let alert = UIAlertController(title: GAME_OVER_TITLE, message: GAME_OVER_MESSAGE, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: OK_ALERT, style: .default, handler: {
                (action) in
                self.dataStore.randomize()
                self.restartGame(indexPath: indexPath)
                self.dismiss(animated: true, completion: nil)
                return
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: Dispatch Event
extension MemoryGameViewController {
    func delay(delay: Double, completion: @escaping () -> Void) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: completion)
    }
}

// MARK: Utility Functions
extension MemoryGameViewController {
    func removeCards() {
        delay(delay: 1, completion: {
            for index in self.selectedIndices {
                let cell = self.collectionView.cellForItem(at: index) as! CardCollectionViewCell
                cell.BYE_FELICIA()
            }
            self.selectedIndices = [IndexPath]()
        })
    }
    func isFinished() -> Bool {
        if pairs == dataStore.getCount()/2 {
            return true
        }
        return false
    }
    
    func turnCardsDown() {
        delay(delay: 1, completion: {
            for index in self.selectedIndices {
                let cell = self.collectionView.cellForItem(at: index) as! CardCollectionViewCell
                cell.TURN_DOWN_FOR_WHAT()
            }
            self.selectedIndices = [IndexPath]()
        })
    }
    
    // TODO: Implement Function to Restart Game
    func restartGame(indexPath: IndexPath) {
        startGame()
    }
}
