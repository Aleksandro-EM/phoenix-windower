# Windower on Phoenix FFXI

Windower 4 can launch Phoenix if you register the Phoenix client with Windows, add a `patch.ver` built for Phoenix's client version, and load the era DATs with XIPivot. Phoenix staff don't support Windower, so use this at your own risk.

## Before you start

The official launcher runs the game inside Ashita's sandbox, which skips a client version check and supplies registry settings. Outside it, you have to provide both yourself. That's all this guide does.

You need:

- Phoenix installed with the official launcher (it downloads the client and the era DATs)
- Windower 4, ideally in its own folder, separate from any other server's setup
- Admin rights on your PC, for one registry step

Caveats:

- **Unsupported.** Phoenix staff say Windower players are on their own. Don't take Windower problems to staff support.
- **Addons and plugins are allowlist-only.** Check [phoenix-xi.com/approved-addons](https://phoenix-xi.com/approved-addons) before you autoload anything.
- **One client at a time.** If you also play another private server through Windower (HorizonXI, for example), Step 2 points Windows at Phoenix. Run that server's own switcher before you play it.
- **Tested on one PC** (Windows 10, Windower 4, `phoenix-loader` 2.1.1.0): logged in and played on the live server on launch day, Sep 24 2026.

## Step 1: Install Phoenix and run it once

Install Phoenix with the official launcher, let it finish downloading, and launch the game once. That run fills in the era DATs.

This guide calls the install folder **`<Phoenix>`**. It's the folder that holds `bootloader\`, `polplugins\` and `SquareEnix\` (for example `D:\Games\PhoenixXI`). Check that these exist:

- `<Phoenix>\bootloader\phoenix-loader.exe`
- `<Phoenix>\SquareEnix\FINAL FANTASY XI\FFXiMain.dll`
- `<Phoenix>\polplugins\DATs\EraDATs\ROM`

Keep the official launcher installed. It's how you get client and DAT updates.

## Step 2: Register the Phoenix client

Windower's loader finds the game through the Windows registry and starts it through COM. Both have to point at Phoenix's files, not another server's. The official launcher never does this, because its sandbox fakes it.

Copy [`Switch_Phoenix.bat`](Switch_Phoenix.bat) into `<Phoenix>\SquareEnix\`, then right-click it and choose **Run as administrator**. It:

- sets the FFXI and PlayOnline install paths (`HKLM\SOFTWARE\WOW6432Node\PlayOnlineUS\InstallFolder`)
- sets `PlayOnlineUS\Interface\0001` to `0`
- registers the game's COM DLLs (`FFXi.dll`, `FFXiMain.dll`, `FFXiVersions.dll`) and PlayOnline's (`polcore.dll`, `app.dll`, contents and ActiveX DLLs) from the Phoenix install

Notes:

- **`Interface\0001` must be `0`.** The `patch.ver` in Step 3 is encrypted with a key taken from this value. Another value makes the game reject the file.
- **It's based on HorizonXI's `Switch_Horizon.bat`**, plus the PlayOnline DLLs. The PC this was tested on already had those PlayOnline components registered, so the extra `regsvr32` lines haven't been tested on a clean PC.
- **Switching back** to another server means running that server's switcher. It re-registers its own files the same way.

## Step 3: Add the Phoenix patch.ver

Phoenix ships no `patch.ver`, so outside the official launcher the game closes right after "Resolving host". Borrowing another server's `patch.ver` gets past that, but then the client reports that server's version, and Phoenix answers with error **3331** ("FINAL FANTASY XI has been updated"). You need a `patch.ver` that reports Phoenix's version, **`30260904_1`** (the minimum in Phoenix's source code, `settings/default/login.lua`).

1. Download [`patch.ver`](patch.ver) from this repository. It's a 288-byte file with SHA-256 `9DFBA3A0F4109225F2C280B0BFF69E9199E0B034AAD6626324DB787E90607620`.
2. Copy it into `<Phoenix>\SquareEnix\FINAL FANTASY XI\`.

- **The official launcher ignores this file**, so it's safe to leave in place.
- **A launcher "repair" may delete it.** If Windower starts closing after "Resolving host" again, copy it back.

## Step 4: Create the Windower profile

In the Windower launcher, add a profile with these settings:

| Setting | Value |
| --- | --- |
| Executable | `<Phoenix>\bootloader\phoenix-loader.exe` |
| Arguments | `--server play.phoenix-xi.com --user YOURNAME --serverport 51220` |
| Password | leave empty |

- **Leave the password out.** A saved password with special characters (`@`, `!`) broke launching in testing. The loader asks for it in its console window instead.
- **`--serverport 51220`** matches what the official launcher passes to the loader.
- The official launcher logs in with a token. Windower can't use that token, so you type your password each time.

## Step 5: Load the era DATs with XIPivot

Phoenix's era menus, maps and zones come from the `EraDATs` overlay. The official launcher loads it with Ashita's pivot plugin. In Windower, the XIPivot **addon** (not a plugin) does the same job.

1. Install XIPivot into `Windower\addons\XIPivot\`, from Windower's addon list or [github.com/Shirk/XIPivot](https://github.com/Shirk/XIPivot).
2. Link the overlay instead of copying it. Then the official launcher's DAT updates reach Windower too. In Command Prompt (no admin needed):

   ```bat
   mklink /J "C:\Windower\addons\XIPivot\data\DATs\EraDATs" "D:\Games\PhoenixXI\polplugins\DATs\EraDATs"
   ```

   Change both paths to your Windower and `<Phoenix>` folders.

3. Set `Windower\addons\XIPivot\data\settings.xml` to:

   ```xml
   <?xml version="1.1" ?>
   <settings>
       <global>
           <overlays>EraDATs</overlays>
       </global>
   </settings>
   ```

4. Add `lua load xipivot` to `Windower\scripts\init.txt`, so it loads before the game reads any DATs.
5. In game, type `//pivot status`. It should list `EraDATs` as an active overlay.

## Troubleshooting

The loader's console window closes fast. To read the error, press Win+Shift+S the moment it appears, or run the loader from Command Prompt with the same arguments as Step 4.

| What you see | Cause | Fix |
| --- | --- | --- |
| "Resolving host…" then "Closing…" | No `patch.ver`, or the registry points at another server's client | Redo Step 3, then Step 2 |
| Error 3331, "FINAL FANTASY XI has been updated" | `patch.ver` reports an older version than the server accepts | Get the Phoenix `patch.ver` (Step 3). If you already have it, Phoenix raised its version (see below) |
| "Could not connect to lobby server" | The server isn't accepting logins (maintenance, or before launch) | Check the official launcher. If it gets the same message, wait |
| Login works, but menus or maps look wrong | XIPivot isn't loading `EraDATs` | Step 5: check the link, `settings.xml`, and `//pivot status` |
| Launching through Windower closes instantly with no console text | A saved password is being mangled | Clear the password field and the `--password` argument (Step 4) |
| Another server's Windower setup stopped working | Step 2 moved the registry to Phoenix | Run that server's switcher before you play it |

Windows logs crashes in Event Viewer under **Windows Logs → Application**, event ID 1000. During testing, a `phoenix-loader.exe` crash naming Windower's `Hook.dll` was just the game exiting over a missing `patch.ver`, not a Windower bug.

## How patch.ver works, and when it changes

`patch.ver` is how the client learns its own version number, which it then reports to the login server. Phoenix's server accepts version `30260904_1` or newer (Phoenix source default; the live server's setting could differ).

- **What's inside:** 288 bytes, encrypted by PlayOnline's own routine. Decrypted, it's the version string plus a small length-and-checksum trailer.
- **The key** comes from the registry value `PlayOnlineUS\Interface\0001`. That's why Step 2 sets it to `0`: one `patch.ver` then works on every PC.
- **How the file was made:** by running PlayOnline's own encrypt routine in an emulator. The method was checked by rebuilding HorizonXI's `patch.ver` byte for byte from its version string alone.

**When Phoenix raises its client version**, usually after a client update, Windower players start getting error 3331 again, while the official launcher keeps working. A new `patch.ver` with the new version fixes it. Watch this repository for an updated file.
