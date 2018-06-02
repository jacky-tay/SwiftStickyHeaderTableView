# SwiftStickyHeaderTableView
Allow table view cell sticks on the top of the screen when user view it in a grouped table view.

![Demo](https://github.com/jacky-tay/SwiftStickyHeaderTableView/blob/master/Assets/sticky1.mov.gif)

## Background
One of the iOS app I've built is required to build a review summary for a document. The data is presented in a grouped UITableView, and the table view cell should behave like a header table view in a plain UITableView.

## Workaround
There is a table view, known as stick table view which allows table view cell to act like a sticky header, is displayed on top of the main table view. Since the sticky table view is rendered on top of the main table view, the scroll bar of the main table view is blocked, hence there is a scroll view which is displayed on top of table views and it has the same content size as the main table view.

## Data Source Sturcture
There are two data displayable classes, Section and Row. In this demo all data are constructed from a JSON file.
#### Section
A Section object contains a list of Row items. It may also contain a header and a footer, they are used for section header and section footer in table view.
#### Row
A Row object may contain a list of Row children. In this demo a Row class has basic title and detail values. 

There are three types of table view cells illustrates the concept: VehicleCell, PersonCell, and StandardCell. 
For example, a vehicle sub-section contains multiple people content, when the person's details are viewed in the list, the vehicle and person cells are stick on the top as header.

## Requirements
* Minimum iOS version: 11.0
* XCode 9.4
* Swift 4.1

## Author
Jacky Tay - Software Developer - [Smudge](http://www.smudgeapps.com/)

## License
SwiftStickyHeaderTableView is available under the MIT license. See the [LICENSE](https://github.com/jacky-tay/SwiftStickyHeaderTableView/blob/master/LICENSE) file for more info.

## Disclaims
1. Note that the content in this demo is from [NZTA](http://www.nzta.govt.nz/assets/resources/traffic-crash-reports/docs/traffic-crash-reports.pdf). I DO NOT own the copy right of the data content.
2. Icons used in this project are provided by [Icon8](https://icons8.com/free-icons/)
