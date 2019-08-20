# z-RAM/SWAP Manager
## About zRAM
zRAM is a module of the Linux/Android kernel, it increases performance by avoiding disk paging and instead using a compressed block device in the physical RAM. Since using RAM is faster than using disks, zram allows the kernel to make more use of RAM when swapping/paging is required.

## Why use zRAM ?
Unlike what some myths claim zRAM does not slow down your device, neither affect battery life. It uses extremely fast algorithms that can compress/decompress large amount of data in a fraction of second. It is very useful for android by helping to keep background apps open while multitasking. It can be useful even on high RAM devices with 6-8GB RAM and in older phones it can offer a signficant performance boost.

## Changelog
*v1.3 20.08.2019*
- Unity template update 4.4
- Bug fixes

*v1.2 14.04.2019*
- Unity template update 4.0 (Magisk 19 support)

*v1.1 18.03.2019*
- Bug fixes

*v1.0 11.03.2019*
- First release

## Credits
### Author
**Omar Koulache** - [korom42](https://github.com/korom42)

### Thanks goes to those wonderful people
- ### [Unity template](https://forum.xda-developers.com/android/software/module-audio-modification-library-t3579612) & [Keycheck Method](https://forum.xda-developers.com/android/software/guide-volume-key-selection-flashable-zip-t3773410) by @ahrion & @Zackptg5 
- ### [Magisk](https://github.com/topjohnwu/Magisk) by @topjohnwu
