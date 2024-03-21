<p align="center"><img src="./DiaBLE/Assets.xcassets/AppIcon.appiconset/Icon.png" width="25%" /> &nbsp; &nbsp; <img src="https://github.com/gui-dos/DiaBLE/assets/7220550/901ad341-edfb-426e-9617-6763cf377447" width="20.5%"/> &nbsp; &nbsp; <img src="https://github.com/gui-dos/DiaBLE/assets/7220550/57aa2b5f-6458-42a8-8d86-23eeb5260206" width="20.5%" /></p>
<br><br>

**ChangeLog:**
* 20/1/2024 - [Build 88](https://github.com/gui-dos/DiaBLE/commit/d1333f3)  
  - Shell: import and dump LibreView CSV files by using TabularData:
<p align="center"><img src="https://github.com/gui-dos/DiaBLE/assets/7220550/01050cf3-2f75-4034-8861-5e33475c972b" width="75%"/>
<br><br>

To build the project you have to duplicate the file _DiaBLE.xcconfig_, rename the copy to _DiaBLEOverride.xcconfig_ (the missing reference displayed by Xcode in red should then point to it) and edit it by deleting the last line `#include?... ` and replacing `##TEAM_ID##` with your Apple Team ID so that the first line should read for example `DEVELOPMENT_TEAM = Z25SC9UDC8`.

The NFC capabilities require a paid Apple Developer Program annual membership but a public beta is availaBLE at **[TestFlight](https://testflight.apple.com/join/H48doU3l)** anyway. If you own an iPad you can also download the [zipped archive](https://github.com/gui-dos/DiaBLE/archive/refs/heads/main.zip) of this repository and just tap _DiaBLE Playground.swiftpm_.

Currently I am targeting only the latest betas of Xcode and iOS and focusing on the new Libre 3. Please refer to the [**TODOs**](https://github.com/gui-dos/DiaBLE/blob/main/TODO.md) list for the up-to-date status of all the current limitations and known bugs of this **prototype**.

**Warnings:**
  * the temperature-based calibration algorithm has been derived from the old LibreLink 2.3: it is known that the Vendor improves its algorithms at every new release, smoothing the historical values and projecting the trend ones into the future to compensate the interstitial delay but these further stages aren't understood yet; I never was convinced by the simple linear regression models that others apply on finger pricks;
  * activating the BLE streaming of data on a Libre 2 will break other apps' pairings and you will have to reinstall them to get their alarms back again; in Test mode it is possiBLE however to sniff the incoming data of multiple apps running side-by-side by just activating the notifications on the known BLE characteristics: the same technique is used to analyze the Libre 3 incoming traffic since the Core Bluetooth connections are reference-counted;
  * connecting directly to a Libre 2/3 from an Apple Watch is currently just a proof of concept that it is technically possiBLE: keeping the connection in the background will require additional work and AFAIK nobody else is capaBLE of doing the job... :-P
  
The Shell in the Console allows opening both encrypted and decrypted _trident.realm_ files from a backup of the Libre 3 app data (the Container folder extracted for example by using iMazing): see the nice technical post (mentioning me 😎) ["Liberating glucose data from the Freestyle Libre 3"](https://frdmtoplay.com/freeing-glucose-data-from-the-freestyle-libre-3/) (a rooted Android Virtual Machine like Waydroid or the default _Google APIs System Image_ in Android Studio is required to unwrap the Realm encryption key).
