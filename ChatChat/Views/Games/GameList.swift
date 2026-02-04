import SwiftUI
import Foundation
struct TicTacToeView: View {
    @State private var board = Array(repeating: "", count: 9)
    @State private var currentPlayer = "X"
    @State private var winner: String?

    var body: some View {
        VStack {
            Text("Tic Tac Toe")
                .font(.largeTitle)
                .padding()

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                ForEach(0..<9, id: \.self) { index in
                    ZStack {
                        Rectangle()
                            .foregroundColor(.blue.opacity(0.3))
                            .aspectRatio(1, contentMode: .fit)
                            .cornerRadius(8)
                        Text(board[index])
                            .font(.system(size: 50))
                            .fontWeight(.bold)
                    }
                    .onTapGesture { makeMove(at: index) }
                }
            }
            .padding()

            if let winner = winner {
                Text("\(winner) wins!")
                    .font(.title)
                    .foregroundColor(.green)
                    .padding()
                Button("Reset Game") { resetGame() }
                    .buttonStyle(.borderedProminent)
            }
        }
    }

    private func makeMove(at index: Int) {
        guard board[index] == "", winner == nil else { return }
        board[index] = currentPlayer
        if checkWinner(for: currentPlayer) {
            winner = currentPlayer
        } else {
            currentPlayer = currentPlayer == "X" ? "O" : "X"
        }
    }

    private func checkWinner(for player: String) -> Bool {
        let combos = [
            [0,1,2],[3,4,5],[6,7,8],
            [0,3,6],[1,4,7],[2,5,8],
            [0,4,8],[2,4,6]
        ]
        return combos.contains { $0.allSatisfy { board[$0] == player } }
    }

    private func resetGame() {
        board = Array(repeating: "", count: 9)
        currentPlayer = "X"
        winner = nil
    }
}


//

struct RockPaperScissorsView: View {
    let moves = ["✊", "🤚", "✌️"] // Rock, Paper, Scissors
    @State private var userChoice: String?
    @State private var computerChoice: String?
    @State private var result: String = ""

    var body: some View {
        VStack(spacing: 30) {
            Text("Rock–Paper–Scissors")
                .font(.largeTitle)

            HStack {
                ForEach(moves, id: \.self) { move in
                    Button(action: { play(move) }) {
                        Text(move)
                            .font(.system(size: 50))
                    }
                }
            }
            if let user = userChoice, let comp = computerChoice {
                Text("You chose \(user), computer chose \(comp)")
                Text(result)
                    .font(.title)
                    .foregroundColor(result.contains("Win") ? .green : result.contains("Lose") ? .red : .orange)
            }
        }
        .padding()
    }

    private func play(_ move: String) {
        userChoice = move
        computerChoice = moves.randomElement()
        result = outcome(user: move, comp: computerChoice!)
    }

    private func outcome(user: String, comp: String) -> String {
        if user == comp { return "Draw" }
        if (user == "✊" && comp == "✌️") ||
           (user == "🤚" && comp == "✊") ||
           (user == "✌️" && comp == "🤚") {
            return "You Win!"
        } else {
            return "You Lose!"
        }
    }
}


struct MemoryMatchView: View {
    @State private var cards = ["🍎", "🍌", "🍎", "🍌"].shuffled()
    @State private var flippedIndices: [Int] = []
    @State private var matchedIndices: Set<Int> = []

    var body: some View {
        VStack {
            Text("Memory Match")
                .font(.largeTitle)
                .padding()

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                ForEach(cards.indices, id: \.self) { index in
                    ZStack {
                        Rectangle()
                            .fill(Color.blue.opacity(0.3))
                            .cornerRadius(8)
                            .aspectRatio(1, contentMode: .fit)

                        if flippedIndices.contains(index) || matchedIndices.contains(index) {
                            Text(cards[index])
                                .font(.largeTitle)
                        } else {
                            Text("?")
                                .font(.largeTitle)
                        }
                    }
                    .onTapGesture { flipCard(at: index) }
                }
            }
            .padding()
        }
    }

    private func flipCard(at index: Int) {
        guard !flippedIndices.contains(index),
              !matchedIndices.contains(index),
              flippedIndices.count < 2 else { return }

        flippedIndices.append(index)

        if flippedIndices.count == 2 {
            let firstIndex = flippedIndices[0]
            let secondIndex = flippedIndices[1]

            if cards[firstIndex] == cards[secondIndex] {
                matchedIndices.insert(firstIndex)
                matchedIndices.insert(secondIndex)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                flippedIndices.removeAll()
            }
        }
    }
}


