# TCA-Snake-2
[![xcodebuild](https://github.com/p-larson/TCA-Snake-2/actions/workflows/xcodebuild.yml/badge.svg)](https://github.com/p-larson/TCA-Snake-2/actions/workflows/xcodebuild.yml)

This repository contains the source code for the `macOS` interpretition of the popular game Snake, built with `SwiftUI` and `TCA`. 

<img src="https://user-images.githubusercontent.com/22569521/233392660-85f50dc9-ad85-416b-95d0-bfc36958f346.gif" width=500px height=400px></img>

---

# About

`Snake` is a retro arcade-style game, built in almost every programming language in existance, it's history is similar to that of `Pong`. The whole application is powered by the [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) with a focus on composability, modularity, and testing.

# Architecture

[`Snake.swift`](https://github.com/p-larson/TCA-Snake-2/blob/8c616eaf6cfb6fdbc770b76b1677acbafb08994d/TCA-Snake%202/Snake.swift)
- [`State`](https://github.com/p-larson/TCA-Snake-2/blob/8c616eaf6cfb6fdbc770b76b1677acbafb08994d/TCA-Snake%202/Snake.swift#L20)
- [`Actions`](https://github.com/p-larson/TCA-Snake-2/blob/8c616eaf6cfb6fdbc770b76b1677acbafb08994d/TCA-Snake%202/Snake.swift#L46)
- [`Reducer`](https://github.com/p-larson/TCA-Snake-2/blob/8c616eaf6cfb6fdbc770b76b1677acbafb08994d/TCA-Snake%202/Snake.swift#L73)

## Dependencies

* [**HighScoreClient**](https://github.com/p-larson/TCA-Snake-2/blob/8c616eaf6cfb6fdbc770b76b1677acbafb08994d/TCA-Snake%202/HighScoreClient.swift)
  <br> Acts a database, with a getter and setter method to interact with the stored data which is just for this projects purpose: the   
  highscore. This, like the other dependencies, doesn't make any real world requests. Simply, this mimicks the structure of a potential 
  RESTful API get and post request but instead of it being to a server, its just to `UserDefaults`. So yes, this is just a controlled 
  dependency wrapper for local storage, but this makes it testable and composable!

* [**CoordinateGenerator**](https://github.com/p-larson/TCA-Snake-2/blob/8c616eaf6cfb6fdbc770b76b1677acbafb08994d/TCA-Snake%202/CoordinateGenerator.swift)
  <br> Represents a third party system with a failable task to generate a `Coordinate` inside of a player's game. This does not actually send   a request outside of the system, it's a just to simulate a outside system request.
  
## Tests

[TCA_Snake_2_Tests.swift](https://github.com/p-larson/TCA-Snake-2/blob/8c616eaf6cfb6fdbc770b76b1677acbafb08994d/TCA-Snake%202%20Tests/TCA_Snake_2_Tests.swift)
