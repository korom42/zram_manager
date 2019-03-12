# z-RAM/SWAP Manager
## What is zRAM ?
ZRAM is a module of the Linux/Android kernel, it increases performance by avoiding disk paging and instead using a compressed block device in the physical RAM. Since using RAM is faster than using disks, zram allows the kernel to make more use of RAM when swapping/paging is required.

## Why use zRAM ?
zRAM doesn't slow down your device and it doesn't affect battery life. It uses extremely fast alghortims that can compress & decompress data in a fraction of second.
zRAM is very useful for android it allow keeping your apps open while multitasking. It can be useful even on high RAM devices with 6-8GB RAM and on older phones it can offer a signficant performance boost.

## Changelog

*v1.0 11.03.2019*
- First release

## Credits
### Author
**Omar Koulache** - [korom42](https://github.com/korom42)

### Thanks goes to those wonderful people
- ### [Unity template](https://forum.xda-developers.com/android/software/module-audio-modification-library-t3579612) & [Keycheck Method](https://forum.xda-developers.com/android/software/guide-volume-key-selection-flashable-zip-t3773410) by @ahrion & @Zackptg5 
- ### [Magisk](https://github.com/topjohnwu/Magisk) by @topjohnwu
