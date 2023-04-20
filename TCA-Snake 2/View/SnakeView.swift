//
//  SnakeView.swift
//  TCA-Snake 2
//
//  Created by Peter Larson on 4/13/23.
//

import SwiftUI
import ComposableArchitecture

fileprivate let observedKeys: [KeyEquivalent] = [.upArrow, .downArrow, .rightArrow, .leftArrow, .space]

struct SnakeView: View {
    let store: StoreOf<Snake>
    
    func keyboard(_ viewStore: ViewStoreOf<Snake>) -> some View {
        HStack {
            ForEach(observedKeys, id: \.character) {
                key in 
                Button(String(describing: key)) {
                    viewStore.send(.key(key.character))
                }
                .keyboardShortcut(key, modifiers: [])
            }
        }
    }
    
    var body: some View {
        WithViewStore(store) { viewStore in 
            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    Text("TCA-Snake 2")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                    Spacer()
                    Link("p-larson/TCA-Snake-2", 
                         destination: URL(
                            string: "https://github.com/p-larson/TCA-Snake-2"
                         )!
                    )
                    .underline()
                    .onHover { isHovering in
                        if isHovering {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                    
                }
                
                Canvas { context, size in
                    context.fill(
                        Path(
                            CGRect(
                                x: 0,
                                y: 0,
                                width: CGFloat(viewStore.width * Snake.cellSize),
                                height: CGFloat(viewStore.height * Snake.cellSize)
                            )
                        ), with: .color(Color.black.opacity(0.1))
                    )
                    
                    let cellSize = CGFloat(Snake.cellSize)
                    
                    let path: Path = Path {
                        $0.addRects(viewStore.player.map { coordinate in
                            CGRect(
                                x: CGFloat(coordinate.x) * cellSize, 
                                y: CGFloat(coordinate.y) * cellSize, 
                                width: cellSize, 
                                height: cellSize
                            )
                        })
                    }
                    context.fill(path, with: .color(.yellow))
                    context.fill(
                        Path(
                            CGRect(
                                x: cellSize * CGFloat(viewStore.food.x),
                                y: cellSize * CGFloat(viewStore.food.y),
                                width: cellSize, 
                                height: cellSize
                            )
                        ), with: .color(.red)
                    )
                }
                .frame(
                    minWidth: CGFloat(Snake.minWidth * Snake.cellSize),
                    minHeight: CGFloat(Snake.minHeight * Snake.cellSize)
                )
                .background(Color.white)
                .background(keyboard(viewStore))
                .overlay {
                    GeometryReader { reader in
                        Color.clear.onChange(of: reader.size) {
                            newValue in viewStore.send(.canvas(newValue))
                        }
                    }
                }
                
                HStack {
                    Text("Score: \(viewStore.player.count)")
                        .font(.body)
                    Spacer()
                    Text("High-Score: \(viewStore.highscore)")
                        .font(.callout)
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
        }
        .background(Color.white)
    }
}

struct SnakeView_Previews: PreviewProvider {
    static var previews: some View {
        SnakeView(store: StoreOf<Snake>(
            initialState: Snake.State(
                width: Snake.minWidth, 
                height: Snake.minHeight
            ),
            reducer: Snake()
        ))
    }
}
