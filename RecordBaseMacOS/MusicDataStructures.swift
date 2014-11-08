//
//  File.swift
//  RecordBaseMacOS
//
//  Created by Ruben Parham on 10/31/14.
//  Copyright (c) 2014 Ruben Parham. All rights reserved.
//


// TODO: MDSSong should contain parent: MDSAlbum. MDSAlbum has parent: MDSArtist. This way can go directly from child to parent without searching via id


// TODO: Should probably make array of albums and array of songs actually hold options. Then, after deleting a song or album, can set that space in the array to nil. Getters an still return non-options, just have an assert to check for nil and then return <whatever>!. No one should be trying to access an id that was deleted anyway

import Foundation


// ================= IDS ==================

@objc protocol MDSDataId {
    var idx: Int { get }
    optional var parentId: MDSDataId { get }
}

class MDSArtistId: MDSDataId, Equatable {
    var idx: Int
    init(artistIdx: Int) {
        self.idx = artistIdx
    }
}
func ==(lhs: MDSArtistId, rhs:MDSArtistId) -> Bool {
    return lhs.idx == rhs.idx
}

class MDSAlbumId: MDSDataId, Equatable {
    var idx: Int
    var parentId: MDSArtistId? // TODO: this optional
    
    init(albumIdx: Int, artistId: MDSArtistId) {
        self.idx = albumIdx
        self.parentId = artistId
    }
    
    var artistId: MDSArtistId {
        return parentId!
    }
}
func ==(lhs: MDSAlbumId, rhs:MDSAlbumId) -> Bool {
    return (lhs.idx == rhs.idx &&
            lhs.parentId == rhs.parentId)
}

class MDSSongId: MDSDataId {
    var idx: Int
    var parentId: MDSAlbumId? // TODO: and this one
    init(songIdx: Int, albumId: MDSAlbumId) {
        self.idx = songIdx
        self.parentId = albumId
    }
    
    var albumId: MDSAlbumId {
        return parentId!
    }
    
    var artistId: MDSArtistId {
        return albumId.artistId
    }
}
func ==(lhs: MDSSongId, rhs:MDSSongId) -> Bool {
    return (lhs.idx == rhs.idx &&
            lhs.parentId == rhs.parentId)
}


// ================= DATA ==================

enum MDSDataType: Int {
    case MDSSongType = 0
    case MDSAlbumType = 1
    case MDSArtistType = 2
}

protocol MDSData {
    typealias IdType: MDSDataId
    typealias ParentIdType: MDSDataId
    typealias SelfType: MDSData
    
    var id: IdType { get }
    
