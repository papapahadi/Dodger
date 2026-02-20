import SpriteKit

final class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private let obstacleImages = ["obstacle1", "obstacle2", "obstacle3"]

    private var obstacleSpeed: CGFloat = 4.0
    private var spawnInterval: TimeInterval = 1.0

    
    private var score = 0
    private let scoreLabel = SKLabelNode(fontNamed: "Avenir-Heavy")

    
    struct PhysicsCategory {
        static let player: UInt32 = 1 << 0
        static let obstacle: UInt32 = 1 << 1
    }


    private let player = SKSpriteNode(imageNamed: "player")
    
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: size.width / 2,
                                      y: size.height / 2)

        background.size = size
        background.zPosition = -1

        addChild(background)

        
        setupPlayer()
        
        setupScore()
        startScoring()
        
        startSpawnLoop()
    }
    
    private func startSpawnLoop() {
        
        let spawn = SKAction.run { [weak self] in
            self?.spawnObstacle()
        }
        
        let wait = SKAction.wait(forDuration: spawnInterval)
        let sequence = SKAction.sequence([spawn, wait])
        let loop = SKAction.repeatForever(sequence)
        
        run(loop, withKey: "spawnLoop")
    }


    
    private func startScoring() {
        
        let increment = SKAction.run { [weak self] in
            guard let self else { return }
            
            self.score += 1
            self.scoreLabel.text = "\(self.score)"
            
            // Increase difficulty every 10 points
            if self.score % 10 == 0 {
                self.increaseDifficulty()
            }
        }
        
        let wait = SKAction.wait(forDuration: 0.5) // Fixed constant speed
        
        let sequence = SKAction.sequence([wait, increment])
        let loop = SKAction.repeatForever(sequence)
        
        run(loop, withKey: "scoreLoop")
    }
    
    private func increaseDifficulty() {
        
        if obstacleSpeed > 1.5 {
            obstacleSpeed -= 0.3
        }
        
        if spawnInterval > 0.4 {
            spawnInterval -= 0.1
        }
        
        removeAction(forKey: "spawnLoop")
        startSpawnLoop()
    }



    
    private func setupScore() {
        
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = .white
        
        if let safeArea = view?.safeAreaInsets {
            
            scoreLabel.position = CGPoint(
                x: size.width / 2,
                y: size.height - safeArea.top - 20
            )
            
        } else {
            
            scoreLabel.position = CGPoint(
                x: size.width / 2,
                y: size.height - 60
            )
        }
        
        scoreLabel.text = "0"
        
        addChild(scoreLabel)
    }


    
    private func setupPlayer() {
        
        player.size = CGSize(width: 60, height: 60)
        player.position = CGPoint(x: size.width / 2, y: 100)
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.categoryBitMask = 1
        player.physicsBody?.contactTestBitMask = 2
        player.physicsBody?.collisionBitMask = 0
        
        addChild(player)
    }


    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        // Clamp player inside screen
        let minX = player.size.width / 2
        let maxX = size.width - player.size.width / 2
        
        let clampedX = min(max(location.x, minX), maxX)
        
        player.position.x = clampedX
    }
    
    private func spawnObstacle() {
        
        let randomImage = obstacleImages.randomElement()!
        let obstacle = SKSpriteNode(imageNamed: randomImage)
        
        obstacle.size = CGSize(width: 50, height: 50)
        
        let randomX = CGFloat.random(in: 50...(size.width - 50))
        obstacle.position = CGPoint(x: randomX,
                                    y: size.height + 50)
        
        obstacle.physicsBody = SKPhysicsBody(texture: obstacle.texture!,
                                             size: obstacle.size)

        
        obstacle.physicsBody?.isDynamic = true
        obstacle.physicsBody?.affectedByGravity = false
        obstacle.physicsBody?.categoryBitMask = 2
        obstacle.physicsBody?.contactTestBitMask = 1
        obstacle.physicsBody?.collisionBitMask = 0
        
        addChild(obstacle)
        
        let move = SKAction.moveTo(y: -50, duration: obstacleSpeed)
        let remove = SKAction.removeFromParent()
        
        obstacle.run(SKAction.sequence([move, remove]))
    }


    func didBegin(_ contact: SKPhysicsContact) {
        
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if mask == PhysicsCategory.player | PhysicsCategory.obstacle {
            gameOver()
        }
    }
    
    
    private var isGameOver = false

    private func gameOver() {
        
        removeAllActions()
        removeAction(forKey: "scoreLoop")
        
        let gameOverLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 40
        gameOverLabel.position = CGPoint(x: size.width/2,
                                         y: size.height/2)
        
        gameOverLabel.name = "gameOverLabel"
        
        addChild(gameOverLabel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if childNode(withName: "gameOverLabel") != nil {
            
            let newScene = GameScene(size: self.size)
            newScene.scaleMode = .resizeFill
            
            self.view?.presentScene(newScene,
                                    transition: SKTransition.fade(withDuration: 0.5))
        }
    }



}
