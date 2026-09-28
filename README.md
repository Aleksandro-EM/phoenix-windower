# Windower on Phoenix FFXI

How to launch Phoenix through Windower 4.

> **Unsupported.** Phoenix staff don't support Windower, so don't take Windower problems to them. Addons and plugins are allowlist-only: check [phoenix-xi.com/approved-addons](https://phoenix-xi.com/approved-addons) before you load anything.

You need:

- Phoenix installed with the official launcher
- Windower 4
- Admin rights on your PC

In this guide, **`<Phoenix>`** means your Phoenix install folder, the one containing `bootloader`, `polplugins` and `SquareEnix` (for example `D:\Games\PhoenixXI`).

## Step 1: Run Phoenix once

Install Phoenix with the official launcher and start the game once so it finishes downloading. Keep the official launcher installed; it's how you get updates.

## Step 2: Run the switch script

1. Copy [`Switch_Phoenix.bat`](Switch_Phoenix.bat) into `<Phoenix>\SquareEnix\`.
2. Right-click it and choose **Run as administrator**.

This tells Windows to use the Phoenix client. If you also play another server through Windower (such as HorizonXI), run that server's switch script before playing it, and run this one again when you come back.

## Step 3: Add patch.ver

Copy [`patch.ver`](patch.ver) into `<Phoenix>\SquareEnix\FINAL FANTASY XI\`.

The official launcher ignores this file, so it's safe to leave there. If a launcher repair deletes it, copy it back.

## Step 4: Create the Windower profile

In the Windower launcher, add a profile:

| Setting | Value |
| --- | --- |
| Executable | `<Phoenix>\bootloader\phoenix-loader.exe` |
| Arguments | `--server play.phoenix-xi.com --user YOURNAME` |
| Password | leave empty |

Replace `YOURNAME` with your Phoenix username. Leave the password empty; you'll type it in the console window when you launch.

> **Don't add `--serverport`.** Earlier versions of this guide included `--serverport 51220`. After a Phoenix change, the game no longer launches with it. If your profile has it, delete it.

## Step 5: Set up XIPivot

Phoenix needs its era DATs (menus, maps, zones). The XIPivot addon loads them.

1. Install the XIPivot addon from Windower's addon list.
2. Open Command Prompt and link the DATs (change both paths to your own folders):

   ```bat
   mklink /J "C:\Windower\addons\XIPivot\data\DATs\EraDATs" "D:\Games\PhoenixXI\polplugins\DATs\EraDATs"
   ```

3. Replace the contents of `Windower\addons\XIPivot\data\settings.xml` with:

   ```xml
   <?xml version="1.1" ?>
   <settings>
       <global>
           <overlays>EraDATs</overlays>
       </global>
   </settings>
   ```

4. Add this line to `Windower\scripts\init.txt`:

   ```
   lua load xipivot
   ```

Launch the profile. In game, `//pivot status` should list `EraDATs`.

## Troubleshooting

| Problem | Fix |
| --- | --- |
| Game closes after "Resolving host" | Redo Step 3, then Step 2 |
| Error 3331, "FINAL FANTASY XI has been updated" | Get the latest `patch.ver` from this repository (Step 3) |
| "Could not connect to lobby server" | The server is down. Check the official launcher |
| Menus or maps look wrong | Redo Step 5 |
| Game doesn't launch | Remove `--serverport 51220` from the profile's arguments (Step 4) |
| Windower closes instantly | Clear the password field in the profile (Step 4) |
| Another server's Windower setup broke | Run that server's switch script |

If error 3331 comes back after a Phoenix update, Phoenix raised its client version. Watch this repository for a new `patch.ver`.

<details>
<summary>How it works (for the curious)</summary>

The official launcher runs the game inside Ashita's sandbox, which supplies registry settings and skips a client version check. Outside it, you provide both yourself.

- **Switch script:** sets the FFXI and PlayOnline install paths under `HKLM\SOFTWARE\WOW6432Node\PlayOnlineUS`, sets `Interface\0001` to `0`, and registers the game's and PlayOnline's COM DLLs from the Phoenix install. It's based on HorizonXI's `Switch_Horizon.bat`. The PlayOnline DLL lines haven't been tested on a clean PC.
- **patch.ver:** tells the client its version, which it reports to the login server. Phoenix ships none, and another server's copy reports the wrong version (error 3331). This one reports `30260904_1`, the minimum in Phoenix's source (`settings/default/login.lua`). It's encrypted with a key from `Interface\0001`, which is why the script sets that to `0`. It was built by running PlayOnline's own encrypt routine in an emulator, a method checked by rebuilding HorizonXI's `patch.ver` byte for byte. SHA-256: `9DFBA3A0F4109225F2C280B0BFF69E9199E0B034AAD6626324DB787E90607620`.
- **Password:** a saved password with special characters (`@`, `!`) broke launching in testing, so the loader asks for it instead.
- **XIPivot:** does the job of Ashita's pivot plugin. The junction means the official launcher's DAT updates reach Windower too.
- **Tested** on Windows 10 with `phoenix-loader` 2.1.1.0, on the live server on launch day (Sep 24 2026).

</details>
