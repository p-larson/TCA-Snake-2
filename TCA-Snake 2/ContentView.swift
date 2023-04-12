//
//  ContentView.swift
//  TCA-Snake 2
//
//  Created by Peter Larson on 4/3/23.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    func keyboard(store: ViewStore<Snake.State, Snake.Action>) -> some View {
        HStack {
            ForEach([.upArrow, .downArrow, .rightArrow, .leftArrow, .space] as [KeyEquivalent], id: \.character) {
                key in 
                Button(String(describing: key)) {
                    store.send(.key(key.character))
                }
                .keyboardShortcut(key, modifiers: [])
            }
        }
    }
    
    let store:  StoreOf<Snake>
    
    func board(store: ViewStore<Snake.State, Snake.Action>) -> some View {
        Canvas { context, size in 
            let cubeSize = CGSize(
                width: size.width / CGFloat(store.width), 
                height: size.height / CGFloat(store.height)
            )
            
            let path = Path {
                $0.addRects(store.player.map { coordinate in
                    CGRect(
                        x: cubeSize.width * CGFloat(coordinate.x), 
                        y: cubeSize.height * CGFloat(store.height - coordinate.y)  - cubeSize.height, 
                        width: cubeSize.width, 
                        height: cubeSize.height
                    )
                })
            }
            context.fill(path, with: .color(.yellow))
            context.fill(
                Path(
                    CGRect(
                        x: cubeSize.width * CGFloat(store.food.x), 
                        y: cubeSize.height * CGFloat(store.height - store.food.y) - cubeSize.height, 
                        width: cubeSize.width, 
                        height: cubeSize.height
                    )
                ), with: .color(.red)
            )
        }
        .background(Color.blue)
        .frame(
            maxWidth: CGFloat(Snake.cellSize) * CGFloat(store.width), 
            maxHeight: CGFloat(Snake.cellSize) * CGFloat(store.height)
        )
    }
    
    var body: some View {
        WithViewStore(store) { viewStore in 
            VStack {
                HStack {
                    Text("TCA-Snake 2")
                    Spacer()
                    Text(viewStore.player.count.description)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                GeometryReader { proxy in 
                    Color.clear
                        .onChange(of: proxy.size) { newValue in
                        viewStore.send(.canvas(newValue))
                    }
                    board(store: viewStore)
                        .frame(alignment: .center)
                }
                
                HStack {
                    Text("Length \(viewStore.player.count)")
                        .foregroundColor(.white)
                    Text("Food \(viewStore.food.debugDescription)")
                        .foregroundColor(.white)
                    Text(String(describing: viewStore.status))
                        .foregroundColor(.white)
                    Text(String(describing: viewStore.width) + "x" + String(describing: viewStore.height))
                        .foregroundColor(.white)
                } 
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.orange.background(keyboard(store: viewStore)))
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store: StoreOf<Snake>(
                initialState: Snake.State(),
                reducer: Snake()
            )
        )
    }
}
