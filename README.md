VS Code extension for formatting AL files.

![Formatting Example](https://github.com/RasmusTidselbak/al-formatter/blob/master/client/images/al_formatter.gif?raw=true)


### Features
- Indentation
- Keyword case style
- Sort variable definitions
- Spacing

### Usage
To format a file click `alt + shift + f` or use the format document feature in VS Code.

### In Development
Full implementation of the Microsoft C/AL Coding Guidelines.<br>
[Microsoft C/AL Coding Guidelines](https://blogs.msdn.microsoft.com/nav/2015/01/09/cal-coding-guidelines-used-at-microsoft-development-center-copenhagen/)



### Changes
#### 1.1.1
- Fixed an issue with var parameters in procedure definitions

#### 1.1.0
- Implementet the readability guidlines for variable definition and operators.
- Fixed an issue with textconst definitions
- Fixed an issue with wrong casing on object definitions