    class func dataFromParentElement(#parentId: ParentIdType?, parentElement: NSXMLElement) -> [SelfType]
    
    func asString() -> String
}

protocol MDSSongContainer {
    var numSongs: Int { get }
    func getSong(#idx: Int) -> MDSSong
    func getSong(#songId: MDSSongId, ignoreAssert: Bool) -> MDSSong
    func getSongs() -> MDSIterator<MDSSong>
}

protocol MDSAlbumContainer {
    var numAlbums: Int { get }
    func getAlbum(#idx: Int) -> MDSAlbum
    func getAlbum(#albumId: MDSAlbumId, ignoreAssert: Bool) -> MDSAlbum
    func getAlbums() -> MDSIterator<MDSAlbum>
}

protocol MDSArtistContainer {
    var numArtists: Int { get }
    func getArtist(#idx: Int) -> MDSArtist
    func getArtist(#artistId: MDSArtistId, ignoreAssert: Bool) -> MDSArtist
    func getArtists() -> MDSIterator<MDSArtist>
}


class MDSMusic: NSObject, MDSSongContainer, MDSAlbumContainer, MDSArtistContainer {
    
    // ----- Unique music properties
    private var artists: [MDSArtist]
    
    
    // ----- Conform to artist container protocol
    var numArtists: Int = 0
    
    func getArtist(#idx: Int) -> MDSArtist {
        return artists[idx]
    }
    
    func getArtist(#artistId: MDSArtistId, ignoreAssert: Bool = false) -> MDSArtist {
        return artists[artistId.idx]
    }
    
    func getArtists() -> MDSIterator<MDSArtist> {
        return MDSBaseIterator<MDSArtist>(list: artists)
    }
    
    
    // ----- Conform to album container protocol
    var numAlbums: Int = 0
    
    func getAlbum(#idx: Int) -> MDSAlbum {
        var curArtistIdx = -1, curAlbumIdx = -1, prevAlbumIdx = -1
        
        while curAlbumIdx < idx {
            curArtistIdx++
            assert(curArtistIdx < numArtists)
            
            prevAlbumIdx = curAlbumIdx
            curAlbumIdx += getArtist(idx: curArtistIdx).numAlbums
        }
        
        var newIdx = idx - (prevAlbumIdx + 1)
        return getArtist(idx: curArtistIdx).getAlbum(idx: newIdx)
    }
    
    func getAlbum(#albumId: MDSAlbumId, ignoreAssert: Bool = false) -> MDSAlbum {
        return getArtist(artistId: albumId.artistId).getAlbum(albumId: albumId, ignoreAssert: true)
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
    
    // Conform to song container protocol
    var numSongs: Int = 0
    
    func getSong(#idx: Int) -> MDSSong {
        var curArtistIdx = -1, curSongIdx = -1, prevSongIdx = -1
        
        while curSongIdx < idx {
            curArtistIdx++
            assert(curArtistIdx < numArtists)
            
            prevSongIdx = curSongIdx
            curSongIdx += getArtist(idx: curArtistIdx).numSongs
        }
        
        var newIdx = idx - (prevSongIdx + 1)
        return getArtist(idx: curArtistIdx).getSong(idx: newIdx)
    }
    
    func getSong(#songId: MDSSongId, ignoreAssert: Bool = false) -> MDSSong {
        return getAlbum(albumId: songId.albumId).getSong(songId: songId, ignoreAssert: true)
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
    
    // ----- Initializers
    init(artists: [MDSArtist]) {
        self.artists = artists
        self.numArtists = self.artists.count
        for artist in self.artists {
            self.numAlbums += artist.numAlbums
            self.numSongs += artist.numSongs
        }
    }
    
    convenience init(musicElement element: NSXMLElement) {
        assert(element.name == "music")
        
        self.init(artists: MDSArtist.dataFromParentElement(parentId: nil, parentElement: element))
    }
}

class MDSArtist: MDSData, MDSSongContainer, MDSAlbumContainer {
    
    // ----- Unique artist properties
    var name: String
    
    private var albums: [MDSAlbum]
    
    // ----- Conform to MDSData protocol
    var id: MDSArtistId
    
    class func dataFromParentElement(#parentId: MDSDataId?, parentElement: NSXMLElement) -> [MDSArtist] {
        assert(parentId == nil)
        
        var artistIdx: Int = 0
        var result = [MDSArtist]()
        
        for artistElement in parentElement.elementsForName("artist") as [NSXMLElement] {
            var newId = MDSArtistId(artistIdx: artistIdx)
            result.append(MDSArtist(id: newId, artistElement: artistElement))
            artistIdx++
        }
        
        return result
    }
    
    func asString() -> String {
        return "Artist: " + name
    }
    
    
    // ----- Conform to album container protocol
    var numAlbums: Int = 0
    
    func getAlbum(#idx: Int) -> MDSAlbum {
        return albums[idx]
    }
    
    func getAlbum(#albumId: MDSAlbumId, ignoreAssert: Bool = false) -> MDSAlbum {
        if !ignoreAssert { assert(albumId.artistId == id) }
        return getAlbum(idx: albumId.idx)
    }
    
    func getAlbums() -> MDSIterator<MDSAlbum> {
        return MDSBaseIterator<MDSAlbum>(list: albums)
    }
    
    
    // ----- Conform to song container protocol
    var numSongs: Int = 0
    
    func getSong(#idx: Int) -> MDSSong {
        var curAlbumIdx = -1
        var curSongIdx = -1
        var prevSongIdx = curSongIdx
        
        while curSongIdx < idx {
            curAlbumIdx++
            assert(curAlbumIdx < numAlbums)
            
            prevSongIdx = curSongIdx
            curSongIdx += getAlbum(idx: curAlbumIdx).numSongs
        }
        
        var newIdx = idx - (prevSongIdx + 1)
        return getAlbum(idx: curAlbumIdx).getSong(idx: newIdx)
        
    }
    
    func getSong(#songId: MDSSongId, ignoreAssert: Bool = false) -> MDSSong {
        if !ignoreAssert { assert(songId.artistId == id) }
        return getAlbum(albumId: songId.albumId).getSong(songId: songId, ignoreAssert: true)
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
    
    
    // ----- Initializers
    init(id: MDSArtistId, name: String, albums: [MDSAlbum]) {
        self.id = id
        self.name = name
        self.albums = albums
        self.numAlbums = self.albums.count
        for album in self.albums {
            self.numSongs += album.numSongs
        }
    }
    
    convenience init(id: MDSArtistId, artistElement element: NSXMLElement) {
        assert(element.name == "artist")
        
        self.init(
            id: id,
            name: element.elementsForName("name")[0].stringValue,
            albums: MDSAlbum.dataFromParentElement(parentId: id, parentElement: element)
        )
    }
}

class MDSAlbum: MDSData, MDSSongContainer {
    // ----- Unique album properties
    var title: String
    var artistId: MDSArtistId {
        return id.artistId
    }
    
    private var songs: [MDSSong]
    
    // ----- Conform to MDSData protocol
    var id: MDSAlbumId
    
    class func dataFromParentElement(#parentId: MDSArtistId?, parentElement: NSXMLElement) -> [MDSAlbum] {
        assert(parentId != nil)
        
        var albumIdx: Int = 0
        var result = [MDSAlbum]()
        
        for albumElement in parentElement.elementsForName("album") as [NSXMLElement] {
            var newId = MDSAlbumId(albumIdx: albumIdx, artistId: parentId!)
            result.append(MDSAlbum(id: newId, albumElement: albumElement))
            albumIdx++
        }
        
        return result
    }
    
    func asString() -> String {
        return "Album: " + title
    }
    
    
    // ----- Conform to song container protocol
    var numSongs: Int = 0
    
    func getSong(#idx: Int) -> MDSSong {
        return songs[idx]
    }
    
    func getSong(#songId: MDSSongId, ignoreAssert: Bool = false) -> MDSSong {
        if !ignoreAssert { assert(songId.albumId == id) }
        return getSong(idx: songId.idx)
    }
    
    func getSongs() -> MDSIterator<MDSSong> {
        return MDSBaseIterator<MDSSong>(list: songs)
    }
    
    
    // ----- Initializers
    init(id: MDSAlbumId, title: String, songs :[MDSSong]) {
        self.id = id
        self.title = title
        self.songs = songs
        self.numSongs = self.songs.count
    }
    
    convenience init(id: MDSAlbumId, albumElement element: NSXMLElement) {
        assert(element.name == "album")
        
        self.init(
            id: id,
            title: element.elementsForName("title")[0].stringValue,
            songs: MDSSong.dataFromParentElement(parentId: id, parentElement: element)
        )
    }
}

class MDSSong: MDSData {
    
    // ----- Unique song properties
    var title: String
    var albumId: MDSAlbumId {
        return id.albumId
    }
    var artistId: MDSArtistId {
        return id.artistId
    }
    
    
    // ----- Conform to MDSData protocol
    var id: MDSSongId
    
    class func dataFromParentElement(#parentId: MDSAlbumId?, parentElement: NSXMLElement) -> [MDSSong] {
        assert (parentId != nil)
        
        var songIdx: Int = 0
        var result = [MDSSong]()
        
        for songElement in parentElement.elementsForName("song") as [NSXMLElement] {
            var newId = MDSSongId(songIdx: songIdx, albumId: parentId!)
            result.append(MDSSong(id: newId, songElement: songElement))
            songIdx++
        }
        
        return result
    }
    
    func asString() -> String {
        return "Song: " + title
    }
    
    // ----- Initializers
    init(id: MDSSongId, title: String) {
        self.id = id
        self.title = title
    }
    
    convenience init(id: MDSSongId, songElement element: NSXMLElement) {
        assert(element.name == "song")
        
        self.init(id: id, title: element.elementsForName("title")[0].stringValue)
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