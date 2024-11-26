# Inventory

Demo app for showcasing Ditto's real-time sync and Conflict Resolution through the use of an inventory counter.

This inventory demo showcases the smoothness of Ditto's sync and conflict resolution, and how counters work with Ditto. You can also open up the Presence Viewer to see all existing devices and connections in the mesh.

Powered by [Ditto](https://www.ditto.live/).

For support, please contact Ditto Support (<support@ditto.live>).

- [Demo Video](https://www.youtube.com/watch?v=1P2bKEJjdec)
- [iOS Download](https://apps.apple.com/us/app/ditto-inventory/id1449905935)
- [Android Download](https://play.google.com/store/apps/details?id=live.ditto.inventory)


## How to build the apps

### iOS

1. Run `cp .env.template .env` at the root directory
1. Edit `.env` to add environment variables
1. Open the app project on Xcode and clean (<kbd>Command</kbd> + <kbd>Shift</kbd> + <kbd>K</kbd>)
1. Build (<kbd>Command</kbd> + <kbd>B</kbd>)
    - This will generate `Env.swift`

### Android

1. Open `/Android/gradle.properties` and add environment variables
1. Build the app normally


## License

MIT
