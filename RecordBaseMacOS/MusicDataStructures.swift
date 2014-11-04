//
//  File.swift
//  RecordBaseMacOS
//
//  Created by Ruben Parham on 10/31/14.
//  Copyright (c) 2014 Ruben Parham. All rights reserved.
//


// TODO: Should probably make array of albums and array of songs actually hold options. Then, after deleting a song or album, can set that space in the array to nil. Getters an still return non-options, just have an assert to check for nil and then return <whatever>!. No one should be trying to access an id that was deleted anyway

// TODO: Add iterators for artists, albums and songs in music, artist and album classes

// TODO: Idea, instead of each class having a getter for all its children that returns an array, have a subclass that's an iterator and a getter that returns that iterator. Then, for example, an album iterator has an idx var and returns songs one by one and finally nil. An artist iterator has an idx var AND an album iterator. Once the album iterator returns nil, it moves on to the next album. etc... YAY! I think not allowing anyone to get a hold of the full array is A-OK. The can get any individual element by using its id, and if music is a singleton everyone has access, meaning no one needs to pass "the whole array" to anyone else. Yeah, returning the whole array is needless (and potentially wasteful) functionality. We lose control over setting it that way as well. The iterator can just return the array's values. Then the only way to update a value is to go through an API method. BUENO!!! Now I'm tired

import Foundation


// ================= IDS ==================

typealias MDSArtistId = Int
typealias MDSAlbumId = (MDSArtistId, Int)
typealias MDSSongId = (MDSAlbumId, Int)

func == (id1: MDSAlbumId, id2: MDSAlbumId) -> Bool {
    return (id1.0 == id2.0) && (id1.1 == id2.1)
}

func == (id1: MDSSongId, id2: MDSSongId) -> Bool {
    return (id1.0 == id2.0) && (id1.1 == id2.1)
}


// ================= DATA ==================

class MDSData: NSObject {
    
    class func getAlbumId(songId: MDSSongId) -> MDSAlbumId {
        return songId.0
    }
    
    class func getArtistId(albumId: MDSAlbumId) -> MDSArtistId {
        return albumId.0
    }
    
    class func getArtistId(songId: MDSSongId) -> MDSArtistId {
        return MDSData.getArtistId(MDSData.getAlbumId(songId))
    }
}

// TODO: make this class a singleton with a get and reset method (rather than initialization)
class MDSMusic: NSObject {
    
    private var artists: [MDSArtist]
    
    init(artists: [MDSArtist]) {
        self.artists = artists
    }
    
    convenience init(musicElement element: NSXMLElement) {
        assert(element.name == "music")
        
        self.init(artists: MDSArtist.artistsFromMusicElement(musicElement: element))
    }
    
    // Children Getters
    // -- Single
    func getArtist(artistId: MDSArtistId) -> MDSArtist {
        return artists[artistId]
    }
    func getAlbum(albumId: MDSAlbumId) -> MDSAlbum {
        return getArtist(MDSData.getArtistId(albumId)).getAlbum(albumId, ignoreAssert: true)
    }
    func getSong(songId: MDSSongId) -> MDSSong {
        return getAlbum(MDSData.getAlbumId(songId)).getSong(songId, ignoreAssert: true)
    }
    // -- Multiple
    func getArtists() -> MDSIterator<MDSArtist> {
        return MDSBaseIterator<MDSArtist>(list: artists)
    }
    func getAlbums() -> MDSIterator<MDSAlbum> {
        return MDSParentIterator<MDSArtist, MDSAlbum>(
            list: artists,
            getInnerIterator: {
                (artist: MDSArtist) -> MDSIterator<MDSAlbum> in
                return artist.getAlbums()
            }
        )
    }
    func getSongs() -> MDSIterator<MDSSong> {
        return MDSParentIterator<MDSArtist, MDSSong>(
            list: artists,
            getInnerIterator: {
                (artist: MDSArtist) -> MDSIterator<MDSSong> in
                return artist.getSongs()
            }
        )
    }
}

class MDSArtist: MDSData {
    private var id: MDSArtistId
    private var albums: [MDSAlbum]
    
    var name: String
    
    init(id: MDSArtistId, name: String, albums: [MDSAlbum]) {
        self.id = id
        self.name = name
        self.albums = albums
    }
    
    convenience init(id: MDSArtistId, artistElement element: NSXMLElement) {
        assert(element.name == "artist")
        
        self.init(
            id: id,
            name: element.elementsForName("name")[0].stringValue,
            albums: MDSAlbum.albumsFromArtistElement(artistId: id, artistElement: element)
        )
    }
    
