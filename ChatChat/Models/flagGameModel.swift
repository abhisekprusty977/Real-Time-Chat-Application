struct CountryOption: Codable {
    let country_name: String
    let id: Int
}

// Matches the JSON exactly
struct QuestionDTO: Codable {
    let answer_id: Int
    let countries: [CountryOption]
    let country_code: String
}

struct QuizDataDTO: Codable {
    let questions: [QuestionDTO]
}

// Your actual playable Question model
struct Question: Identifiable {
    let id: Int
    let flagImageName: String
    let options: [String]
    let correctOptionIndex: Int
}
