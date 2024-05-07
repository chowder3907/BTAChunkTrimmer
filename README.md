# BTAChunkTrimmer.sh
___
## Description
This is a basic chunk trimming program for the Better Than Adventure! Minecraft beta 1.7.3 mod. This works under Linux and is untested on MacOS/WSL, though this is only bash so there is no reason it wouldn't work.
___
## How To Use
1. Click on BTAChunkTrimmer.sh
2. In the code window's header bar, press the download to save as raw.
3. Navigate to the directory with the script in the terminal.
4. Make sure the script is executable by running `chmod +x ./BTAChunkTrimmer.sh`.
5. Run the script using `./BTAChunkTrimmer.sh`.
6. Follow the on-screen prompts.
___
## Limitations
This script does not modify region files, it only deletes them. This means that your
coordinates must be 1,536 blocks away from each other. It also does some division on the coordinates you enter, so your coordinates cannot be 0. Finally, because region files are big and I don't want to delete anyone's bases, this program deletes things non-inclusively. This means when you define your coordinates, things directly on the perimiter of the rectangle you enter will not be deleted. So this is good for deleting big groups of chunks, but you won't be able to delete individual chunks with this. For that I recommend something for editing McRegion files directly like [NBTExplorer](https://github.com/jaquadro/NBTExplorer)
