import Foundation

struct OpenAIService {
    static func identifyExercise(description: String) async throws -> (name: String, unit: ExerciseUnit) {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(Secrets.openAIKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "temperature": 0.3,
            "max_tokens": 100,
            "messages": [
                [
                    "role": "system",
                    "content": "Tu es un expert en musculation. L'utilisateur décrit un exercice avec ses mots. Réponds UNIQUEMENT avec le nom exact de l'exercice en français, suivi d'un pipe |, suivi de 'kg' ou 'pdc' (poids du corps). Exemple: 'Développé couché|kg' ou 'Tractions|pdc'. Pas d'explication, juste le nom et l'unité."
                ],
                [
                    "role": "user",
                    "content": description
                ]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw OpenAIError.requestFailed
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let first = choices.first,
              let message = first["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw OpenAIError.invalidResponse
        }

        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = trimmed.split(separator: "|", maxSplits: 1)

        let name = parts.first.map(String.init)?.trimmingCharacters(in: .whitespaces) ?? trimmed
        let unit: ExerciseUnit = parts.count > 1 && parts[1].lowercased().contains("pdc") ? .pdc : .kg

        return (name, unit)
    }
}

enum OpenAIError: LocalizedError {
    case requestFailed
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .requestFailed: return "La requête a échoué"
        case .invalidResponse: return "Réponse invalide"
        }
    }
}
