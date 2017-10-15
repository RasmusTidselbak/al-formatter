VS Code extension for formatting AL files.

![Formatting Example](https://bytebucket.org/rasmustidselbak/al-formatter/raw/470a9f1d65f008614d7267d097335b919e359257/client/images/al_formatter.gif)


### Features
- Indentation
- Keyword case style
- Sort variable definitions
- Readability Guidelines - Spacing and newlines (experimental)

### Usage
To format a file click `alt + shift + f` or use the format document feature in VS Code.

### Report an Issue
Issues can be reported to the project on [Github](https://github.com/RasmusTidselbak/al-formatter/issues).

### In Development
- RDLC Reports
- XMLPorts
- Lists, Dictionaries and Control Addins

### Changes
#### 2.0.1
- Fixed a couple of issues when indenting IF THEN ELSE statements, DO WHILE and BEGIN END
- Implemented an entire new code structure, which is more dynamic
- Implemented newline and spacing. Enable it under settings - alForm.experimental

#### 1.1.1
- Fixed an issue with var parameters in procedure definitions

#### 1.1.0
- Implementet the readability guidlines for variable definition and operators.
- Fixed an issue with textconst definitions
- Fixed an issue with wrong casing on object definitions
