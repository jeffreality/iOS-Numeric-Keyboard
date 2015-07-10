# iOS Numeric Keyboard
Numeric keyboard replacement for `UITextField` (within iOS projects)

## Overview
This is a keyboard replacement for textfields within iOS projects.

Any `UITextField` can have its `inputView` set to the `NumPad` object, which will then display the number pad when tapped.

The number pad can be configured to display a number pad (with or without decimal support), or it can support basic calculator functionality.

## Display

### iPad : Landscape

![iPad displaying NumPad as floating point numeric pad, in landscape](README-images/iPad-landscape.png?raw=true)

The above image shows how the NumPad replacement looks on an iPad as a floating point numeric pad, in landscape.

![iPad displaying NumPad as floating point calculator, in landscape](README-images/iPad-landscape-calculator.png?raw=true)

This is the same control, with the calculator feature enabled.  The backspace button becomes a clear button.  (This screen shows the Prev and Next buttons instead of Done, but those were only set to illustrate another difference in capability.)

### iPad : Portrait

![iPad displaying NumPad as floating point calculator, in portrait](README-images/iPad-portrait-calculator.png?raw=true)

This is the portrait view of the control, showing the calculator functionality.

### iPhone 4s example

![iPhone displaying NumPad in landscape](README-images/iPhone4s-landscape.png?raw=true)

![iPhone displaying NumPad with calculator in portrait](README-images/iPhone4s-portrait.png?raw=true)

This is the portrait view of the control, showing the calculator functionality.

## Implementation Examples

The NumPadDemo project shows a complete example (along with controls to dynamically change some of the functions).

To implement within your own projects:

`#import "NumPad.h"`

And 

`[NumPad setKeyboardFor:myTextField];`

(where `myTextField` is an instance of `UITextField` or a sub-class thereof.)

To configure some of the other features (such as the calculator), the request would be something like:

`[NumPad setKeyboardFor:myTextField withDecimal:YES andCalculator:YES maxCharacters:8];`

- `withDecimal:(BOOL)`
  - YES = shows a button with a period (.) to support floating point numbers
  - NO = hides the button
- `andCalculator:(BOOL)`
  - YES = shows the calculator buttons
  - NO = hides the buttons
- `maxCharacters:(NSInteger)`
  - limits the number of characters in the textField to the submitted integer value

Additionally, you can set the tag value to an incremental number (i.e. `textField1.tag = 1; textField2.tag = 2;` ...) and the Next and Prev buttons will automatically move between the textFields on screen.  Pressing it on the final field will hide the NumPad.

## Known Issues

There is a known issue with changing orientation (i.e. changing the screen's orientation doesn't recalculate the sizes properly).