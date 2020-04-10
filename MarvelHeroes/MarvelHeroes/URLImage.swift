//
//  URLImage.swift
//  MarvelHeroes
//
//  Created by Gustavo Amaral on 10/04/20.
//  Copyright © 2020 Gustavo Almeida Amaral. All rights reserved.
//

import SwiftUI
import Networking
import Combine

struct URLImage: View {
    
    let url: URL
    @ObservedObject private var imageLoader = ImageLoader()
    @State var isPresentingError = false
    @State var isAnimating = false
    
    var body: some View {
        Group {
            
            imageLoader.isLoading {
                ZStack {
                    Rectangle()
                        .frame(width: 65, height: 45, alignment: .center)
                        .foregroundColor(.clear)
                    Image(systemName: "xmark.octagon")
                }
            }
            
            imageLoader.isFinished { image in
                Image(uiImage: image)
                    .cornerRadius(10)
            }
            
            imageLoader.isFailed { _ in
                ZStack {
                    Rectangle()
                        .frame(width: 65, height: 45, alignment: .center)
                        .foregroundColor(.clear)
                    ActivityIndicator(style: .medium)
                }
            }

        }
        .onAppear { self.imageLoader.loadImage(from: self.url) }
        .onDisappear { self.imageLoader.cancelLoad() }
    }
}

fileprivate class ImageLoader: ObservableObject, AsyncOperation {
    
    @Published private var image: AsyncResult<UIImage, NetworkError> = .loading
    private var cancellable: AnyCancellable?
    
    func loadImage(from url: URL) {
        self.cancellable = getThumbnail(from: url)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.image = .failed(error)
                    debugPrint(error.localizedDescription)
                default: break
                }
            }, receiveValue: { response in
                self.image = .finished(response)
        })
    }
    
    func cancelLoad() {
        self.cancellable?.cancel()
    }
    
    func isFinished<Content: View>(@ViewBuilder content: (UIImage) -> Content) -> Content? {
        return image.isFinished(content: content)
    }
    
    func isLoading<Content: View>(@ViewBuilder content: () -> Content) -> Content? {
        return image.isLoading(content: content)
    }
    
    func isFailed<Content: View>(@ViewBuilder content: (NetworkError) -> Content) -> Content? {
        return image.isFailed(content: content)
    }
}
