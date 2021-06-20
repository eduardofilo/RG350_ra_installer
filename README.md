![Icon](images/icon_big.png)

In December, official RetroArch distributions for RG350 and RG280 began to appear. At the moment they are beta versions in the form of nightly builds that can be obtained from [this site](https://buildbot.libretro.com/nightly/dingux/mips32/) for stock/ROGUE or [this other](https://buildbot.libretro.com/nightly/dingux/mips32-odbeta/) for [ODBeta](http://od.abstraction.se/opendingux/latest/).

The zip files that they distribute contain a single OPK, a binary (optional) and a directory (with all the configuration and cores) to be copied to the home of the console:

![Files](images/files.png)

Once everything is in place, the only way to run the ROMs with the cores included in the distribution is through the only OPK that launches RetroArch as frontend (UX mode, like it is known in other emulators):

![Frontend](images/frontend.png)

To achieve a more complete integration of RetroArch, respecting the normal experience of the usual frontends in RG350 / RG280 (GMenu2X, SimpleMenu, PyMenu, EmulationStation, etc.), wrapper-type OPKs can be created that allow selecting the ROMs and launching the corresponding RetroArch core, since the optional binary supports the same arguments as RetroArch on other platforms.

## OPK wrappers

To achieve this, it was first necessary to figure out how to parameterize the core and the ROM. Loading a core and a ROM from RetroArch itself does not work because it does not externalize this data as arguments on the executable. So I assumed that the same argument format used by the `retroarch_rg350` binary (inside `bin` directory; in ODBeta distribution, the binary is `retroarch_rg350_odbeta`) would serve on other systems like EmuELEC on RG351P. In this console the usual EmulationStation frontend does parameterize the core and the ROM to be executed by means of arguments in the call. For example, running Tetris on Game Boy with the core gambatte in EmuELEC on RG3551P, the process is invoked in this way:

```
/usr/bin/retroarch -v -L /tmp/cores/gambatte_libretro.so --config /storage/.config/retroarch/retroarch.cfg /storage/roms/gb/Tetris (World) (Rev A).7z
```

Therefore, the idea is, first, to install the `retroarch_rg350` optional binary in an accessible path (`/media/data/local/bin` is chosen), and then build different OPKs that invoke a script whith the ROM to be executed as argument. Inside the script we can mount the complete call to the `retroarch_rg350`. For example for the Game Boy system the script could be the following:

```bash
#!/bin/sh
/media/data/local/bin/retroarch_rg350 -v -L /media/data/local/home/.retroarch/cores/gambatte_libretro.so --config /media/data/local/home/.retroarch/retroarch.cfg "$1"
```

We put the previous script together with an appropriate icon for the system that is going to launch and a `.desktop` that invokes the script passing the ROM as an argument, for example:

```
[Desktop Entry]
Name=Nintendo GB (RA)
Comment=Nintendo GB in RetroArch
Exec=exec.sh %f
Terminal=false
Type=Application
StartupNotify=true
Icon=icon
Categories=retroarch;
X-OD-NeedsDownscaling=true
```

This are the cores offered by the latest version of RetroArch released at the time of writing (2021-06-18):

|Core|System|Supported extensions|Observations|
|:---|:-----|:-------------------|:-----------|
|fbalpha2012_cps1_libretro.so|CPS1|zip| |
|fbalpha2012_cps2_libretro.so|CPS2|zip| |
|fbalpha2012_neogeo_libretro.so|Neo Geo|zip| |
|fceumm_libretro.so|NES|fds, nes, unif, unf|Disk System need BIOS: `disksys.rom` (md5: `ca30b50f880eb660a320674ed365ef7a`)|
|gambatte_libretro.so|GB/GBC|gb, gbc, dmg|Optional BIOS: `gb_bios.bin` (md5: `32fbbd84168d3482956eb3c5051637f5`), `gbc_bios.bin` (md5: `dbfce9db9deaa2567f6a84fde55f9680`)|
|genesis_plus_gx_libretro.so|MD, MS, GG, SEGA CD|mdx, md, smd, gen, bin, cue, iso, sms, bms, gg, sg, 68k, chd, m3u|SEGA CD need BIOS: `bios_CD_E.bin`, `bios_CD_U.bin`, `bios_CD_J.bin`|
|genesis_plus_gx_wide_libretro.so|MD, MS, GG, SEGA CD|mdx, md, smd, gen, bin, cue, iso, sms, bms, gg, sg, 68k, chd, m3u|SEGA CD need BIOS: `bios_CD_E.bin`, `bios_CD_U.bin`, `bios_CD_J.bin`|
|gpsp_libretro.so|GBA|gba, bin|Optional BIOS: `gba_bios.bin` (md5: `a860e8c0b6d573d191e4ec7db1b1e4f6`)|
|handy_libretro.so|LYNX|lnx, o|Need BIOS: `lynxboot.img` (md5: `fcd403db69f54290b51035d82f835e7b`)|
|mednafen_pce_fast_libretro.so|PCE, PCE CD|pce, cue, ccd, chd, toc, m3u|PCE CD need BIOS: `syscard3.pce` (md5: `38179df8f4ac870017db21ebcbf53114`)|
|mednafen_wswan_libretro.so|WS|ws, wsc, pc2| |
|mgba_libretro.so|GBA|gb, gbc, gba|Optional BIOS: `gba_bios.bin` (md5: `a860e8c0b6d573d191e4ec7db1b1e4f6`)|
|mrboom_libretro.so|MrBoom| | |
|picodrive_libretro.so|MD, MS, SEGA CD, SEGA 32X|bin, gen, smd, md, 32x, chd, cue, iso, sms, 68k, m3u|SEGA CD need BIOS: `bios_CD_U.bin` (md5: `2efd74e3232ff260e371b99f84024f7f`), `bios_CD_E.bin` (md5: `e66fa1dc5820d254611fdcdba0662372`), `bios_CD_J.bin` (md5: `278a9397d192149e84e820ac621a8edd`)|
|pokemini_libretro.so|POKEMINI|min|Need BIOS: `bios.min` (md5: `1e4fb124a3a886865acb574f388c803d`)|
|prboom_libretro.so|DOOM|wad, iwad, pwad|Need game files|
|quicknes_libretro.so|NES|nes| |
|race_libretro.so|NGP|ngp, ngc, ngpc, npc| |
|snes9x2005_libretro.so|SNES|smc, fig, sfc, gd3, gd7, dx2, bsx, swc| |
|snes9x2005_plus_libretro.so|SNES|smc, fig, sfc, gd3, gd7, dx2, bsx, swc| |
|tyrquake_libretro.so|QUAKE|pak|Need game files|
|vice_x64_libretro.so|C64|d64, d71, d80, d81, d82, g64, g41, x64, t64, tap, prg, p00, crt, bin, zip, gz, d6z, d7z, d8z, g6z, g4z, x6z, cmd, m3u, vfl, vsf, nib, nbz, d2m, d4m| |
|stella2014_libretro.so|Atari 2600|a26, bin| |
|prosystem_libretro.so|Atari 7800|a78, bin|Optional BIOS: `7800 BIOS (U).rom` (md5: `0763f1ffb006ddbe32e52d497ee848ae`)|
|scummvm_libretro.so|ScummVM|<see file in core_info>| |
|tic80_libretro.so|TIC-80|tic| |
|potator_libretro.so|Watara Supervision|bin, sv| |
|dosbox_pure_libretro.so|DOSBox|zip, dosz, exe, com, bat, iso, cue, ins, img, ima, vhd, m3u, m3u8| |
|o2em_libretro.so|Magnavox Odyssey2, Phillips Videopac+|bin|Need BIOS: `o2rom.bin` (md5: `562d5ebf9e030a40d6fabfc2f33139fd`)|
|mame2003_libretro.so|MAME2003|zip| |
|mame2003_plus_libretro.so|MAME2003|zip| |

Additionally, the compilation of unofficial cores made by [Poligraf](https://github.com/Poligraf/opendingux_ra_cores_unofficial) is included (**WARNING**: this compilation is an experiment by its author; some cores like `hatari` and `puae` have not been tested; feedback is welcome). This involves adding the following cores to the former list:

|Core|System|Supported extensions|Observations|
|:---|:-----|:-------------------|:-----------|
|81_libretro.so|Sinclair ZX81|p, tzx, t81| |
|bk_libretro.so|Elektronika - BK-0010/BK-0011|bin|Need BIOS: `bk/BASIC10.ROM` (md5: `3fa774326d75410a065659aea80252f0`), `bk/FOCAL10.ROM` (md5: `5737f972e8638831ab71e9139abae052`), `bk/MONIT10.ROM` (md5: `95f8c41c6abf7640e35a6a03cecebd01`)|
|cannonball_libretro.so|SEGA Outrun|game, 88|Need game files and a dummy file with the extension `.game`|
|cap32_libretro.so|Amstrad CPC|dsk, sna, zip, tap, cdt, voc, cpr, m3u| |
|freechaf_libretro.so|Fairchild ChannelF|bin, chf|Need BIOS: `sl31253.bin` (md5: `ac9804d4c0e9d07e33472e3726ed15c3`), `sl31254.bin` (md5: `da98f4bb3242ab80d76629021bb27585`), `sl90025.bin` (md5: `95d339631d867c8f1d15a5f2ec26069d`)|
|fuse_libretro.so|Sinclair ZX Spectrum|tzx, tap, z80, rzx, scl, trd, dsk| |
|gme_libretro.so|Game Music Emu|ay, gbs, gym, hes, kss, nsf, nsfe, sap, spc, vgm, vgz, zip| |
|hatari_libretro.so|Atari ST|st, msa, zip, stx, dim, ipf, m3u|Need BIOS: `tos.img` (md5: `c1c57ce48e8ee4135885cee9e63a68a2`). Difficult configuration. Achieved some success with RG350M, but not with RG350P|
|mednafen_vb_libretro.so|Nintendo Virtual Boy|vb, vboy, bin|Poor performance|
|nxengine_libretro.so|Cave Story|exe|Need game files|
|puae_libretro.so|Commodore Amiga|adf, adz, dms, fdi, ipf, hdf, hdz, lha, slave, info, cue, ccd, nrg, mds, iso, chd, uae, m3u, zip, 7z|Need BIOS: `kick34005.A500` (md5: `82a21c1890cae844b3df741f2762d48d`)|
|reminiscence_libretro.so|Flashback|map, aba, seq, lev|Need game files|
|theodore_libretro.so|Thomson - MO/TO|fd, sap, k7, m7, m5, rom|Difficult configuration. Achieved some success with MO5 model in ODBeta with RG350M, but not in stock/ROGUE|
|uzem_libretro.so|Uzebox|uze|Poor performance|

Therefore, we have to make one OPK at least for each of them. We say *at least* because the option of making an OPK for each "core/system to emulate" combination can be considered.

## Installer

As there are several pieces necessary for the set to work, an installer has been created to install everything you need in one go. Specifically, the installer integrates this items:

* 37+14 (official+unofficial) OPKs to launch the different core/system combinations independently from different frontends (GMenu2X, SimpleMenu, PyMenu, EmulationStation, etc.) by previously selecting the ROM (Explorer mode).
* Binary `retroarch_rg350` (or `retroarch_rg350_odbeta` for ODBeta) in common location (`/media/data/local/bin`) to be invoked by former OPKs to not be cloned inside them.
* Configurations for all the cores differentiated by screen, that is, adequate configurations for 320x240 or 640x480 are installed depending on the screen detected. The settings have been adopted from the Retro Game Corps recommendations in [this guide](https://retrogamecorps.com/2020/12/24/guide-retroarch-on-rg350-and-rg280-devices/).
* GMenu2X filters by extension for each system (including `7z` in all systems).
* New section with the RetroArch icon in all the skins installed in GMenu2X where all the OPK launchers appear.

When launched, it ask for two options that are disabled by default:

![Installing options](images/installing_options.png)

* Install config: To install the configurations refered in third spot in last list. The recommendation is to install the configurations the first time and not install them in subsequent installations to avoid losing the settings made on it.
* Install unofficial cores: To install the 14 new but unofficial cores of [Poligraf](https://github.com/Poligraf/opendingux_ra_cores_unofficial).

The OPK with the installer can be obtained in the releases of [this repository](https://github.com/eduardofilo/RG350_ra_installer/releases/latest).

## Hoykeys

In RetroArch configuration file the following hotkeys have been defined.

|Function|Shortcut|
|:-------|:-------|
|Pause|`Select + A`|
|Reset|`Select + B`|
|RetroArch Menu|`Select + X`|
|Fast forward|`Select + Y`|
|Savestate save|`Select + R1`|
|Savestate load|`Select + L1`|
|Swap disk|`Select + R2`|
|Open CD tray|`Select + L2`|
|Close content|`Select + Start`|
|Savestate slot changing|`Select + ←→`|
|Volume changing|`Select + ↑↓`|

## Telegram channel

Join this Telegram channel to get update notifications: [https://t.me/RG350_ra_installer](https://t.me/RG350_ra_installer)
