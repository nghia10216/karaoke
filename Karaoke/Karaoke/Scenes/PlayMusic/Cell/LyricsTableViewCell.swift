//
//  LyricsTableViewCell.swift
//  Karaoke
//
//  Created by Lê Nghĩa on 24/06/2024.
//

import UIKit
var aaa = false

class LyricsTableViewCell: UITableViewCell {

  @IBOutlet weak var lyricsLabel: LyricsLabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

  func updateCell(param: Param) {
    lyricsLabel.lyricItems = param.items.map { $0.transform() }
    lyricsLabel.fillTextColor = .red
    lyricsLabel.textColor = .black
  }
}
