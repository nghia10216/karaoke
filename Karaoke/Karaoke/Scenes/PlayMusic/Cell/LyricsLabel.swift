//
//  LyricsLabel.swift
//  Karaoke
//
//  Created by Lê Nghĩa on 24/06/2024.
//

import UIKit

struct LyricsItem {
  let time: Double
  let text: String
}

final class LyricsLabel: UILabel {

  var duration: CGFloat = 0.0

  private var textLayer: CATextLayer = CATextLayer()
  private let animationKey = "lyric"

  var fillTextColor:UIColor? {
    didSet {
      guard let fillTextColor = self.fillTextColor else { return }
      textLayer.foregroundColor = fillTextColor.cgColor
    }
  }

  var lyricItems: [LyricsItem] = [] {
     didSet {
       updateText()
     }
   }

  var differenceArray: [Double] {
    var diffArr: [Double] = []
    let originalArray = lyricItems.map { $0.time }
    var val: Double = 0
    for i in 1..<originalArray.count {
      val += originalArray[i] - originalArray[i - 1]
      diffArr.append(val)
    }
    duration - val > 2 ? diffArr.append(val + 2) : diffArr.append(duration)
    return diffArr
  }

  private func updateText() {
     guard !lyricItems.isEmpty else {
       text = nil
       return
     }
     text = lyricItems.compactMap { $0.text }.joined(separator: " ")
   }

  override var text: String? {
    didSet {
      self.updateLayer()
    }
  }

  override var font: UIFont! {
    didSet {
      self.updateLayer()
    }
  }

  // MARK: Init methods
  override init(frame: CGRect) {
    super.init(frame: frame)
    prepareForLyricLabel()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    prepareForLyricLabel()
  }

  func prepareForLyricLabel() {
    textLayer.removeFromSuperlayer()

    textLayer = CATextLayer()
    textLayer.frame = self.bounds

    self.numberOfLines = 1
    self.clipsToBounds = true
    self.textAlignment = .left
    self.baselineAdjustment = .alignBaselines

    textLayer.foregroundColor = fillTextColor?.cgColor ?? UIColor.blue.cgColor

    let textFont = self.font
    if let fontName = textFont?.fontName as CFString? {
      textLayer.font = CGFont(fontName)
    }

    if let fontSize = textFont?.pointSize as CGFloat? {
      textLayer.fontSize = fontSize
    }

    textLayer.string = self.text
    textLayer.contentsScale = UIScreen.main.scale
    textLayer.masksToBounds = true
    textLayer.anchorPoint = CGPoint(x: 0, y: 0.5)
    textLayer.frame = self.bounds
    textLayer.isHidden = true
    self.layer.addSublayer(textLayer)
  }

  // MARK: Animation
  func animationForTextLayer() -> CAKeyframeAnimation {
    textLayer.isHidden = false
    let textAnim = CAKeyframeAnimation(keyPath: "bounds.size.width")
    textAnim.duration = CFTimeInterval(self.duration)
    textAnim.values = valuesFromLyricSegment().map { NSNumber(value: $0) }
    textAnim.keyTimes = keyTimesFromLyricSegment().map { NSNumber(value: $0) }
    textAnim.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)]
    textAnim.isRemovedOnCompletion   = true
    return textAnim
  }

  // MARK: Help methods
  func updateLayer() {
    self.sizeToFit()
    self.setNeedsLayout()
    self.prepareForLyricLabel()
  }

  private func valuesFromLyricSegment() -> [Double] {
    let layerWidth = textLayer.bounds.width
    guard !lyricItems.isEmpty else { return [0.0, layerWidth] }
    var values: [Double] = [0.0]
    var val: Double = 0
    lyricItems.forEach {
      val += ($0.text + " ").size(withAttributes: [NSAttributedString.Key.font: font as Any]).width
      values.append(val)
    }
 //   values.append(val + 10)
    return values
  }

  private func keyTimesFromLyricSegment() -> [Double] {
    guard !lyricItems.isEmpty else { return [0.0, 1.0] }
    return [0.0] + differenceArray.map { Double($0 / duration) } + [1.0]
  }

  func startAnimation() {
    guard let _ = textLayer.animation(forKey: animationKey) else {
      let anim = self.animationForTextLayer()
      textLayer.add(anim, forKey: animationKey)
      return
    }
  }
}
