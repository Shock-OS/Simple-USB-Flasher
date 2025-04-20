## Simple USB Flasher

Finally, a simple Linux app that flashes a wide variety of bootable image formats to block devices such as USB drives, external HDDs and SSDs, and SD cards. It is designed to be straightforward and "just work". It exists as a GUI app and a CLI tool.

Simply download and install the .deb package. It should work on most modern Debian/Ubuntu-based systems, and is tested and working on Linux Mint 22.1. The program currently only comes in .deb format, though it can easily be ported to other distros/Flatpak for those interested in contributing towards that.

## Disclaimer

This program has rigorous built-in safeguards to prevent flashing the computer's internal hard drive. It also displays a warning before flashing/erasing a device with an option to cancel. However, this program comes with <b>ABSOLUTELY NO WARRANTY</b>, and I am not responsible for unwanted data loss. The program is designed to only identify anything mounted under `/media` or `/mnt` as a removable storage device. If you have any internal/external drives with important data mounted as external storage volumes in these locations, the program may recognize them as a USB stick, so be careful not to select them. <b>YOU HAVE BEEN WARNED!</b>

## Installation

### Debian/Ubuntu/Mint and derivatives:

Simply grab the latest .deb release from the side pane on the right, and install it using:

`$ sudo apt install [PATH_TO_DEB_FILE]`

For example, if you downloaded the .deb to the Downloads folder:

`$ sudo apt install ~/Downloads/simple-usb-flasher-1.3-all.deb`

## Usage

### GUI (Python GTK+ App):

Simply launch Simple USB Flasher from the applications menu, or run the following command in a terminal window:

`$ simple-usb-flasher`

Or, for more verbose output:

`$ simple-usb-flasher --verbose`

### CLI (Bash script)

Simple USB Flasher also has a CLI tool: `simple-usb-flasher-cli`. In fact, the backend of the program is a collection of Bash scripts (the Python GTK+ app also uses these script under the hood). The usage for `simple-usb-flasher-cli` is as follows:

<pre>simple-usb-flasher-cli: [ACTIONS] [PARAMETERS] [OPTIONS]

ACTIONS:
    erase [DEVICE]                      Erase [DEVICE] to use it as a normal storage device again. Formats to exFAT by default, but can be used with --ask-method to select a filesystem. 
    flash [PATH_TO_IMAGE] [DEVICE]      Flash image [PATH_TO_IMAGE] to [DEVICE]. 
    list-devices                        List available external USB drives, SD cards, or USB SSDs/HDDs that can be flashed 
    list-supported-file-types           Show a list of file types supported for flashing 

FLASH OPTIONS:
    --ask-method              If multiple decompression methods are available for an image type, prompt the user for which one to use. If this options is not applied, the default option will be used. 
    --skip-size-check         Don't check to see if image will fit on device, attempt flashing anyway. 
    --skip-size-check-smart   Same as '--skip-size-check', but only skips checking size if it 'may take a while'. 

OTHER OPTIONS:
    --verbose            Increase output verbosity</pre>

To print this screen in ther terminal, you can also run:

`$ simple-usb-flasher-cli --help`, or simply `$ simple-usb-flasher-cli` with no arguments.

## Known Issues

### Flash failed, device can no longer be mounted

Simple USB Flasher allows the option to flash an image even when it detects that doing so probably won't work, such as when the image is too big for the target device, or the image does not appear to be a bootable one. This option is available in the hope that some unconventional OS images can still be flashed, but it has a downside. Sometimes, the flashing will fail in a way that leaves the target devices with no partitions. This causes the device to not mount when it is plugged in to the computer.

Luckily, the fix is simple, but it requires another software: GParted. It is widely available on most Linux distros and can be installed on Debian/Ubuntu based distros with:

`$ sudo apt install gparted`

Once installed, open GParted, navigate to the target device, navigate to `Device` > `Create Partition Table...` from the top menu bar, and use either `msdos` or `gpt`. Then, go to `Partition` > `New` and create a partition with the `fat32`, `exfat`, or `ntfs` filesystem.

That's it! Exit GParted and your device should now mount properly (you may have to unplug it and plug it back in).

