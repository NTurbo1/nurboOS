# NurboOS

NurboOS is an operating system built from scratch for learning and experimentation purposes. The goal of this project is to explore the inner workings of an OS, including the bootloader, kernel, and hardware interaction. This project serves as a foundation for building a more complex operating system.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Licensing Notice for GRUB Bootloader

This project uses GNU GRUB (GPL v3) to create a bootable ISO image.

If you distribute the operating system ISO image, which includes GRUB binaries, you must also make the exact GRUB source code available to comply with the GNU General Public License (GPL).

GRUB version used: **2.12**  
Source code for this version: [https://ftp.gnu.org/gnu/grub/grub-2.12.tar.gz](https://ftp.gnu.org/gnu/grub/grub-2.12.tar.gz)

If you build GRUB from source yourself, include the `.tar.gz` file with your release or link to it directly.

This notice satisfies GPL requirements for distributing GRUB as part of the ISO. Your own operating system source code is **not required** to be under the GPL.