    // Id Getters
    func getId() -> MDSArtistId {
        return id
    }
    
    
    // Children Getters
    func getAlbum(albumId: MDSAlbumId, ignoreAssert: Bool = false) -> MDSAlbum {
        if !ignoreAssert { assert(MDSData.getArtistId(albumId) == id) }
        return albums[albumId.1]
    }
    func getSong(songId: MDSSongId, ignoreAssert: Bool = false) -> MDSSong {
        if !ignoreAssert { assert(MDSData.getArtistId(songId) == id) }
        return getAlbum(MDSData.getAlbumId(songId)).getSong(songId, ignoreAssert: true)
    }
    func getAlbums() -> MDSIterator<MDSAlbum> {
        return MDSBaseIterator<MDSAlbum>(list: albums)
    }
    func getSongs() -> MDSIterator<MDSSong> {
        return MDSParentIterator<MDSAlbum, MDSSong>(
            list: albums,
            getInnerIterator: {
                (album: MDSAlbum) -> MDSIterator<MDSSong> in
                return album.getSongs()
            }
        )
    }
    
    
    // Children Setters
    // TODO
    
    
    class func artistsFromMusicElement(#musicElement: NSXMLElement) -> [MDSArtist] {
        var artistIdx: Int = 0
        var result = [MDSArtist]()
        
        for artistElement in musicElement.elementsForName("artist") as [NSXMLElement] {
            result.append(MDSArtist(id: artistIdx, artistElement: artistElement))
            artistIdx++
        }
        
        return result
    }
}

class MDSAlbum: MDSData {
    private var id: MDSAlbumId
    private var songs: [MDSSong]
    
    var title: String
    
    // Initialize album using list of songs
    init(id: MDSAlbumId, title: String, songs :[MDSSong]) {
        self.id = id
        self.title = title
        self.songs = songs
    }
    
    // Initialize album using xml element of type "album"
    convenience init(id: MDSAlbumId, albumElement element: NSXMLElement) {
        assert(element.name == "album")
        
        self.init(
            id: id,
            title: element.elementsForName("title")[0].stringValue,
            songs: MDSSong.songsFromAlbumElement(albumId: id, albumElement: element)
        )
    }
    
    // Id Getters
    func getId() -> MDSAlbumId {
        return id
    }
    func getArtistId() -> MDSArtistId {
        return MDSData.getArtistId(id)
    }
    
    
    // Children Getters
    func getSong(songId: MDSSongId, ignoreAssert: Bool = false) -> MDSSong {
        if !ignoreAssert { assert(MDSData.getAlbumId(songId) == id) }
        return songs[songId.1]
    }
    func getSongs() -> MDSIterator<MDSSong> {
        return MDSBaseIterator<MDSSong>(list: songs)
    }
    
    // Children Setters
    // TODO
    
    
    // Get all albums under xml element of type "artist" as array of MDSAlbum objects
    class func albumsFromArtistElement(#artistId: MDSArtistId, artistElement: NSXMLElement) -> [MDSAlbum] {
        var albumIdx: Int = 0
        var result = [MDSAlbum]()
        
        for albumElement in artistElement.elementsForName("album") as [NSXMLElement] {
            result.append(MDSAlbum(id: (artistId, albumIdx), albumElement: albumElement))
            albumIdx++
        }
        
        return result
    }
}

class MDSSong: MDSData {
    
    private var id: MDSSongId
    
    var title: String
    
    // Initialize song
    init(id: MDSSongId, title: String) {
        self.id = id
        self.title = title
    }
    
    // Initialize song using xml element of type "song"
    convenience init(id: MDSSongId, songElement element: NSXMLElement) {
        assert(element.name == "song")
        
        self.init(id: id, title: element.elementsForName("title")[0].stringValue)
    }
    
    // Id Getters
    func getId() -> MDSSongId {
        return id
    }
    func getAlbumId() -> MDSAlbumId {
        return MDSData.getAlbumId(id)
    }
    func getArtistId() -> MDSArtistId {
        return MDSData.getArtistId(id)
    }
    
    // Get all songs under xml element of type "album" as array of MDSSong objects
    class func songsFromAlbumElement(#albumId: MDSAlbumId, albumElement: NSXMLElement) -> [MDSSong] {
        var songIdx: Int = 0
        var result = [MDSSong]()
        
        for songElement in albumElement.elementsForName("song") as [NSXMLElement] {
            result.append(MDSSong(id: (albumId, songIdx), songElement: songElement))
            songIdx++
        }
        
        return result
    }
}


// ================= ITERATORS ==================

// Should really be a protocol but swift is stupid and doesn't have generics for protocols
// (and I don't feel like using an associated type, not trying to cast the result of next() every 2 seconds)
class MDSIterator<T>: NSObject {
    func next() -> T? {
        return nil
    }
}

class MDSBaseIterator<T>: MDSIterator<T> {
    private var idx: Int
    private var list: [T]
    
    init(list: [T], startIdx: Int = 0) {
        assert(startIdx < list.count)
        
        self.idx = startIdx
        self.list = list
    }
    
    override func next() -> T? {
        return (idx < list.count) ? list[idx++] : nil
    }
}

class MDSParentIterator<P, T>: MDSIterator<T> {
    private var idx: Int
    private var list: [P]
    private var getInnerIterator: (P) -> MDSIterator<T>
    private var innerIterator: MDSIterator<T>
    
    init(list: [P], getInnerIterator: (P) -> MDSIterator<T>, startIdx: Int = 0) {
        assert(startIdx < list.count)
        
        self.idx = startIdx
        self.list = list
        self.getInnerIterator = getInnerIterator
        self.innerIterator = self.getInnerIterator(self.list[self.idx++])
    }
    
    override func next() -> T? {
        var result: T? = innerIterator.next()
        while result == nil {
            if idx >= list.count {
                return nil
            }
            
            innerIterator = getInnerIterator(list[idx++])
            result = innerIterator.next()
        }
        
        return result
    }
}