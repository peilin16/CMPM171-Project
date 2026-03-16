# CMPM171-Project  Ron&Gun

## Non-Original Assets Citation
- [Font - Pixelify Sans](https://github.com/eifetx/Pixelify-Sans) (Licensed under [the SIL Open Font License, Version 1.1](https://openfontlicense.org/))
- [The adventurer - Female](https://sscary.itch.io/the-adventurer-female) (Purchased for Premium Ver.)


## Running Requirements
### Windows
Add contents here

---

### MacOS (Universal Build - Apple Silicon & Intel Processors)
Minimum OS version:
- Apple Silicon (arm64): 11.00
- Intel Processors (x86_64): 10.12


Since we, as student developers, don't have an Apple Developer ID Certificate, we can only:

select `Built-in (ad-hoc only)` in the `Code Signing > Codesign` option

and `Disabled` in the `Notarization` option

to export our build from Godot.

Therefore, here are 2 cases you might run into:

1. When you run the app for the first time, the following dialog is displayed: `"Ron&Gun.app" can't be opened because Apple cannot check it for malicious software.`
- Open `System Preferences`
- Click `Security & Privacy`, then scroll down to the bottom, and click `Open Anyway`.

2. OR when you run the app for the first time, the following dialog is displayed: `"Ron&Gun.app" is damaged and can't be opened. You should move it to the Bin.`
- Open `Terminal`
- Navigate to the folder containing the app (Use the `cd path_to_the_app_folder` command, e.g. `cd Applications` if it's installed there).
- Run `xattr -dr com.apple.quarantine "Unsigned Game.app"` (including quotation marks & .app extension name)
