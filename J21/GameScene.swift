//
//  GameScene.swift
//  J21
//
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //MARK: ========== Constants
    enum GameState {case newGame, firstTurn, secondTurn, endGame}
    
    enum Player : Int {case undefined = -1, me = 0, them = 1, draw = 2}
    
    enum GameOutcome : Int {case undefined = -1, normal = 1, blackjack = 21, bust = 22}

    
    let Blackjack : Int = 21
    
    
    //MARK: ========== Game Variables
    var state : GameState = .newGame
    var firstTurnPlayer : Player = .undefined
    var winner : Player = .undefined
    var outcome : GameOutcome = .undefined
    
    
    
    var myTotalScore = 0
    var theirTotalScore = 0
    
    var myCurrentScore = 0
    var theirCurrentScore = 0
    
    //MARK: ========== Game Controls
    var pointButton : [SKLabelNode] = Array(repeating: SKLabelNode(), count: 11)
    var goButton : SKLabelNode  = SKLabelNode()
    var doneButton : SKLabelNode = SKLabelNode()
    var menuButton : SKLabelNode = SKLabelNode()
    var myScoreLabel : SKLabelNode = SKLabelNode()
    var theirScoreLabel : SKLabelNode = SKLabelNode()
    var iCollectLabel : SKLabelNode = SKLabelNode()
    var theyCollectLabel : SKLabelNode = SKLabelNode()
    var announcementLabel : SKLabelNode = SKLabelNode()
    
    
    //MARK: ========== Standard Event Handlers
    
    override func didMove(to view: SKView) {
       
        formatLabels()
        
        startNewGame()
       
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
           
            touchScreen(touch)
            
            
            //self.touchDown(atPoint: t.location(in: self))
            
            
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    //MARK: ========== Calculators
    
    
    
    
    func collector() -> Player{
        switch state{
        //case .newGame: return .undefined
        case .firstTurn: return firstTurnPlayer
        case .secondTurn: return GameScene.Player(rawValue: 2 - firstTurnPlayer.rawValue)!
        default : return .undefined
        }
    }
    
    
    
    //MARK: ========== Formatters
    
    func formatLabels(){
        
        for i in 0...10{
            pointButton[i] = self.childNode(withName: "point\(i)")! as! SKLabelNode
        }
        goButton = self.childNode(withName: "go")! as! SKLabelNode
        doneButton = self.childNode(withName: "done")! as! SKLabelNode
        menuButton = self.childNode(withName: "menu")! as! SKLabelNode
        
        announcementLabel = self.childNode(withName: "announcement")! as! SKLabelNode
        iCollectLabel = self.childNode(withName: "icollect")! as! SKLabelNode
        theyCollectLabel = self.childNode(withName: "theycollect")! as! SKLabelNode
        myScoreLabel = self.childNode(withName: "mytotal")! as! SKLabelNode
        theirScoreLabel = self.childNode(withName: "theirtotal")! as! SKLabelNode

    }
    
    func selectHand() -> Int{
        
        
        return 0
    }
    
    
    func touchScreen(_ touch : UITouch){
        
        let positionInScene = touch.location(in: self)
        
        // a label has been pressed
        
        if let touchedLabel = self.atPoint(positionInScene) as? SKLabelNode{
            
            switch(touchedLabel.name){
            case "go":
                go();
            case "done":
                done();
            case "menu":
                break;
            case let point where point?.prefix(5) == "point":
                _ = selectPoint(point!);
            default:
                print(touchedLabel.name! + " touched")
            }
            
        }
        
        
    }
    
    func selectPoint(_ point : String) -> Int{
        
        let pt : Int = Int(point.suffix(point.count - 5))!
     
        for i in 0..<pointButton.count{
            pointButton[i].fontColor = (i == pt ? UIColor.red : UIColor.systemBlue)
        }
        goButton.isHidden = false
        
        myCurrentScore = pt
        return pt
    }
    
    func go(){
        
        if gameOff(){
            startNewGame()
            return
        }
        
        
        // __TODO : calculate their current score
        theirCurrentScore = 5
        
        if myTurn(){
            myTotalScore += (myCurrentScore + theirCurrentScore)
        }
        else if theirTurn(){
            theirTotalScore += (myCurrentScore + theirCurrentScore)
        }
        else {
            // probably should never happen
            print("go is pressed out of turn")
        }
        
        // __TODO: some good animation here
        goButton.isHidden = true
        if myCurrentScore > 0 {
            pointButton[myCurrentScore].fontColor = .systemBlue
            
        }
        
        updateGameStatus()
        updateInfoLabels()
        
        
    }
    
    func done(){
        
        if myFirstTurn(){
            state = .secondTurn
            updateInfoLabels()
        }
        else if mySecondTurn() {
            state = .endGame
            updateInfoLabels()
        }
        
    }
 
    func updateInfoLabels(){

        if gameOff(){
            goButton.isHidden = false
            goButton.text = "New Game"
        }
        else {
            goButton.text = "Go"
        }
        
        
        myScoreLabel.text = "My Score: \(myTotalScore)"
        theirScoreLabel.text = "Their Score: \(theirTotalScore)"
        iCollectLabel.isHidden = !myTurn()
        theyCollectLabel.isHidden = !theirTurn()
        doneButton.isHidden = !myTurn()
        
        var message : String = ""

        if state == .endGame{
            
            if outcome == .blackjack { message = "Blackjack! "}
            else if outcome == .bust { message = "Bust! "}
            
            
            if (winner == .me) { message += "I won!"}
            else if (winner == .them) {message  += "They won!"}
            else {message += "It's a push!"}
        }
        else {
            message = "Welcome to J21!"
        }
        announcementLabel.text = message
    }
    
    func updateGameStatus(){
        
        if myTotalScore == Blackjack { // I won
            outcome = .blackjack
            state = .endGame
            winner = .me
        }
        else if myTotalScore > Blackjack {
            outcome = .bust
            state = .endGame
            winner = .them
        }
        else if theirTotalScore == Blackjack{
            outcome = .bust
            state = .endGame
            winner = .them
        }
        else if theirTotalScore > Blackjack{
            outcome = .bust
            state = .endGame
            winner = .me
        }
        // _TODO_ : handle 11
        else if (theirSecondTurn() && theirTotalScore > 11) ||
                    (mySecondTurn() && myTotalScore > 11)    {
            state = .endGame
            if myTotalScore > theirTotalScore {winner = .me}
            else if myTotalScore < theirTotalScore {winner = .them}
            else {winner = .draw}
        }
        // _TODO_ : handle 11
        else if (theirFirstTurn() && theirTotalScore > 11 ||
                    (mySecondTurn() && myTotalScore > 11) ){
            state = .secondTurn
        }
        
        
        
    }
    
    
    func startNewGame(){
        
        myTotalScore = 0
        theirTotalScore = 0
        winner = .undefined
        outcome = .undefined
        
        state = .firstTurn
        firstTurnPlayer =  (Bool.random() ? .me : .them)
        goButton.isHidden = true
        updateInfoLabels()
        
    }
    
    func changeTurn(){
        
        if state != .firstTurn {return}
        
        state = .secondTurn
        
        
        updateInfoLabels()

        
    }
    
    //MARK: ========== Game State

    func firstTurn()->Bool {return state == .firstTurn}
    func secondTurn()->Bool {return state == .secondTurn}
    func myFirstTurn()-> Bool {return state == .firstTurn && firstTurnPlayer == .me}
    func mySecondTurn()-> Bool {return state == .secondTurn && firstTurnPlayer != .me}
    func theirFirstTurn()-> Bool {return state == .firstTurn && firstTurnPlayer != .me}
    func theirSecondTurn()-> Bool {return state == .secondTurn && firstTurnPlayer == .me}
    func myTurn()-> Bool {return myFirstTurn() || mySecondTurn()}
    func theirTurn()-> Bool {return theirFirstTurn() || theirSecondTurn()}
    func gameOff()-> Bool {return state == .newGame || state == .endGame}
    func gameOn()-> Bool {return state == .firstTurn || state == .secondTurn}

}
