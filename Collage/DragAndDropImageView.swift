// https://gist.github.com/raphaelhanneken/d77b6f9b01bef35709da

import Cocoa

class DragAndDropImageView: NSImageView {
    var delegate: ScrollViewDelegate?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        // Assure editable is set to true, to enable drop capabilities.
        self.isEditable = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        // Assure editable is set to true, to enable drop capabilities.
        self.isEditable = true
    }
    
    override func viewWillDraw() {
        super.viewWillDraw()
        delegate?.update()
    }
}
