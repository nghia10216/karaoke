//
//  XMLDataParser.swift
//  Karaoke
//
//  Created by Lê Nghĩa on 24/06/2024.
//

import Foundation
import XMLCoder

struct Param {
  let s: String
  var items: [Item]
}

struct Item {
  let va: Double
  let text: String

  func transform() -> LyricsItem {
    .init(time: va, text: text)
  }
}

enum XMLDataParser {
  static func parseXML<T: Decodable>(data: Data, rootElement: String) -> T? {
    let decoder = XMLDecoder()
    decoder.shouldProcessNamespaces = true
    do {
      let result = try decoder.decode(T.self, from: data)
      return result
    } catch {
      print("Error decoding XML: \(error)")
      return nil
    }
  }
}


extension Param: Decodable {
  enum CodingKeys: String, CodingKey {
    case s
    case items = "i"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    s = try container.decode(String.self, forKey: .s)
    items = try container.decode([Item].self, forKey: .items)
  }
}

extension Item: Decodable {
  enum CodingKeys: String, CodingKey {
    case va
    case text = ""
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    va = try container.decode(Double.self, forKey: .va)
    text = try container.decode(String.self, forKey: .text)
  }
}
