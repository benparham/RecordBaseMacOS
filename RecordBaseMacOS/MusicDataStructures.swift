//
//  File.swift
//  RecordBaseMacOS
//
//  Created by Ruben Parham on 10/31/14.
//  Copyright (c) 2014 Ruben Parham. All rights reserved.
//


// TODO: Should probably make array of albums and array of songs actually hold options. Then, after deleting a song or album, can set that space in the array to nil. Getters an still return non-options, just have an assert to check for nil and then return <whatever>!. No one should be trying to access an id that was deleted anyway

import Foundation

enum MDSDataType: Int {
    case MDSSongType = 0
    case MDSAlbumType = 1
    case MDSArtistType = 2
    case MDSMusicType = 3
}

// ================= Protocols ==================

protocol MDSData {
    var type: MDSDataType { get }
    
    func asString() -> String
}

protocol MDSSongContainer: MDSData {
    var numSongs: Int { get }
    func getSong(#idx: Int) -> MDSSong
    func getSongs() -> MDSIterator<MDSSong>
}

protocol MDSAlbumContainer: MDSData {
    var numAlbums: Int { get }
    func getAlbum(#idx: Int) -> MDSAlbum
    func getAlbums() -> MDSIterator<MDSAlbum>
}

protocol MDSArtistContainer: MDSData {
    var numArtists: Int { get }
    func getArtist(#idx: Int) -> MDSArtist
    func getArtists() -> MDSIterator<MDSArtist>
}

protocol MDSArtistChild: MDSData {
    var artist: MDSArtist { get }
}

protocol MDSAlbumChild {
    var album: MDSAlbum { get }
}


// ================= Music Classes ==================

class MDSMusic: MDSSongContainer, MDSAlbumContainer, MDSArtistContainer {
    
    // ----- Unique music properties
    private var artists: [MDSArtist]
    
    
    // ----- Conform to MDSData protocol
    var type: MDSDataType = .MDSMusicType
    
    func asString() -> String {
        return "Music"
    }
    
    // ----- Conform to artist container protocol
    var numArtists: Int = 0
    
    func getArtist(#idx: Int) -> MDSArtist {
        return artists[idx]
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
        self.init(artists: MDSArtist.artistsFromMusicElement(element))
    }
}

class MDSArtist: MDSSongContainer, MDSAlbumContainer {
    
    // ----- Unique artist properties and methods
    var name: String
    
    private var albums: [MDSAlbum]
    
    class func artistsFromMusicElement(musicElement: NSXMLElement) -> [MDSArtist] {
        var artistIdx: Int = 0
        var result = [MDSArtist]()
        
        for artistElement in musicElement.elementsForName("artist") as [NSXMLElement] {
            result.append(MDSArtist(artistElement: artistElement))
            artistIdx++
        }
        
        return result
    }
    
    // ----- Conform to MDSData protocol
    var type: MDSDataType = .MDSArtistType
    
    func asString() -> String {
        return "Artist: " + name
    }
    
    
    // ----- Conform to album container protocol
    var numAlbums: Int = 0
    
    func getAlbum(#idx: Int) -> MDSAlbum {
        return albums[idx]
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
    init(name: String, albums: [MDSAlbum]) {
        self.name = name
        self.albums = albums
        self.numAlbums = self.albums.count
        for album in self.albums {
            self.numSongs += album.numSongs
        }
    }
    
    convenience init(artistElement element: NSXMLElement) {
        assert(element.name == "artist")
        
        self.init(
            name: element.elementsForName("name")[0].stringValue,
            albums: [MDSAlbum]()
        )
        
        self.albums = MDSAlbum.albumsFromArtistElement(element, parentArtist: self)
        self.numAlbums = self.albums.count
        for album in self.albums {
            self.numSongs += album.numSongs
        }
    }
}

class MDSAlbum: MDSSongContainer, MDSArtistChild {
    // ----- Unique album properties and methods
    var title: String
    
    private var songs: [MDSSong]
    
    class func albumsFromArtistElement(artistElement: NSXMLElement, parentArtist: MDSArtist) -> [MDSAlbum] {
        var albumIdx: Int = 0
        var result = [MDSAlbum]()
        
        for albumElement in artistElement.elementsForName("album") as [NSXMLElement] {
            result.append(MDSAlbum(parentArtist: parentArtist, albumElement: albumElement))
            albumIdx++
        }
        
        return result
    }
    
    // ----- Conform to MDSData protocol
    var type: MDSDataType = .MDSAlbumType
    
    func asString() -> String {
        return "Album: " + title
    }
    
    
    // ----- Conform to song container protocol
    var numSongs: Int = 0
    
    func getSong(#idx: Int) -> MDSSong {
        return songs[idx]
    }
    
    func getSongs() -> MDSIterator<MDSSong> {
        return MDSBaseIterator<MDSSong>(list: songs)
    }
    
    
    // ----- Conform to artist child protocol
    var artist: MDSArtist
    
    
    // ----- Initializers
    init(parentArtist: MDSArtist, title: String, songs: [MDSSong]) {
        self.artist = parentArtist
        self.title = title
        self.songs = songs
        self.numSongs = self.songs.count
    }
    
    convenience init(parentArtist: MDSArtist, albumElement element: NSXMLElement) {
        assert(element.name == "album")
        
        self.init(
            parentArtist: parentArtist,
            title: element.elementsForName("title")[0].stringValue,
            songs: [MDSSong]()
        )
        
        self.songs = MDSSong.songsFromAlbumElement(element, parentAlbum: self)
        self.numSongs = self.songs.count
    }
}

class MDSSong: MDSAlbumChild, MDSArtistChild {
    
    // ----- Unique song properties and methods
    var title: String
    var fileName: String
    
    var filePath: String {
        get {
            return artist.name + "/" + album.title + "/" + fileName
        }
    }
    
    class func songsFromAlbumElement(albumElement: NSXMLElement, parentAlbum: MDSAlbum) -> [MDSSong] {
        var songIdx: Int = 0
        var result = [MDSSong]()
        
        for songElement in albumElement.elementsForName("song") as [NSXMLElement] {
            result.append(MDSSong(parentAlbum: parentAlbum, songElement: songElement))
            songIdx++
        }
        
        return result
    }
    
    
    // ----- Conform to MDSData protocol
    var type: MDSDataType = .MDSSongType

    func asString() -> String {
        return "Song: " + title
    }
    
    // ----- Conform to MDSAlbumChild
    var album: MDSAlbum
    
    // ----- Conform to MDSArtistChild
    var artist: MDSArtist
    
    // ----- Initializers
    init(parentAlbum: MDSAlbum, title: String, fileName: String) {
        self.album = parentAlbum
        self.artist = self.album.artist
        self.title = title
        self.fileName = fileName
    }
    
    convenience init(parentAlbum: MDSAlbum, songElement element: NSXMLElement) {
        assert(element.name == "song")
        
        self.init(parentAlbum: parentAlbum,
                  title: element.elementsForName("title")[0].stringValue,
                  fileName: element.elementsForName("fileName")[0].stringValue
        )
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