# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

### V 1.2

####  Added
 - Notices for users using old mapkit versions encouraging them to update their map
 - New notices to the insert page
 - Added 'Texture Kit' by Phexonia to the insert page
 - New dropdown menus to some setting objects
 - LDM tag
 - Speed + Jump booster tags
 
 #### Changed
 - Updated settings page to have the new 0.6 settings
 - Settings page will now tell you if a setting cannot be found
 - Improved selecting buttons to edit properties
 - Insert page will now use the latest versions of the mapkits automatically
 - Improved map detection for non TRIA.os maps
 - Oxygen can now be edited inside of an airtank
 
 #### Fixed
 - 0.6 map kits not working
 - Button/object tags can be clicked when no parts are selected
 - Object tag menu wouldnt show if a part was tagged with _Kill
 - Other bug fixes


### V 1.1
#### Added
 - _Kill function support
 - Insert tab
   - This will allow you to insert the map kit, map addons, and complex map components.

#### Fixed
 - Colorwheel not working
 - Colorwheel not respecting undo/redo
 - Last selected map not loading at the start of a new studio session
 - Notification screen wasnt scaling its size correctly

### V 1.0.1
#### Added
 - "Export to Lighting" option in settings editor

#### Changed
 - Updated formatting for difficulty tooltip


## V 1.0[^2]
 - TRIA.os Release
#### Added
 - New Interface
 - Last selected map now saves between studio sessions
 - Undo/Redo support
 - New message system instead of studio output
 - Abillity to alter the metadata (button #, delay, etc.) of each individual tag type (wallruns, _Show, etc.) 
 - Map settings editor

#### Changed
 - Rewritten plugin internals

#### Fixed
 - Map selecting bug fixes
 - Bug fixes

#### Removed
 - View modes (these will return at a later date)


### V 0.3
 #### Changed
  - Improved Object View mode internals
 
 #### Fixed
 - Bug fixes


### V 0.2
 #### Added
  - Dark/Light mode support
  - LDM View Mode
 
 #### Fixed
  - Bug Fixes


## V 0.1[^1] 
 - Beta Release
 #### Added
  - View modes:
    - _Detail
    - Variant
    - Object
    - Button
  - Abillity to edit button function properties
 
 
 [^1]: v0.1 was originally released as a FE2 Map Test plugin as a beta test.
 [^2]: V1.0 Brought the plugin out of concept into a full release during TRIA.os v0.5 beta.
