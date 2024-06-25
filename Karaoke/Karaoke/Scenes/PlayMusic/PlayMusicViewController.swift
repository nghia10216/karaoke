//
//  PlayMusicViewController.swift
//  Karaoke
//
//  Created by Lê Nghĩa on 24/06/2024.
//

import UIKit
import AVFoundation

enum AudioState: Int {
  case play
  case pause
}

class PlayMusicViewController: UIViewController {

  // MARK: - IBOutlet
  @IBOutlet weak var lyricsTableView: UITableView!
  @IBOutlet weak var playButton: UIButton!
  @IBOutlet weak var timeSlider: UISlider!

  @IBOutlet weak var startTimeLabel: UILabel!
  @IBOutlet weak var endTimeLabel: UILabel!

  private let songURL = URL(fileURLWithPath: Bundle.main.path(forResource: "beat", ofType: "mp3")!)
  private let lyricsURL = Bundle.main.path(forResource: "lyrics", ofType: "xml")!

  private var audioPlayer: AVAudioPlayer?
  private var playerTimer: Timer?
  private var lyricTimer: Timer?
  private var params: [Param] = []

  var lyricIndex: Int = 0

  private var startTimes: [Double] {
    params.map {
      $0.items.first?.va ?? 0.0
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    configTableView()
    setupAudioPlayer()
    setupLyricsData()
    setupDurationView()
  }

  private func configTableView() {
    lyricsTableView.dataSource = self
    lyricsTableView.register(UINib(nibName: "LyricsTableViewCell", bundle: nil), forCellReuseIdentifier: "LyricsTableViewCell")
  }

  private func setupDurationView() {
    startTimeLabel.text = "00:00"
    endTimeLabel.text = "\((audioPlayer?.duration ?? 0.0).durationString)"
  }

  private func setupLyricsData() {
    if let xmlData = try? Data(contentsOf: URL(fileURLWithPath: lyricsURL)), let parsedData: [Param] = XMLDataParser.parseXML(data: xmlData, rootElement: "data") {
      params = parsedData
    }
  }

  @IBAction func playButtonDidTap(_ sender: UIButton) {
    let audioState = AudioState(rawValue: sender.tag) ?? .play
    sender.setBackgroundImage(UIImage(systemName: audioState != .play ? "play.fill" : "pause.fill"), for: .normal)
    switch audioState {
    case .play:
      sender.tag = AudioState.pause.rawValue
      audioPlayer?.play()
      startTimer()
      startLyricTimer()
    case .pause:
      sender.tag = AudioState.play.rawValue
      audioPlayer?.pause()
      playerTimer?.invalidate()
    }
  }

  // MARK: - Private
  private func setupAudioPlayer() {
    audioPlayer = try? AVAudioPlayer(contentsOf: songURL)
    audioPlayer?.delegate = self
  }

  func stopAll() {
    playerTimer?.invalidate()
    audioPlayer?.stop()
  }

  @IBAction func timeSliderDidChange(_ sender: UISlider) {
    guard let audioPlayer = self.audioPlayer else { return }
    let songDuration = audioPlayer.duration
    let currentTime = TimeInterval(sender.value) * songDuration
    audioPlayer.currentTime = currentTime
    startTimeLabel.text = "\(audioPlayer.currentTime.durationString)"
  }
  
  @objc func timerStick(_ timer: Timer) {
    if let audioPlayer = self.audioPlayer, audioPlayer.isPlaying {
      let value = audioPlayer.currentTime / audioPlayer.duration
      startTimeLabel.text = "\(audioPlayer.currentTime.durationString)"
      self.timeSlider.value = Float(value)
    }
  }

  func startTimer() {
    playerTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerStick(_:)), userInfo: nil, repeats: true)
  }

  func calculateDurationForLyricLabel() -> CGFloat {
    var duration:CGFloat = 0.0
    let timing = startTimes[lyricIndex]
    let nextTiming = startTimes[lyricIndex + 1]
    duration = nextTiming - timing
    return duration
  }

  func repeatLyricTimer() {
    self.lyricTimer = Timer.scheduledTimer(timeInterval: calculateDurationForLyricLabel(), target: self, selector: #selector(handleAnimationAndShowLabel), userInfo: nil, repeats: false)
    self.lyricIndex += 1
  }

  func startLyricTimer() {
    self.lyricTimer = Timer.scheduledTimer(timeInterval: startTimes[0], target: self, selector: #selector(handleAnimationAndShowLabel), userInfo: nil, repeats: false)
  }

  @objc func handleAnimationAndShowLabel() {
    let indexPath = IndexPath(row: lyricIndex, section: 0)
    if let cell = lyricsTableView.cellForRow(at: indexPath) as? LyricsTableViewCell {
      lyricsTableView.scrollToRow(at: indexPath, at: .top, animated: true)
      cell.lyricsLabel.duration = calculateDurationForLyricLabel()
      cell.lyricsLabel.startAnimation()
      repeatLyricTimer()
    }
  }
}

// MARK: - AVAudioPlayerDelegate
extension PlayMusicViewController: AVAudioPlayerDelegate {

}

// MARK: - UITableViewDataSource
extension PlayMusicViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    params.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "LyricsTableViewCell", for: indexPath) as? LyricsTableViewCell else {
      return UITableViewCell()
    }
    cell.updateCell(param: params[indexPath.row])
    return cell
  }
}
