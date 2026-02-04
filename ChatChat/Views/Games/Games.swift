import SwiftUI

struct GamesView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: TicTacToeView()) {
                    HStack {
                        Image(systemName: "gamecontroller.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                            .foregroundColor(.blue)
                        Text("Tic Tac Toe")
                            .font(.headline)
                            .padding(.leading, 8)
                    }
                    .padding(.vertical, 8)
                }
                
                NavigationLink(destination: RockPaperScissorsView()) {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                            .foregroundColor(.green)
                        Text("Rock–Paper–Scissors")
                            .font(.headline)
                            .padding(.leading, 8)
                    }
                    .padding(.vertical, 8)
                }
                
                NavigationLink(destination: MemoryMatchView()) {
                    HStack {
                        Image(systemName: "rectangle.grid.2x2.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                            .foregroundColor(.purple)
                        Text("Memory Match")
                            .font(.headline)
                            .padding(.leading, 8)
                    }
                    .padding(.vertical, 8)
                }
                
                NavigationLink(destination: TriviaQuizView()) {
                    HStack {
                        Image(systemName: "questionmark.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                            .foregroundColor(.orange)
                        Text("Trivia / Quiz")
                            .font(.headline)
                            .padding(.leading, 8)
                    }
                    .padding(.vertical, 8)
                }
                
                NavigationLink(destination: QuizGameView()) {
                    HStack {
                        Image(systemName: "flag")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                            .foregroundColor(.yellow)
                        Text("Flag Challenge")
                            .font(.headline)
                            .padding(.leading, 8)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Games")
            .listStyle(InsetGroupedListStyle())
        }
    }
}
