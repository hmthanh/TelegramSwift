//
//  ContextMenu.swift
//  TGUIKit
//
//  Created by keepcoder on 03/10/2016.
//  Copyright © 2016 Telegram. All rights reserved.
//

import Cocoa


public class ContextSeparatorItem : ContextMenuItem {
    public init() {
        super.init("", handler: {}, image: nil)
    }
    
    public override var isSeparatorItem: Bool {
        return true
    }
    
    required public init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class ContextMenuItem : NSMenuItem {
    public let id: Int64 = arc4random64()
    public var rowItem:(()->TableRowItem)? = nil

    public let handler:()->Void
    private let dynamicTitle:(()->String)?
    
    public var contextObject: Any? = nil
    
    public let itemImage: ((NSColor, ContextMenuItem)->AppMenuItemImageDrawable)?
    public let itemMode: AppMenu.ItemMode
    
    public init(_ title:String, handler:@escaping()->Void = {}, image:NSImage? = nil, dynamicTitle:(()->String)? = nil, state: NSControl.StateValue? = nil, itemMode: AppMenu.ItemMode = .normal, itemImage: ((NSColor, ContextMenuItem)->AppMenuItemImageDrawable)? = nil) {
        self.handler = handler
        self.dynamicTitle = dynamicTitle
        self.itemMode = itemMode
        self.itemImage = itemImage
        super.init(title: title, action: nil, keyEquivalent: "")
        
        self.title = title
        self.action = #selector(click)
        self.target = self
        self.isEnabled = true
        self.image = image
        if let state = state {
            self.state = state
        }
    }
    
    public override var title: String {
        get {
            return self.dynamicTitle?() ?? super.title
        }
        set {
            super.title = newValue
        }
    }
    
    required public init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func click() -> Void {
        handler()
    }
    
}

public final class ContextMenu : NSMenu, NSMenuDelegate {

    
    public var contextItems: [ContextMenuItem] {
        return self.items.compactMap {
            $0 as? ContextMenuItem
        }
    }
    
    public var onShow:(ContextMenu)->Void = {(ContextMenu) in}
    public var onClose:()->Void = {() in}
        
    
    public static func show(items:[ContextMenuItem], view:NSView, event:NSEvent, onShow:@escaping(ContextMenu)->Void = {_ in}, onClose:@escaping()->Void = {}, presentation: AppMenu.Presentation = .current) -> Void {
        
        let menu = ContextMenu()
        menu.onShow = onShow
        menu.onClose = onClose
        
        for item in items {
            menu.addItem(item)
        }
        let app = AppMenu(menu: menu, presentation: presentation)
        app.show(event: event, view: view)
    }
    
    
    public func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return true
    }
    
    public func menuWillOpen(_ menu: NSMenu) {
        onShow(self)
    }
    
    public func menuDidClose(_ menu: NSMenu) {
        onClose()
    }
    
}





