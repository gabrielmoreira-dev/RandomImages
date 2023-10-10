import Foundation

enum NetworkError: Error {
    case badURL
    case invalidID
    case decoding
}

private extension WebService.Constants {
    enum URLs {
        static let randomImageURL = URL(string: "https://picsum.photos/200?uuid=\(UUID().uuidString)")
        static let randomQuoteURL = URL(string: "https://api.quotable.io/random")
    }
}

final class WebService {
    fileprivate enum Constants {}

    func getRamdomImages(ids: [Int]) async throws -> [RandomImage] {
        var randomImages: [RandomImage] = []

        try await withThrowingTaskGroup(of: (Int, RandomImage).self) { group in
            for id in ids {
                group.addTask {
                    return (id, try await self.getRandomImage(id: id))
                }
            }

            for try await (_, randomImage) in group {
                randomImages.append(randomImage)
            }
        }

        return randomImages
    }

    func getRandomImage(id: Int) async throws -> RandomImage {
        guard let randomImageURL = Constants.URLs.randomImageURL,
              let randomQuoteURL = Constants.URLs.randomQuoteURL else {
            throw NetworkError.badURL
        }

        async let (imageData, _) = URLSession.shared.data(from: randomImageURL)
        async let (quoteData, _) = URLSession.shared.data(from: randomQuoteURL)

        guard let quote = try? JSONDecoder().decode(Quote.self, from: await quoteData) else {
            throw NetworkError.decoding
        }

        return RandomImage(image: try await imageData, quote: quote)
    }
}
