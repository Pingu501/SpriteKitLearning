//
//  GameScene.swift
//  Minesweeper
//
//  Created by Alexander Hesse on 26.06.17.
//  Copyright © 2017 Alexander Hesse. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var motionManager = CMMotionManager()
    
    private var deleteButton : SKNode! = nil
    
    private var gravity = false
    private var gravityButton : SKNode! = nil
    
    private var currentlyDraggedBall : SKShapeNode?
    
    override func didMove(to view: SKView) {
        
        backgroundColor = SKColor.darkGray
        
        self.motionManager.startAccelerometerUpdates()
        
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        let border = SKNode.init()
        border.position = CGPoint(x: 0, y: 0)
        border.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.addChild(border)
        
        addDeleteButton()
        addGravityButton()
    }
    
    func addDeleteButton() {
        self.deleteButton = SKSpriteNode(color: SKColor.black.withAlphaComponent(0.5), size: CGSize(width: 44, height: 44))
        self.deleteButton.position = CGPoint(x: 44, y: 44)
        self.deleteButton.zPosition = 1000;
        self.deleteButton.name = "delete"
        
        let deleteText = SKLabelNode(text: "x") as SKNode
        deleteText.position = CGPoint(x: 0, y: -10)
        deleteText.name = "delete"
        
        self.deleteButton.addChild(deleteText)
        self.addChild(self.deleteButton)
    }
    
    func addGravityButton() {
        self.gravityButton = SKSpriteNode(color: SKColor.black.withAlphaComponent(0.5), size: CGSize(width: 44, height: 44))
        self.gravityButton.position = CGPoint(x: 100, y: 44)
        self.gravityButton.zPosition = 1000
        self.gravityButton.name = "gravitiy"
        
        let gravityText = SKLabelNode(text: "G") as SKNode
        gravityText.position = CGPoint(x: 0, y: -10)
        gravityText.name = "gravity"
        gravityText.alpha = 0.1
        
        self.gravityButton.addChild(gravityText)
        self.addChild(self.gravityButton)
    }
    
    func handleGravityChange() {
        let buttonText = self.gravityButton.childNode(withName: "gravity")
        
        if self.gravity {
            self.physicsWorld.gravity = CGVector.zero
            buttonText?.alpha = 0.1
        } else {
            buttonText?.alpha = 1
        }
        
        self.gravity = !self.gravity
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchedNodes = nodes(at: touch.location(in: self))
        if (touchedNodes.first == nil) {
            self.addBall(touch: touch)
            
        } else {
            currentlyDraggedBall = touchedNodes.first as? SKShapeNode
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        if (currentlyDraggedBall == nil) {
            let touchedNodes = nodes(at: touch.location(in: self))
            currentlyDraggedBall = touchedNodes.first as? SKShapeNode
        } else {
            currentlyDraggedBall?.position = touch.location(in: self)
            self.shotBall(ball: self.currentlyDraggedBall!, touch: touch)
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchedNodes = self.nodes(at: touch.location(in: self))
        if let name = touchedNodes.first?.name {
            switch name {
            case "delete":
                for node:SKNode in self.children {
                    if node.name == "ball" {
                        node.removeFromParent()
                    }
                }
                break
            case "gravity":
                handleGravityChange()
            default:
                if currentlyDraggedBall != nil {
                    self.shotBall(ball: currentlyDraggedBall!, touch: touch)
                }
            }
        }
            
        currentlyDraggedBall = nil
    }
    
    func addBall(touch : UITouch) {
        let circleSize = CGFloat(20)
        let colors = [SKColor.white, SKColor.black]
        let randomIndex = Int(arc4random_uniform(UInt32(colors.count)))
        let color = colors[randomIndex]
        
        let ball = SKShapeNode(circleOfRadius: circleSize)
        ball.position = touch.location(in: self)
        ball.fillColor = color
        ball.strokeColor = color
        ball.name = "ball"
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: circleSize + 2)
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.restitution = 0.6
        ball.physicsBody?.affectedByGravity = true
        
        addChild(ball)
    }
    
    func processUserMotionForUpdate(forUpdate currentTime: CFTimeInterval) {
        if let data = self.motionManager.accelerometerData {
            self.physicsWorld.gravity = CGVector(dx: data.acceleration.y * 20, dy: data.acceleration.x * -20)
        }
    }
    
    func shotBall(ball: SKShapeNode, touch: UITouch) {
        let dx = touch.location(in: self).x - touch.previousLocation(in: self).x
        let dy = touch.location(in: self).y - touch.previousLocation(in: self).y
        
        ball.physicsBody?.velocity.dx = dx * 70
        ball.physicsBody?.velocity.dy = dy * 70
    }
    
    override func update(_ currentTime: TimeInterval) {
        // function which gets called before every frame
        if self.gravity {
            processUserMotionForUpdate(forUpdate: currentTime)
        }
    }
}
