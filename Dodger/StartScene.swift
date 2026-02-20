import SpriteKit

class StartScene: SKScene {
    
    override func didMove(to view: SKView) {

        backgroundColor = .black

        // Background
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: size.width / 2,
                                      y: size.height / 2)
        background.size = size
        background.zPosition = -1
        addChild(background)

        // Title
        let title = SKLabelNode(fontNamed: "Avenir-Heavy")
        title.text = "DODGER"
        title.fontSize = 50
        title.position = CGPoint(x: size.width / 2,
                                 y: size.height / 2 + 100)
        addChild(title)

        // PLAY button
        let button = SKShapeNode(rectOf: CGSize(width: 200, height: 60),
                                 cornerRadius: 15)

        button.fillColor = .systemBlue
        button.strokeColor = .white
        button.lineWidth = 3
        button.position = CGPoint(x: size.width / 2,
                                  y: size.height / 2 - 40)
        button.name = "playButton"
        addChild(button)

        let buttonText = SKLabelNode(fontNamed: "Avenir-Heavy")
        buttonText.text = "PLAY"
        buttonText.fontSize = 28
        buttonText.verticalAlignmentMode = .center
        buttonText.position = .zero
        button.addChild(buttonText)

        // Glow layer
        let glow = SKShapeNode(rectOf: CGSize(width: 220, height: 80),
                               cornerRadius: 20)

        glow.fillColor = .systemBlue
        glow.strokeColor = .clear
        glow.alpha = 0.3
        glow.position = button.position
        glow.zPosition = button.zPosition - 1

        addChild(glow)
        
        let glowPulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.6, duration: 0.8),
            SKAction.fadeAlpha(to: 0.2, duration: 0.8)
        ])

        glow.run(SKAction.repeatForever(glowPulse))

        // ✅ ADD PULSE ANIMATION HERE
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.8),
            SKAction.scale(to: 1.0, duration: 0.8)
        ])

        button.run(SKAction.repeatForever(pulse))
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let tappedNode = atPoint(location)
        
        if tappedNode.name == "playButton" ||
           tappedNode.parent?.name == "playButton" {
            
            let gameScene = GameScene(size: self.size)
            gameScene.scaleMode = .resizeFill
            
            self.view?.presentScene(gameScene,
                                    transition: SKTransition.fade(withDuration: 0.5))
        }
    }

}
