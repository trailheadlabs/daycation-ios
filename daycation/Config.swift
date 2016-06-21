//
//  Config.swift
//
//  Created by Ethan on 2/24/16.
//  Copyright © 2016 Ethan. All rights reserved.
//

import Foundation
import p2_OAuth2
struct Config {
   static var host: String { return "https://www.outerspatial.com" }
   // static var host: String { return "http://10.0.0.5:3000/" }
     static var imagePrefix: String { return "" }
    static var settings: OAuth2JSON { return   [
        "client_id": "63354ba6cdc9a182c6f021155c476a422729a9e6068dd2761ae5f091fa44c377",
        "client_secret": "ee2161bb19f3ea72ff3bf2b35742e5425d944631a71d47829bdc3bbdf46f9736",
        "authorize_uri": "\(Config.host)/oauth/token",
        "token_uri": "\(Config.host)/oauth/token",
        "application_id": 20
        ] }
//    static var host: String { return "http://10.0.0.5:3000" }
//    static var imagePrefix: String { return "http://10.0.0.5:3000" }
//    static var settings: OAuth2JSON { return   [
//        "client_id": "a494162f241c86d5128993bbc53ef19dc0ae9c28006c3f7c4e96d1a96eff03d3",
//        "client_secret": "ec2ae14a042dbb30bc9d3d287fd748791348afc35e295fc3540291eed8900099",
//        "authorize_uri": "\(Config.host)/oauth/token",
//        "token_uri": "\(Config.host)/oauth/token",
//        "application_id": 12
//        ] }
    
//    static var host: String { return "https://outerspatial-staging.herokuapp.com" }
//    static var imagePrefix: String { return "" }
//        static var settings: OAuth2JSON { return   [
//           "client_id": "a494162f241c86d5128993bbc53ef19dc0ae9c28006c3f7c4e96d1a96eff03d3",
//           "client_secret": "ec2ae14a042dbb30bc9d3d287fd748791348afc35e295fc3540291eed8900099",
//          "authorize_uri": "\(Config.host)/oauth/token",
//            "token_uri": "\(Config.host)/oauth/token",
//            "application_id": 1
//        ] }
//    
}
