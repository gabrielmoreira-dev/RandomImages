import SwiftUI

struct ContentView: View {
    @StateObject private var imageListVM = ImageListViewModel()

    var body: some View {
        List(imageListVM.randomImages) { randomImage in
            HStack {
                randomImage.image.map {
                    Image(uiImage: $0)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                Text(randomImage.quote)
            }
        }.task {
            await imageListVM.getRandomImages(ids: Array(1...20))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
