# UTestTools iOS SDK

**UTestTools** is a cross-platform suite designed for the analysis and evaluation of the user experience associated with a software application through the capture and background recording of the individual's interaction with the application itself. This repository contains the SDK for integrating UTestTools with iOS applications.

## Description

The UTestTools SDK allows developers to carry out remote, unmoderated usability tests on their iOS applications. This type of test offers significant advantages over traditional supervised tests:

- **Flexibility**: Users decide when and where to conduct the tests, allowing evaluation in a real, uncontrolled environment.
- **No moderator needed**: There is no need for a person to guide the test session.
- **Cost reduction**: No need for a physical location or equipment for the tests; only an internet connection and a capable device are required.
- **Greater reach**: It is possible to recruit a larger number of participants in less time, enabling global studies.

The UTestTools iOS SDK is a set of software libraries for native iOS development. Once integrated with the developed applications, it allows these applications to be tested by providing the ability to characterize and capture user actions and send them to the analytics server once the test session is complete. The SDK supports testing on both real devices and the iOS simulator without the need for jailbreaking.

## Integration of UTestTools in an iOS Project

### 1. Duplicate the App's Build Target

To avoid altering the original build target of the app, create a new target exclusively for usability testing using UTestTools:

1. Access the project editing options by right-clicking on the project's name in the left panel of the Xcode window (the “project navigator”).
2. In the central panel, duplicate the app's original target by right-clicking on it and selecting the "Duplicate" option from the contextual menu.

### 2. Include UTestTools in the App's Xcode Project

To include the monitoring library in an existing Xcode project:

1. Access the directory where UTestTools' source code is located.
2. Drag the library's project file (`UTestTools.xcodeproj`) to the project navigator in Xcode.

### 3. Link UTestTools to the Test Target

To enable the app to use UTestTools' monitoring functionalities, instruct the compiler to link the library to the generated binary file:

1. Access the build configuration parameters within the project editor.
2. Locate the "Other Linker Flags" field using the editor's search box.
3. Add the `-all_load` linker flag.

### 4. Add Additional Libraries from the iOS SDK

Link the following additional libraries included in the iOS SDK to the build target:

- `SystemConfiguration.framework`
- `CoreData.framework`
- `CoreLocation.framework`
- `QuartzCore.framework`

## Installation

1. Clone the repository.
2. Follow the integration steps mentioned above.

