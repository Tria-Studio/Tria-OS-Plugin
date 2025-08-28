# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.2] - 2025/XX/XX
### Added
- Added the option to manually run a Runtime Check on all Scripts inside a map in the Scripting menu.
- Added support for the following `v1.4` MapKit features:
~ Added `Fluid Priority` to Liquid & Gas settings.
~ Added `UseTopOnly` to Wallrun settings.
~ Added `Conveyor` Object support to Object Tags, Debug View, & Resources menus.

### Changed
- Moved `Script Autocomplete Settings` to the top of the Scripting page.
- The plugin will no longer automatically convert the `Music` folder to the `Sound` instance, and will leave it as a Folder/Configuration instance.
- `Automatic Runtime Injection` is now set to false by default for new plugin installs. 

### Fixed
- Fixed `Shadow Softness` Lighting property is not being recognised by the plugin.
- Fixed inserting the MapKit sometimes not working.
- Fixed Group Button debug view always showing 50% instead of its PlayerPercensge attribute.



## [1.2.1] - 2025/05/29
### Added
- Added an option to toggle runtime injection in the scripting menu

### Changed
- Maps can now be inside of Folders instead of only Models & Unparented in workspace
- Disabled runtime script injections when more than one person is inside of a studio place.
~ This hopefully will be undone in the future but is in place now to help prevent duplicating scripts.

### Fixed 
- Fixed an issue where you could not insert the 1.0 mapkit if you do not own the model due to a change in Roblox model permissions.



## [1.2.0] - 2023/18/01
### Added
- Added support for the TRIA.os `v1.0` MapKit:
~ All new properties, settings, and new features have been added to the `Object Tags`, `Debug View`, and `Resources` tabs.

- Added an option to automatically convert older mapkit formats to the Optimized Structure format.
- Added Automatic Runtime Injection for all scripts.
- Added `Orb Projections` to Orb Debug View modes.

### Fixed
- Fixed a bug where some actions may not properly initiate when the plugin is loaded for the first time and a map gets auto selected.

### Removed
- Removed `Featured Addons` in support for the #Assets-and-Mods channel in the Discord.
- Removed the `Map Manager` menu, this idea was scrapped.



## [1.1.2] - 2023/19/08
### Changed
- Audio Library will now set the 'Music' value in the 'Music' folder rather than the 'Main' folder

### Fixed 
- Fixed Lighting Import not working due to ChangeHistoryService API migration
- Fixed setting music via Audio Library not working due to ChangeHistoryService API migration



## [1.1.1] - 2023/14/08
### Fixed
- Settings menu setting number types as strings, possibly breaking maps when loading them in TRIA.os



## [1.1.0] - 2023/12/08
### Added
- Added Support for rails. Visualizing, metadata, & converting ziplines to rails + vise-versa
- Added Support for converting map objects to optimized structure (does not touch scripts)
- Added a warning to warn you if your map does not use OptimizedStructure
- Added Ability to disable prints in the output in the debug menu

### Changed
- Any missing settings now get auto-filled to their default values instead of doing nothing
- All ChangeHistoryService calls now use the new API
- Updated all component inserts to be up-to-date

### Fixed
- Fixed Waterjets not working in game
- Fixed teleporters inserted not working in game
- Fixed Zipline momentum being a checkbox rather than a number box
- Fixed other errors + bugs 

### Removed
- Removed legacy BGM + BGM Volume setting from the 'Main' folder. Use the dedicated 'Music' folder from now on.



## [1.0.0] - 2023/06/17
###  Added
- Added the `Resources` Menu:
~ Quick access to insert frequent map components like buttons, wallruns, orbs, etc.
~ Added the abillity to insert the most up-to-date TRIA.os MapKit from the plugin.
~ Added Featured Addons, a select amount of useful tools and additions that are not offical mapkit features but can help.

- Added a new `Settings` Menu with a new look and more functionallity:
~ Added the abillity to create, rename, and remove custom liquids from the settings menu
~ Added dropdown categories to all main setting types
~ Added Import / Export to Lighting buttons to quickly load / preview map lighting.

- Added `Debug View Modes` that allow you to visualize certain components within maps:
~ Easily view all parts that are tagged with `Low Detail Mode`, `Killbricks`, or any other mapkit feature / button tag.
~ Visualize how ziplines will generate and how they will look with the Zipline preview.
~ View how buttons will look with their locators
~ View map variants and what parts are apart of what variant

- Added `MapLib Script Autocomplete` to the Script Editor: 
~ Autocomplete all MapLib functions and its arguments in the MapScript / LocalMapScript / EffectScript
~ Showcase what arguments all MapLib functions take, aswell as descriptions and code examples for all functions.

- Added `Audio Library` integration
~ Search the TRIA.os Audio Library directly from studio and find Map BGMs to use by BGM Name / Author Name
~ Preview audios and scroll through audios to find the one you are looking for.

- Added the `Object Tags` menu that allows you to assign parts in maps as gameplay mechanics
~ Added contextual metadata editors for each gameplay feature allowing you to effectively set all of the metadata for each interactable.

- Added the `Studio Map Manager` page to the plugin, currently disabled.

- Added Tooltips all throughout the plugin for buttons explaining what each setting or what each MapKit feature does.