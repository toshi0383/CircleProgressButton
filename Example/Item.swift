//
//  Item.swift
//  Example
//
//  Created by 鈴木 俊裕 on 2018/03/19.
//  Copyright © 2018 toshi0383. All rights reserved.
//

import Foundation

struct Item {
    let state: State
    enum State {
        case active(Float), inactive(Float), completed

        var progress: Float {
            switch self {
            case .active(let v): return v
            case .inactive(let v): return v
            case .completed: return 100
            }
        }
    }
}
