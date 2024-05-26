//
//  SwipeAction.swift
//
//
//  Created by iwacchi on 2024/05/25.
//

import SwiftUI

public struct SwipeAction {
    
    internal let id: String
    internal let title: String?
    internal let image: Image?
    internal let textColor: Color
    internal let backgroundColor: Color
    internal let width: CGFloat
    internal let action: () -> Void
    
    internal var isTitleOnly: Bool {
        return title != nil && image == nil
    }
    internal var isImageOnly: Bool {
        return title == nil && image != nil
    }
    
    init(
        title: String,
        textColor: Color,
        backgroundColor: Color,
        width: CGFloat = 80,
        action: @escaping () -> Void
    ) {
        self.id = UUID().uuidString
        self.title = title
        self.image = nil
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.width = width
        self.action = action
    }
    
    init(
        image: Image,
        textColor: Color,
        backgroundColor: Color,
        width: CGFloat = 80,
        action: @escaping () -> Void
    ) {
        self.id = UUID().uuidString
        self.title = nil
        self.image = image
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.width = width
        self.action = action
    }
    
    init(
        title: String,
        image: Image,
        textColor: Color,
        backgroundColor: Color,
        width: CGFloat = 80,
        action: @escaping () -> Void
    ) {
        self.id = UUID().uuidString
        self.title = title
        self.image = image
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.width = width
        self.action = action
    }
    
}
