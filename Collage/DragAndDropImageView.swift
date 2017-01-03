// https://gist.github.com/raphaelhanneken/d77b6f9b01bef35709da

import Cocoa

class DragAndDropImageView: NSImageView, NSDraggingSource {
    // Holds the last mouse down event, to track the drag distance.
    var mouseDownEvent: NSEvent?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        // Assure editable is set to true, to enable drop capabilities.
        self.isEditable = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.resignFirstResponder()
        
        // Assure editable is set to true, to enable drop capabilities.
        self.isEditable = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

    
    // MARK: - NSDraggingSource
    
    // Since we only want to copy/delete the current image we register ourselfes
    // for .Copy and .Delete operations.
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return .copy
    }
    
    // Track mouse down events and safe the to the poperty.
    override func mouseDown(with event: NSEvent) {
        self.mouseDownEvent = event
    }
    
    // Track mouse dragged events to handle dragging sessions.
    override func mouseDragged(with event: NSEvent) {
        // Calculate the drag distance...
        let mouseDown    = self.mouseDownEvent!.locationInWindow
        let dragPoint    = event.locationInWindow
        let dragDistance = hypot(mouseDown.x - dragPoint.x, mouseDown.y - dragPoint.y)
        
        // ...to cancel the dragging session in case of accidental drag.
        if dragDistance < 3 {
            return
        }
        
        // Unwrap the image property
        if let image = self.image {
            // Do some math to properly resize the given image.
            let size = NSSize(width: log10(image.size.width) * 30, height: log10(image.size.height) * 30)
            let img = image
            img.size = size
            
            // Create a new NSDraggingItem with the image as content.
            let draggingItem        = NSDraggingItem(pasteboardWriter: image)
            // Calculate the mouseDown location from the window's coordinate system to the
            // ImageView's coordinate system, to use it as origin for the dragging frame.
            let draggingFrameOrigin = convert(mouseDown, from: nil)
            // Build the dragging frame and offset it by half the image size on each axis
            // to center the mouse cursor within the dragging frame.
            let draggingFrame       = NSRect(origin: draggingFrameOrigin, size: img.size).offsetBy(dx: -img.size.width / 2, dy: -img.size.height / 2)
            
            // Assign the dragging frame to the draggingFrame property of our dragging item.
            draggingItem.draggingFrame = draggingFrame
            
            // Provide the components of the dragging image.
            draggingItem.imageComponentsProvider = {
                let component = NSDraggingImageComponent(key: NSDraggingImageComponentIconKey)
                
                component.contents = image
                component.frame    = NSRect(origin: NSPoint(), size: draggingFrame.size)
                return [component]
            }
            
            // Begin actual dragging session. Woohow!
            beginDraggingSession(with: [draggingItem], event: mouseDownEvent!, source: self)
        }
    }
}
