//
//  GameScene.swift
//  FlappyPlane
//
//  Created by Stanislav Tereshchenko on 19.07.2023.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    private var airplane: SKSpriteNode!
    
    private var blocks: [SKSpriteNode] = []
    private var coins: [SKSpriteNode] = []
    
    var currentBlockDelay: TimeInterval = 3.0
    let maxBlockDelay: TimeInterval = 5.0
    let delayIncreaseRate: TimeInterval = 0.1

    private var scoreLabel: SKLabelNode!
    private var score = 0
    private var isGameOver = false
    private var upButton: UIButton!
    private var downButton: UIButton!
    private var restartButton: UIButton!
    private let airplaneCategory: UInt32 = 0x1 << 0
    private let blockCategory: UInt32 = 0x1 << 1
    private let coinCategory: UInt32 = 0x1 << 2
    
    override func didMove(to view: SKView) {
        backgroundColor =  UIColor(red: 0.565, green: 0.847, blue: 0.976, alpha: 1)
        setupAirplane()
        startAddingBlocks()
        startAddingCoins()
        setupButtons()
        setupPhysics()
        setupScoreLabel()
    }
    func setupAirplane() {
        let planeTexture = SKTexture(imageNamed: "Plane")
        airplane = SKSpriteNode(texture: planeTexture, size: CGSize(width: 100, height: 90))
        airplane.physicsBody = SKPhysicsBody(texture: planeTexture, size: airplane.size)
        airplane.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(airplane)
    }
    func startAddingBlocks() {
        let createBlockAction = SKAction.run {
            self.createBlock()
        }
        let waitAction = SKAction.wait(forDuration: currentBlockDelay)
        let sequenceAction = SKAction.sequence([createBlockAction, waitAction])
        let repeatAction = SKAction.repeatForever(sequenceAction)
        run(repeatAction)
    }
    func createBlock() {
           let blockTexture = SKTexture(imageNamed: "Cloud")
           let block = SKSpriteNode(texture: blockTexture, size: CGSize(width: 120, height: 80))
           let minY = size.height / 2 - 180
           let maxY = size.height - block.size.height / 2
           let randomY = CGFloat.random(in: minY...maxY)
            currentBlockDelay = max(currentBlockDelay - delayIncreaseRate, maxBlockDelay)
           block.position = CGPoint(x: size.width, y: randomY)
           block.physicsBody = SKPhysicsBody(rectangleOf: block.size)
           block.physicsBody?.isDynamic = false
           block.physicsBody?.categoryBitMask = blockCategory
           block.physicsBody?.contactTestBitMask = airplaneCategory
           block.physicsBody?.collisionBitMask = 0
           addChild(block)
           blocks.append(block)
           let moveAction = SKAction.moveBy(x: -size.width - block.size.width, y: 0, duration: 5.0)
           let removeAction = SKAction.removeFromParent()
           let sequenceAction = SKAction.sequence([moveAction, removeAction])
           block.run(sequenceAction) {
               self.blocks.removeFirst()
           }
    }
    func startAddingCoins() {
        let createCoinAction = SKAction.run {
            self.createCoin()
        }
        let waitAction = SKAction.wait(forDuration: 3.0)
        let sequenceAction = SKAction.sequence([createCoinAction, waitAction])
        let repeatAction = SKAction.repeatForever(sequenceAction)
        run(repeatAction)
    }
    func createCoin() {
            let coinTexture = SKTexture(imageNamed: "Coin")
            let coin = SKSpriteNode(texture: coinTexture, size: CGSize(width: 50, height: 50))
            let minY = size.height / 2 - 200
            let maxY = size.height - coin.size.height / 2
            let randomY = CGFloat.random(in: minY...maxY)
            coin.position = CGPoint(x: size.width, y: randomY)
            coin.physicsBody = SKPhysicsBody(rectangleOf: coin.size)
            coin.physicsBody?.isDynamic = false
            coin.physicsBody?.categoryBitMask = coinCategory
            coin.physicsBody?.contactTestBitMask = airplaneCategory
            coin.physicsBody?.collisionBitMask = 0
            addChild(coin)
            coins.append(coin)
            let moveAction = SKAction.moveBy(x: -size.width - coin.size.width, y: 0, duration: 5.0)
            let removeAction = SKAction.removeFromParent()
            let sequenceAction = SKAction.sequence([moveAction, removeAction])
            coin.run(sequenceAction) {
                self.coins.removeFirst()
            }
    }
    func setupScoreLabel() {
        scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.fontName = "MuktaMahee-Medium"
        scoreLabel.fontColor = .red
        scoreLabel.fontSize = 24
        scoreLabel.position = CGPoint(x: size.width - 80, y: size.height - 100)
        addChild(scoreLabel)
    }
    func setupPhysics() {
        physicsWorld.contactDelegate = self
        airplane.physicsBody = SKPhysicsBody(rectangleOf: airplane.size)
        airplane.physicsBody?.isDynamic = false
        airplane.physicsBody?.categoryBitMask = airplaneCategory
        airplane.physicsBody?.contactTestBitMask = blockCategory | coinCategory
        airplane.physicsBody?.collisionBitMask = 0
    }
    func gameOver() {
        score = 0
        isGameOver = true
        removeAllActions()
        blocks.forEach { $0.removeAllActions() }
        coins.forEach { $0.removeAllActions() }
        airplane.removeFromParent()
        setupRestartButton()
    }
    func setupRestartButton() {
        restartButton = UIButton(type: .system)
        restartButton.frame = CGRect(x: size.width/2 - 50, y: size.height - 75, width: 100, height: 40)
        let restartButtonAttributedTitle = NSAttributedString(string: "RESTART",
                                                         attributes: [NSAttributedString.Key.font : UIFont(name: "MuktaMahee-Medium", size: 23)!,
                                                                      NSAttributedString.Key.foregroundColor : UIColor.white])
        restartButton.setAttributedTitle(restartButtonAttributedTitle, for: .normal)
        restartButton.addGradient(colors: [UIColor.purple, UIColor.black], startPoint: CGPoint(x: 0.0, y: 0.0), endPoint: CGPoint(x: 1.0, y: 1.0), transform: nil)
        restartButton.layer.cornerRadius = 10
        restartButton.addTarget(self, action: #selector(restartButtonPressed), for: .touchUpInside)
        view?.addSubview(restartButton)
    }
    @objc func restartButtonPressed() {
        restartGame()
    }
    func restartGame() {
        score = 0
        updateScoreLabel()
        isGameOver = false
        blocks.forEach { $0.removeFromParent() }
        coins.forEach { $0.removeFromParent() }
        airplane.removeFromParent()
        restartButton.removeFromSuperview()
        blocks.removeAll()
        coins.removeAll()
        setupAirplane()
        startAddingBlocks()
        startAddingCoins()
        setupPhysics()
    }
    func updateScoreLabel() {
        scoreLabel.text = "Score: \(score)"
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == airplaneCategory | coinCategory {
            // Зіткнулися з монетою
            if let coin = contact.bodyA.node as? SKSpriteNode, coin.physicsBody?.categoryBitMask == coinCategory {
                coin.removeFromParent()
                score += 1
                updateScoreLabel()
            } else if let coin = contact.bodyB.node as? SKSpriteNode, coin.physicsBody?.categoryBitMask == coinCategory {
                coin.removeFromParent()
                score += 1
                updateScoreLabel()
            }
        } else {
            
            gameOver()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        for coin in coins {
            if airplane.intersects(coin) {
                score += 1
                updateScoreLabel()
                coin.removeFromParent()
            }
        }
        if isGameOver { return }
          for block in blocks {
              if airplane.intersects(block) {
                  gameOver()
                  return
              }
          }
    }
    func moveAirplane(up: Bool) {
        let displacementAmount: CGFloat = 10.0
        let displacement = up ? displacementAmount : -displacementAmount
        let newY = airplane.position.y + displacement
        
        let topY = size.height - airplane.size.height/2
        let bottomY = airplane.size.height/2
        let newYClamped = max(min(newY, topY), bottomY)
        
        airplane.position.y = newYClamped
    }
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }
        
        if key.characters == " " {
            gameOver()
        }
    }
    func setupButtons() {
        let buttonSize = CGSize(width: 170, height: 80)
        upButton = UIButton(type: .system)
        upButton.frame = CGRect(x: 10, y: size.height - 20 - buttonSize.height * 2 - 10, width: buttonSize.width, height: buttonSize.height)
        let upButtonAttributedTitle = NSAttributedString(string: "UP",
                                                         attributes: [NSAttributedString.Key.font : UIFont(name: "MuktaMahee-Medium", size: 23)!,
                                                                      NSAttributedString.Key.foregroundColor : UIColor.white])
        upButton.setAttributedTitle(upButtonAttributedTitle, for: .normal)
        upButton.addGradient(colors: [UIColor.purple, UIColor.black], startPoint: CGPoint(x: 0.0, y: 0.0), endPoint: CGPoint(x: 1.0, y: 1.0), transform: nil)
        upButton.layer.cornerRadius = 10
        upButton.addTarget(self, action: #selector(upButtonPressed), for: .touchUpInside)
        view?.addSubview(upButton)

        downButton = UIButton(type: .system)
        downButton.frame = CGRect(x: size.width - (buttonSize.width + 10) , y: size.height - 20 - buttonSize.height * 2 - 10, width: buttonSize.width, height: buttonSize.height)
        let downButtonAttributedTitle = NSAttributedString(string: "DOWN",
                                                         attributes: [NSAttributedString.Key.font : UIFont(name: "MuktaMahee-Medium", size: 23)!,
                                                                      NSAttributedString.Key.foregroundColor : UIColor.white])
        downButton.setAttributedTitle(downButtonAttributedTitle, for: .normal)
        downButton.addGradient(colors: [UIColor.purple, UIColor.black], startPoint: CGPoint(x: 0.0, y: 0.0), endPoint: CGPoint(x: 1.0, y: 1.0), transform: nil)
        upButton.layer.cornerRadius = 10
        
        downButton.addTarget(self, action: #selector(downButtonPressed), for: .touchUpInside)
        view?.addSubview(downButton)
    }
    @objc func upButtonPressed() {
        moveAirplane(up: true)
    }
    
    @objc func downButtonPressed() {
        moveAirplane(up: false)
    }
    override func willMove(from view: SKView) {
         upButton.removeFromSuperview()
         downButton.removeFromSuperview()
        restartButton.removeFromSuperview()
     }
}

