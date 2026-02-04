import Foundation
import SwiftUI
import Combine

class QuizViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentQuestionIndex = 0
    @Published var selectedIndex: Int? = nil
    @Published var isResultShown = false
    @Published var questionTimer = 15  // seconds
    @Published var isGameOver = false
       @Published var score = 0
    
    private var timerCancellable: AnyCancellable?
    
    init() {
        loadQuestions()
        startTimer()
    }
    
    private func loadQuestions() {
        let jsonString = """
            { "questions": [ 
                {
                  "answer_id": 160,
                  "countries": [
                    { "country_name": "Bosnia and Herzegovina", "id": 29 },
                    { "country_name": "Mauritania", "id": 142 },
                    { "country_name": "Chile", "id": 45 },
                    { "country_name": "New Zealand", "id": 160 }
                  ],
                  "country_code": "NZ"
                },
                {
                  "answer_id": 13,
                  "countries": [
                    { "country_name": "Aruba", "id": 13 },
                    { "country_name": "Serbia", "id": 184 },
                    { "country_name": "Montenegro", "id": 150 },
                    { "country_name": "Moldova", "id": 147 }
                  ],
                  "country_code": "AW"
                },
                {
                  "answer_id": 66,
                  "countries": [
                    { "country_name": "Kenya", "id": 117 },
                    { "country_name": "Montenegro", "id": 150 },
                    { "country_name": "Ecuador", "id": 66 },
                    { "country_name": "Bhutan", "id": 26 }
                  ],
                  "country_code": "EC"
                },
                {
                  "answer_id": 174,
                  "countries": [
                    { "country_name": "Niue", "id": 164 },
                    { "country_name": "Paraguay", "id": 174 },
                    { "country_name": "Tuvalu", "id": 232 },
                    { "country_name": "Indonesia", "id": 105 }
                  ],
                  "country_code": "PY"
                },
                {
                  "answer_id": 122,
                  "countries": [
                    { "country_name": "Kyrgyzstan", "id": 122 },
                    { "country_name": "Zimbabwe", "id": 250 },
                    { "country_name": "Saint Lucia", "id": 190 },
                    { "country_name": "Ireland", "id": 108 }
                  ],
                  "country_code": "KG"
                },
                {
                  "answer_id": 113,
                  "countries": [
                    { "country_name": "Belarus", "id": 21 },
                    { "country_name": "Falkland Islands", "id": 73 },
                    { "country_name": "Japan", "id": 113 },
                    { "country_name": "Iraq", "id": 107 }
                  ],
                  "country_code": "JP"
                },
                {
                  "answer_id": 235,
                  "countries": [
                    { "country_name": "United Arab Emirates", "id": 235 },
                    { "country_name": "India", "id": 236 },
                    { "country_name": "Macedonia", "id": 133 },
                    { "country_name": "Guernsey", "id": 93 }
                  ],
                  "country_code": "AE"
                }
              ]
            }
            """
        
        guard let data = jsonString.data(using: .utf8) else { return }
        
        do {
            let decoded = try JSONDecoder().decode(QuizDataDTO.self, from: data)
            
            let mapped: [Question] = decoded.questions.compactMap { q in
                let opts = q.countries.map { $0.country_name }
                guard let correctIdx = q.countries.firstIndex(where: { $0.id == q.answer_id }) else { return nil }
                
                return Question(
                    id: q.answer_id,
                    flagImageName: q.country_code.uppercased(),
                    options: opts,
                    correctOptionIndex: correctIdx
                )
            }
            
            DispatchQueue.main.async {
                self.questions = mapped
                //try? self.saveQuestionsToCoreData(mapped)
            }
        } catch {
            print("JSON decode error: \(error.localizedDescription)")
        }
    }

    
    
    
    func startTimer() {
        timerCancellable?.cancel()
        questionTimer = 15
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.questionTimer > 0 {
                    self.questionTimer -= 1
                } else {
                    self.showResult()
                }
            }
    }
    
  
    func selectOption(_ index: Int) {
        selectedIndex = index
        if questions.indices.contains(currentQuestionIndex) &&
            index == questions[currentQuestionIndex].correctOptionIndex {
            score += 1
        }
        showResult()
    }

    func showResult() {
        isResultShown = true
        timerCancellable?.cancel()
    }

    func nextQuestion() {
        if currentQuestionIndex + 1 < questions.count {
            currentQuestionIndex += 1
            selectedIndex = nil
            isResultShown = false
            startTimer()
        } else {
            isGameOver = true
        }
    }

    func resetGame() {
        score = 0
        currentQuestionIndex = 0
        selectedIndex = nil
        isResultShown = false
        isGameOver = false
        loadQuestions()
        startTimer()
    }
}
