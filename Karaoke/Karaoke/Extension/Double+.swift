//
//  Double+.swift
//  Karaoke
//
//  Created by Lê Nghĩa on 24/06/2024.
//

import Foundation

extension Double {
  var durationString: String {
    let minutes = Int(self) / 60
    let seconds = Int(self) % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }
}

