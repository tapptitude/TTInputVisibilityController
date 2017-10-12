# TTInputVisibilityController
![](https://img.shields.io/badge/Swift-4.0-green.svg?style=flat)
![](https://img.shields.io/badge/Swift-3.0-green.svg?style=flat)
[![Twitter](https://img.shields.io/badge/Twitter-@Tapptitude-blue.svg?style=flat)](http://twitter.com/Tapptitude)

## About
Lightweight controller to keep your inputs visible when the keyboard is presented.

This project is maintained by Tapptitude, a Product-Focused Mobile Development Agency based in Cluj-Napoca, Romania, and London, the UK, specialised in building high-quality Native Mobile Apps on iOS & Android. 


## Features:
- Very easy to integrate
- Lightweight
- Works with any inputs or keyboard types

## Requirements

- iOS 8.0+
- Xcode 7.3+

## Installation

_CocoaPods_

_Swift 4.0_

```ruby
pod 'TTInputVisibilityController'
```

_Carthage_

```
github "tapptitude/TTInputVisibilityController"
```

_Manually_

Add the contents of TTInputVisibilityController files to your project.

## Usage

- Programatic:


```
let segmentedControl = TTSegmentedControl()
segmentedControl.allowChangeThumbWidth = false
segmentedControl.frame = CGRect(x: 50, y: 200, width: 100, height: 50)
segmentedControl.didSelectItemWith = { (index, title) -> () in
    print("Selected item \(index)")
}
view.addSubview(segmentedControl)
```

## Usage

Checkout the playground and see how to implement and customize the SegmentedControl.

```ruby
pod try TTInputVisibilityController
```

In order to customize the segmented control you'll have to edit it's properties.

```swift
segmentedControl.defaultTextColor = UIColor.blackColor()
segmentedControl.selectedTextColor = UIColor.whiteColor()
segmentedControl.thumbGradientColors = [UIColor.redColor(), UIColor.blueColor()]
segmentedControl.useShadow = true

```


## Contribution

Feel free to Fork, submit Pull Requests or send us your feedback and suggestions!


## License

TTInputVisibilityController is available under the MIT license. See the LICENSE file for more info.
