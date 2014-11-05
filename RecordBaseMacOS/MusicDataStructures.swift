//
//  File.swift
//  RecordBaseMacOS
//
//  Created by Ruben Parham on 10/31/14.
//  Copyright (c) 2014 Ruben Parham. All rights reserved.
//


// TODO: Should probably make array of albums and array of songs actually hold options. Then, after deleting a song or album, can set that space in the array to nil. Getters an still return non-options, just have an assert to check for nil and then return <whatever>!. No one should be trying to access an id that was deleted anyway

// TODO: Replace all the getX(idx: Int) -> X functions with [] (subtitle?) definitions for clarity

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

protocol MDSSongContainer {
    func getNumSongs() -> Int
    func getSong(#idx: Int) -> MDSSong
    func getSong(#songId: MDSSongId, ignoreAssert: Bool) -> MDSSong
    func getSongs() -> MDSIterator<MDSSong>
}

protocol MDSAlbumContainer {
    func getNumAlbums() -> Int
    func getAlbum(#idx: Int) -> MDSAlbum
    func getAlbum(#albumId: MDSAlbumId, ignoreAssert: Bool) -> MDSAlbum
    func getAlbums() -> MDSIterator<MDSAlbum>
}

protocol MDSArtistContainer {
    func getNumArtists() -> Int
    func getArtist(#idx: Int) -> MDSArtist
    func getArtist(#artistId: MDSArtistId, ignoreAssert: Bool) -> MDSArtist
    func getArtists() -> MDSIterator<MDSArtist>
}

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
class MDSMusic: NSObject, MDSSongContainer, MDSAlbumContainer, MDSArtistContainer {
    
    private var artists: [MDSArtist]
    private var numArtists: Int = 0
    private var numAlbums: Int = 0
    private var numSongs: Int = 0
    
    init(artists: [MDSArtist]) {
        self.artists = artists
        self.numArtists = self.artists.count
        for artist in self.artists {
            self.numAlbums += artist.getNumAlbums()
            self.numSongs += artist.getNumSongs()
        }
    }
    
    convenience init(musicElement element: NSXMLElement) {
        assert(element.name == "music")
        
        self.init(artists: MDSArtist.artistsFromMusicElement(musicElement: element))
    }
    
    // Conform to song container protocol
    func getNumSongs() -> Int { return numSongs }
    
    func getSong(#idx: Int) -> MDSSong {
        var curArtistIdx = -1, curSongIdx = -1, prevSongIdx = -1
        
        while curSongIdx < idx {
            curArtistIdx++
            assert(curArtistIdx < numArtists)
            
            prevSongIdx = curSongIdx
            curSongIdx += getArtist(idx: curArtistIdx).getNumSongs()
        }
        
        var newIdx = idx - (prevSongIdx + 1)
        return getArtist(idx: curArtistIdx).getSong(idx: newIdx)
    }
    
    func getSong(#songId: MDSSongId, ignoreAssert: Bool = false) -> MDSSong {
        return getAlbum(albumId: MDSData.getAlbumId(songId)).getSong(songId: songId, ignoreAssert: true)
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
    
    
    // Conform to album container protocol
    func getNumAlbums() -> Int { return numAlbums }
    
    func getAlbum(#idx: Int) -> MDSAlbum {
        var curArtistIdx = -1, curAlbumIdx = -1, prevAlbumIdx = -1
        
        while curAlbumIdx < idx {
            curArtistIdx++
            assert(curArtistIdx < numArtists)
            
            prevAlbumIdx = curAlbumIdx
            curAlbumIdx += getArtist(idx: curArtistIdx).getNumAlbums()
        }
        
        var newIdx = idx - (prevAlbumIdx + 1)
        return getArtist(idx: curArtistIdx).getAlbum(idx: newIdx)
    }
    
    func getAlbum(#albumId: MDSAlbumId, ignoreAssert: Bool = false) -> MDSAlbum {
        return getArtist(artistId: MDSData.getArtistId(albumId)).getAlbum(albumId: albumId, ignoreAssert: true)
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
    
    
    // Conform to artist container protocol
    
    func getNumArtists() -> Int { return numArtists }
    
    func getArtist(#idx: Int) -> MDSArtist {
        return artists[idx]
    }
    
    func getArtist(#artistId: MDSArtistId, ignoreAssert: Bool = false) -> MDSArtist {
        return artists[artistId]
    }

    func getArtists() -> MDSIterator<MDSArtist> {
        return MDSBaseIterator<MDSArtist>(list: artists)
    }
}

class MDSArtist: MDSData, MDSSongContainer, MDSAlbumContainer {
    private var id: MDSArtistId
    private var albums: [MDSAlbum]
    private var numAlbums: Int = 0
    private var numSongs: Int = 0
    
    var name: String
    
    init(id: MDSArtistId, name: String, albums: [MDSAlbum]) {
        self.id = id
        self.name = name
        self.albums = albums
        self.numAlbums = self.albums.count
        for album in self.albums {
            self.numSongs += album.getNumSongs()
        }
    }
    
    convenience init(id: MDSArtistId, artistElement element: NSXMLElement) {
        assert(element.name == "artist")
        
        self.init(
            id: id,
            name: element.elementsForName("name")[0].stringValue,
            albums: MDSAlbum.albumsFromArtistElement(artistId: id, artistElement: element)
        )
    }
    
    class func artistsFromMusicElement(#musicElement: NSXMLElement) -> [MDSArtist] {
        var artistIdx: Int = 0
        var result = [MDSArtist]()
        
        for artistElement in musicElement.elementsForName("artist") as [NSXMLElement] {
            result.append(MDSArtist(id: artistIdx, artistElement: artistElement))
            artistIdx++
        }
        
        return result
    }
    
    // Id Getters
    func getId() -> MDSArtistId {
        return id
    }
    
    // Conform to song container protocol
    func getNumSongs() -> Int { return numSongs }
    
    func getSong(#idx: Int) -> MDSSong {
        var curAlbumIdx = -1
        var curSongIdx = -1
        var prevSongIdx = curSongIdx
        
        while curSongIdx < idx {
            curAlbumIdx++
            assert(curAlbumIdx < numAlbums)
            
            prevSongIdx = curSongIdx
            curSongIdx += getAlbum(idx: curAlbumIdx).getNumSongs()
        }
        
        var newIdx = idx - (prevSongIdx + 1)
        return getAlbum(idx: curAlbumIdx).getSong(idx: newIdx)
        
    }
    
    func getSong(#songId: MDSSongId, ignoreAssert: Bool = false) -> MDSSong {
        if !ignoreAssert { assert(MDSData.getArtistId(songId) == id) }
        return getAlbum(albumId: MDSData.getAlbumId(songId)).getSong(songId: songId, ignoreAssert: true)
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
    
    
    // Conform to album container protocol
    func getNumAlbums() -> Int { return numAlbums }
    
    func getAlbum(#idx: Int) -> MDSAlbum {
        return albums[idx]
    }
    
    func getAlbum(#albumId: MDSAlbumId, ignoreAssert: Bool = false) -> MDSAlbum {
        if !ignoreAssert { assert(MDSData.getArtistId(albumId) == id) }
        return getAlbum(idx: albumId.1)//albums[albumId.1]
    }
    
    func getAlbums() -> MDSIterator<MDSAlbum> {
        return MDSBaseIterator<MDSAlbum>(list: albums)
    }
}

class MDSAlbum: MDSData, MDSSongContainer {
    private var id: MDSAlbumId
    private var songs: [MDSSong]
    private var numSongs: Int = 0
    
    var title: String
    
    // Initialize album using list of songs
    init(id: MDSAlbumId, title: String, songs :[MDSSong]) {
        self.id = id
        self.title = title
        self.songs = songs
        self.numSongs = self.songs.count
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
    
    // Id Getters
    func getId() -> MDSAlbumId {
        return id
    }
    func getArtistId() -> MDSArtistId {
        return MDSData.getArtistId(id)
    }
    
    
    // Conform to song container protocol
    func getNumSongs() -> Int { return numSongs }
    
    func getSong(#idx: Int) -> MDSSong {
        return songs[idx]
    }
    
    func getSong(#songId: MDSSongId, ignoreAssert: Bool = false) -> MDSSong {
        if !ignoreAssert { assert(MDSData.getAlbumId(songId) == id) }
        return getSong(idx: songId.1)//songs[songId.1]
    }
    
    func getSongs() -> MDSIterator<MDSSong> {
        return MDSBaseIterator<MDSSong>(list: songs)
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