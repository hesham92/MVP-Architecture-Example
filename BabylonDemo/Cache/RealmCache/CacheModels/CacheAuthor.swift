//
//  CacheModels.swift
//  BabylonDemo
//
//  Created by Hesham Mohamed on 3/2/19.
//  Copyright © 2019 Hesham Mohamed. All rights reserved.
//

import RealmSwift

class CacheAuthor: Object {
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var username = ""
    @objc dynamic var email = ""
    @objc dynamic var address: CacheAddress!

    override static func primaryKey() -> String? {
        return "id"
    }

    var author: Author {
        return Author(id: id, name: name, username: username, email: email, address: address.address)
    }
}

extension Author {
    var cacheAuthor: CacheAuthor {
        let author = CacheAuthor()
        author.id = id
        author.name = name
        author.username = username
        author.email = email
        author.address = address.cacheAddress
        return author
    }
}

class CacheAddress: Object {
    @objc dynamic var street = ""
    @objc dynamic var suite = ""
    @objc dynamic var city = ""
    @objc dynamic var zipcode = ""
    @objc dynamic var geo: CacheGeo!

    var address: Address {
        return Address(street: street, suite: suite, city: city, zipcode: zipcode, geo: geo.geo)
    }
}

extension Address {
    var cacheAddress: CacheAddress {
        let address = CacheAddress()
        address.street = street
        address.suite = suite
        address.city = city
        address.zipcode = zipcode
        address.geo = geo.cacheGeo
        return address
    }
}

class CacheGeo: Object {
    @objc dynamic var lat = ""
    @objc dynamic var lng = ""

    var geo: Geo {
        return Geo(lat: lat, lng: lng)
    }
}

extension Geo {
    var cacheGeo: CacheGeo {
        let geo = CacheGeo()
        geo.lat = lat
        geo.lng = lng
        return geo
    }
}
