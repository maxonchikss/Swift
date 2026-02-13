import Foundation

class PokerGame{
    let bot = PokerOponent(position: .BigBlind)
    var heroStack: Int
    var opStack: Int
    var heroPosition = Position.SmallBlind
    var bank: Int = 0
    var deck: [Card] = []
    var heroHand: [Card] = []
    var opHand: [Card] = []
    var board: [Card] = []
    
    init(BigBlindes: Int){
        self.opStack = BigBlindes
        self.heroStack = BigBlindes
    }
//Раздача карт
    func dealCards(){
        print("You have \(heroHand),", "your position is \(heroPosition)")
        print("Your stack now: \(heroStack/10) BB,", "your op stack now: \(opStack/10) BB")
    }
    
//Префлоп
    func preflopAction() -> Bool{
        let smallBlindBet = 5
        let bigBlindBet = 10
        
        if heroPosition == Position.SmallBlind{
            heroStack -= smallBlindBet
            opStack -= bigBlindBet
            bank = smallBlindBet + bigBlindBet
        }
        if heroPosition == Position.BigBlind{
            heroStack -= bigBlindBet
            opStack -= smallBlindBet
            bank += smallBlindBet + bigBlindBet
        }
        
        print("Your oponent required bet \(bigBlindBet/10) BB, your required bet is \(smallBlindBet/10) BB")
        print("You turn: 1. Call 2. Raise X2 3. Fold ")
        //Выбор игрока
        guard let choice = Int(readLine() ?? ""), choice >= 1 && choice <= 3 else{
            print("Wrong input -> Fold")
            return false
        }
        https://github.com/maxonchikss/Swift.git
        switch choice {
            case 1:
                heroStack -= 5
                bank += 5
                return true
            case 2:
                heroStack -= 15
                bank += 15
                //Точка входа бота в игру
                let botEnters = bot.shouldEnter(withHand: opHand)
                    if !botEnters {
                        heroStack += bank
                        print("Bot fold")
                        return false
                    }else{
                        opStack -= 10
                        bank += 10
                        return true
                    }
            case 3:
                opStack += smallBlindBet
                heroStack -= smallBlindBet
                return false
            default:
                return false
        }
    }
    
// Круг ставок (любых)
    func bettingRound(stage: String, newCards: [Card]) -> Bool{
        board.append(contentsOf: newCards)
        let opBet = (Int.random(in: 1...10)) * bank / 10

        
        print("The board is: \(board)")
        print("Your hand: \(heroHand)", "Your stack now: \(heroStack/10)BB", "Your op stack now: \(opStack/10)BB", "Bank now \(bank)")
        print("Your op bet \(Double(opBet)/10)BB", "You turn: 1. Call 2. Raise X2 3. Fold")
        
        guard let choice = Int(readLine() ?? ""), choice >= 1 && choice <= 3 else{
            print("Wrong input -> Fold")
            return false
        }
        
        switch choice {
            case 1:
                heroStack -= opBet
                opStack -= opBet
                bank += opBet*2
                return true
                
            case 2:
                heroStack -= opBet * 2
                bank += opBet * 2
                opStack -= opBet * 2
                bank += opBet * 2
                return true
                
            case 3:
                opStack += bank / 2
                heroStack += bank / 2
                return false
            default:
                return false
        }
    }
        
    func flop() -> Bool{
        bettingRound(stage: "FLOP", newCards: [deck[4], deck[5], deck[6]])
        
    }
    
    func turn() -> Bool{
        bettingRound(stage: "TURN", newCards: [deck[7]])
        
    }
    
    func river() -> Bool{
        bettingRound(stage: "RIVER", newCards: [deck[8]])
    }

    func showdown(){
        let heroCombination = heroHand + board
        let opCombination = opHand + board
        let heroBestCombination = Combinations(cards: heroCombination)
        let opBestCombination = Combinations(cards: opCombination)
        
        if heroBestCombination.isStronger(than: opBestCombination) {
            print("You win \(bank/10) BB")
            print("Oponent have \(opHand)")
            heroStack+=bank
        } else if opBestCombination.isStronger(than: heroBestCombination) {
            print("You lose \(bank/10) BB")
            print("Oponent have \(opHand)")
            opStack+=bank
        } else {
            print("Split")
            print("Oponent have \(opHand)")
            opStack+=bank/2
            opStack+=bank/2
        }
    }
    
    func newPokerHand(){
        deck = DeckCreator()
        heroHand = [deck[0], deck[2]]
        opHand = [deck[1], deck[3]]
        board = []
        bank = 0
    }
    
    func startGame() {
        while heroStack > 0 && opStack > 0 {
            newPokerHand()
            dealCards()
            
            if !preflopAction() { continue }
            if !flop() { continue }
            if !turn() { continue }
            if !river() { continue }
            showdown()
        }
    }
    
}
