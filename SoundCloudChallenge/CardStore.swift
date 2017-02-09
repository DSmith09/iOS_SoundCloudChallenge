//
//  CardStore.swift
//  SoundCloudChallenge
//
//  Created by David on 2/3/17.
//  Copyright © 2017 DSmith. All rights reserved.
//

import UIKit

// MARK: Global Variables
private let SOUNDCLOUD_URL = URL(string: "http://api.soundcloud.com/playlists/79670980?client_id=aa45989bb0c262788e2d11f1ea041b65")!
private let TRACKS = "tracks"
private let TRACK = "track"
private let ID = "id"
private let ARTWORK_URL = "artwork_url"

private let BEGINNING_INDEX = 0
private let END_INDEX = 8

// MARK: Typealiases
private typealias JSONDictionary = [String:Any]

class CardStore {
    // MARK: Array Data Structure
    private var cards = [TrackData]()
    
    // MARK: Init
    /**
     Retrieves the data from the Sound Cloud API if successful -> Retrieves the track images as well
     After successful card storage -> Randomizes order
    */
    init() {
        let taskGroup = DispatchGroup()
        taskGroup.enter()
        load(resource: TrackData.allTracks, completion: {
            (result) in
            guard let resultData = result else {
                print("Failed to load data properly")
                return
            }
            print("Successfully loaded TrackData - Retrieving Images Now")
            for card in resultData {
                taskGroup.enter()
                self.load(resource: Resource(url: card.artworkURL, parse: {
                    (data) -> UIImage? in
                    guard let image = UIImage(data: data) else {
                        return nil
                    }
                    return image
                }), completion: {
                    (result) in
                    guard let image = result else {
                        print("Failed to retrieve image (╯°□°）╯︵ ┻━┻")
                        taskGroup.leave()
                        return
                    }
                    var mutableCard = card
                    mutableCard.setImage(image: image)
                    self.cards.append(mutableCard)
                    taskGroup.leave()
                    return
                })
            }
            taskGroup.leave()
        })
        // Wait for init to complete before randomizing order
        taskGroup.wait(timeout: .distantFuture)
        manipulateData()
        randomize()
    }
    
    // MARK: Card Store Functions
    public func getCount() -> Int {
        return cards.count
    }
    
    public func getTrackDataAtIndex(index: Int) -> TrackData? {
        return cards[index]
    }
    
    // MARK: Load Data
    // I wanted to make this as generic as possible for both the track data and Artwork Image
    private func load<A>(resource: Resource<A>, completion: @escaping (A?) -> ()) {
        URLSession.shared.dataTask(with: resource.url, completionHandler: {
            (data, _, _) in
            guard let jsonData = data else {
                completion(nil)
                return
            }
            completion(resource.parse(jsonData))
        }).resume()
    }
    
    // MARK: Randomize Order of Cards
    public func randomize() {
        var list = cards
        for i in 0..<(list.count - 1) {
            let j = Int(arc4random_uniform(UInt32(list.count - 1))) + 1
            guard i != j else {
                continue
            }
            swap(&list[i], &list[j])
        }
        cards = list
    }
    
    // MARK: Data Manipulation
    // SoundCloud API is only returning 12 images -> Need 16 for 4 x 4 Game
    private func manipulateData() {
        cards = Array(cards[BEGINNING_INDEX..<END_INDEX]) + Array(cards[BEGINNING_INDEX..<END_INDEX])
    }
}

// MARK: Structures
struct Resource<A> {
    let url: URL
    let parse: (Data) -> A?
}

struct TrackData {
    let id: String
    let artworkURL: URL
    var image: UIImage?
    var hidden = true
    
    // Setters
    mutating func setImage(image: UIImage) {
        self.image = image
    }
    
    mutating func setHidden(hidden: Bool) {
        self.hidden = hidden
    }
}

// MARK: Structure Extensions
// Created extension for initializer to preserve default init
extension Resource {
    init(url: URL, parseJSON: @escaping (Any) -> A?) {
        self.url = url
        self.parse = {
            (data) in
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
            return jsonObject.flatMap(parseJSON)
        }
    }
}

extension TrackData {
    private init?(track: JSONDictionary) {
        guard let id = track[ID] as? Int,
            let artworkURL = track[ARTWORK_URL] as? String else {
            return nil
        }
        self.id = String(stringInterpolationSegment: id)
        self.artworkURL = URL(string: artworkURL)!
    }
    
    static let allTracks = Resource<[TrackData]>(url: SOUNDCLOUD_URL, parseJSON: {
        (jsonData) in
        guard let dictionaries = jsonData as? JSONDictionary,
            let tracks = dictionaries[TRACKS] as? [JSONDictionary] else {
            print("Failed to convert jsonData to TrackData (╯°□°）╯︵ ┻━┻")
            return nil
        }
        print("Successfully pulled TrackData from jsonData")
        return tracks.flatMap(TrackData.init)
    })
}
