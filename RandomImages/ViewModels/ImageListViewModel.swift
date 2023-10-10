import Foundation
import UIKit

@MainActor
final class ImageListViewModel: ObservableObject {
    private let service: WebService
    @Published var randomImages: [RandomImageViewModel] = []

    init(service: WebService = WebService()) {
        self.service = service
    }

    func getRandomImages(ids: [Int]) async {
        do {
            try await withThrowingTaskGroup(of: (Int, RandomImage).self) { group in
                for id in ids {
                    group.addTask { [self] in
                        return (id, try await service.getRandomImage(id: id))
                    }
                }

                for try await (_, randomImage) in group {
                    randomImages.append(RandomImageViewModel(randomImage: randomImage))
                }
            }
        } catch {
            print(error)
        }
    }
}

struct RandomImageViewModel: Identifiable {
    let id = UUID()
    fileprivate let randomImage: RandomImage

    var image: UIImage? {
        UIImage(data: randomImage.image)
    }

    var quote: String {
        randomImage.quote.content
    }
}