struct TriviaQuizView: View {
    struct Question {
        let text: String
        let answers: [String]
        let correct: Int
    }

    let questions: [Question] = [
        Question(text: "What is the capital of France?",
                 answers: ["London", "Paris", "Berlin"], correct: 1),
        Question(text: "2 + 2 = ?", answers: ["3", "4", "5"], correct: 1)
    ]
    
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var showResult = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Trivia Quiz")
                .font(.largeTitle)

            Text(questions[currentIndex].text)
                .font(.title2)
                .padding()

            ForEach(0..<questions[currentIndex].answers.count, id: \.self) { i in
                Button(questions[currentIndex].answers[i]) {
                    checkAnswer(i)
                }
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
            }

            Text("Score: \(score)")
                .font(.headline)
        }
        .padding()
        .alert("Quiz Finished", isPresented: $showResult) {
            Button("OK") { reset() }
        } message: {
            Text("Your score is \(score)/\(questions.count)")
        }
    }

    private func checkAnswer(_ index: Int) {
        if index == questions[currentIndex].correct {
            score += 1
        }
        if currentIndex + 1 < questions.count {
            currentIndex += 1
        } else {
            showResult = true
        }
    }

    private func reset() {
        score = 0
        currentIndex = 0
    }
}


struct QuizGameView: View {
    @StateObject var vm = QuizViewModel()

      var body: some View {
          if vm.isGameOver {
              gameOverView
          } else if vm.currentQuestionIndex < vm.questions.count {
              questionView
          } else {
              ProgressView("Loading...")
          }
      }

      private var questionView: some View {
          let q = vm.questions[vm.currentQuestionIndex]

          return VStack(spacing: 20) {
              HStack {
                  Text("Question \(vm.currentQuestionIndex + 1)/\(vm.questions.count)")
                  Spacer()
                  Text("\(vm.questionTimer)s")
                      .font(.system(size: 22, weight: .bold, design: .monospaced))
                      .foregroundColor(.orange)
              }

              Text("Guess the Country by the Flag")
                  .font(.title2).bold()

              SafeFlagImage(imageName: q.flagImageName)
                  .scaledToFit()
                  .frame(height: 150)
                  .clipShape(RoundedRectangle(cornerRadius: 15))
                  .shadow(radius: 3)

              VStack(spacing: 12) {
                  ForEach(q.options.indices, id: \.self) { idx in
                      Button {
                          vm.selectOption(idx)
                      } label: {
                          HStack {
                              Text(q.options[idx])
                              Spacer()
                          }
                          .padding()
                          .background(buttonBackground(q: q, idx: idx))
                          .cornerRadius(8)
                      }
                      .disabled(vm.isResultShown)
                  }
              }

              if vm.isResultShown {
                  Button(action: {
                      vm.nextQuestion()
                  }) {
                      Image(systemName: "arrow.right")
                          .font(.system(size: 20, weight: .bold))
                          .foregroundColor(.white)
                          .frame(width: 44, height: 44)
                          .background(Circle().fill(Color.blue))
                  }

              }

              Spacer()
          }
          .padding()
      }

      private var gameOverView: some View {
          VStack(spacing: 24) {
              Text("GAME OVER")
                  .font(.largeTitle).bold()
                  .foregroundColor(.blue)

              Text("Your Score: \(vm.score)/\(vm.questions.count)")
                  .font(.title2)

              Button("Play Again") {
                  vm.resetGame()
              }
              .font(.title3.bold())
              .padding()
              .background(Color.blue)
              .foregroundColor(.white)
              .cornerRadius(8)
          }
          .padding()
      }

      private func buttonBackground(q: Question, idx: Int) -> Color {
          if vm.isResultShown {
              if idx == q.correctOptionIndex { return Color.green.opacity(0.3) }
              if idx == vm.selectedIndex && idx != q.correctOptionIndex {
                  return Color.red.opacity(0.3)
              }
          }
          return Color.gray.opacity(0.1)
      }
}


struct SafeFlagImage: View {
    let imageName: String
    var body: some View {
        if UIImage(named: imageName) != nil {
            Image(imageName).resizable()
        } else {
            Image(systemName: "flag.slash.fill")
                .resizable()
                .foregroundColor(.gray)
        }
    }
}
