//
//  LoadingScreenViewController.swift
//  FlappyPlane2.0
//
//  Created by Stanislav Tereshchenko on 21.07.2023.
//

import UIKit
import WebKit
import SpriteKit

class LoadingScreenViewController: UIViewController {

    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var rulesButton: UIButton!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var spriteKitView: SKView!
    
    var gameScene: GameScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGradient(colors: [UIColor.yellow, UIColor.orange], startPoint: CGPoint(x: 0.0, y: 0.5), endPoint: CGPoint(x: 1.0, y: 0.5), transform: nil)
        fetchJSONFromGitHub()
        webView.isHidden = true
        spriteKitView.isHidden = true
        aboutButton.isHidden = true
        playButton.isHidden = true
        rulesButton.isHidden = true
        setupButtons()
        
    }
    func setupButtons() {
        let playButtonAttributedTitle = NSAttributedString(string: "PLAY",
                                                         attributes: [NSAttributedString.Key.font : UIFont(name: "MuktaMahee-Medium", size: 23)!,
                                                                      NSAttributedString.Key.foregroundColor : UIColor.white])
        playButton.setAttributedTitle(playButtonAttributedTitle, for: .normal)
        playButton.addGradient(colors: [UIColor.purple, UIColor.black], startPoint: CGPoint(x: 0.0, y: 0.0), endPoint: CGPoint(x: 1.0, y: 1.0), transform: nil)
        playButton.layer.cornerRadius = 10
        let rulesButtonAttributedTitle = NSAttributedString(string: "RULES",
                                                         attributes: [NSAttributedString.Key.font : UIFont(name: "MuktaMahee-Medium", size: 23)!,
                                                                      NSAttributedString.Key.foregroundColor : UIColor.white])
        rulesButton.setAttributedTitle(rulesButtonAttributedTitle, for: .normal)
        rulesButton.addGradient(colors: [UIColor.purple, UIColor.black], startPoint: CGPoint(x: 0.0, y: 0.0), endPoint: CGPoint(x: 1.0, y: 1.0), transform: nil)
        rulesButton.layer.cornerRadius = 10
        let aboutButtonAttributedTitle = NSAttributedString(string: "ABOUT",
                                                         attributes: [NSAttributedString.Key.font : UIFont(name: "MuktaMahee-Medium", size: 23)!,
                                                                      NSAttributedString.Key.foregroundColor : UIColor.white])
        aboutButton.setAttributedTitle(aboutButtonAttributedTitle, for: .normal)
        aboutButton.addGradient(colors: [UIColor.purple, UIColor.black], startPoint: CGPoint(x: 0.0, y: 0.0), endPoint: CGPoint(x: 1.0, y: 1.0), transform: nil)
        aboutButton.layer.cornerRadius = 10

        
    }
    func fetchJSONFromGitHub() {
        let urlString = "https://raw.githubusercontent.com/StanislavTereshchenko/FlappyPlane/main/Newdocument1.json"
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let data = data {
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    self?.handleJSON(jsonObject)
                    print(jsonObject)
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
        }
        
        task.resume()
    }
    
    func handleJSON(_ jsonObject: [String: Any]?) {
        guard let access = jsonObject?["access"] as? Bool,
              let link = jsonObject?["link"] as? String else {
            print("Invalid JSON format")
            return
        }
        
        if access {
            DispatchQueue.main.async {
                self.webView.isHidden = false
            let urlString = "https://www.google.com"
                if let url = URL(string: urlString) {
                    let request = URLRequest(url: url)
                    self.webView.load(request)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.playButton.isHidden = false
                self.rulesButton.isHidden = false
                self.aboutButton.isHidden = false
                self.playButton.addTarget(self, action: #selector(self.startGame), for: .touchUpInside)
            }
        }

    }
    @objc func startGame() {
        self.playButton.isHidden = true
        self.rulesButton.isHidden = true
        self.aboutButton.isHidden = true
        self.spriteKitView.isHidden = false
        if let view = self.spriteKitView {
            self.gameScene = GameScene(size: view.bounds.size)
            view.presentScene(self.gameScene)
        }
        print("start")
    }
}
