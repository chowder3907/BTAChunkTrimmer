#!/bin/bash
#PS4='+${LINENO}: '
#set -x # enable these 2 lines for debugging
#all coordinates must be 3 MCR files away, each one is 512x512 meaning coords have to be 1,536 blocks away

function userPromptYesDefault() { #outputs 0 for yes, 1 for no. yes as default
    while true; do
        read -p "$question (Y/n) : " answer
        case "$answer" in
            [Yy] )
                return 0
                ;;
            [Nn] )
                return 1
                ;;
            "" )
                return 0
                ;;
            * )
                echo "Please answer y or n"
                ;;
        esac
    done
}

function userPromptNoDefault() { #outputs 0 for yes, 1 for no. no as default
    while true; do
        read -p "$question (y/N) : " answer
        case "$answer" in
            [Yy] )
                while true; do
                read -p "Are you REALLY sure? This cannot be undone! (y/N) : " confirmation
                case "$confirmation" in
                    [Yy] )
                        return 0
                    ;;
                    [Nn] )
                        return 1
                    ;;
                    "" )
                        return 1
                    ;;
                    * )
                        echo "Please answer y or n"
                    esac
                done
                    ;;
            [Nn] )
                return 1
                ;;
            "" )
                return 1
                ;;
            * )
                echo "Please answer y or n"
                ;;
        esac
    done
}

function folderOverwritePrompt(){ #prompt the user to overwrite the directory and return their answer. usage - if folderOverwritePrompt "$someDirectory"
    local inputDir=$1
    if [ -d "$inputDir" ]; then
        question="$1 already exists. Would you like to overwrite it? THIS CANNOT BE UNDONE"
        userPromptNoDefault
        return $?
    fi

}

function folderBackup() {
    echo "Warning: If you choose to overwrite an existing folder, it will not care what the folder is. This can be harmful, type carefully and proceed at your own risk."
    echo
    read -e -p "Select Backup Location (or /home/$USER if left empty) : " backupLocation

    if [ -z "$backupLocation" ]; then
        backupLocation="/home/$USER"
    fi

    # Use eval to expand ~ in backupLocation
    backupLocation=$(eval echo "$backupLocation")

    if [ -d "$backupLocation"/"$minecraftWorldSaveDirName" ]; then
        if folderOverwritePrompt "$backupLocation"/"$minecraftWorldSaveDirName"; then
            rm -rf "$backupLocation"/"$minecraftWorldSaveDirName"
            cp -r "$minecraftWorldSaveDir" "$backupLocation/$minecraftWorldSaveDirName"
        else
            exit
        fi
    else
        cp -r "$minecraftWorldSaveDir" "$backupLocation"/"$minecraftWorldSaveDirName"
    fi
}



echo "First we're going to make a backup"

while true; do

    read -e -p "Enter minecraft world folder location or 'skip' to skip backup: " minecraftWorldSaveDir
    echo
    if [ "$minecraftWorldSaveDir" == "skip" ]; then
        break
    fi
    # Use eval to expand ~
    minecraftWorldSaveDir=$(eval echo "$minecraftWorldSaveDir")
    if [ -d "$minecraftWorldSaveDir" ]; then
        break
    else
        echo "Error: That is not a valid directory. Please enter a valid directory." #maybe let the user type exit here
        read -p "Press enter to continue or type 'exit' to exit" folderLocationLoopExitCheck
    fi
    if [ "$folderLocationLoopExitCheck" == "exit" ]; then
        exit
    else
        continue
    fi
done


if [ "$minecraftWorldSaveDir" != "skip" ]; then
    minecraftWorldSaveDirName=$(basename "$minecraftWorldSaveDir")
    folderBackup
fi

if [ "$minecraftWorldSaveDir" == "skip" ]; then #for if users put skip in the backup step
    question="You did not back up your files. Are you sure you want to proceed? This can cause irreperable damage to your world!"
    if userPromptNoDefault; then
        :
    else
        exit
    fi
    while true; do

        read -e -p "Enter minecraft world folder location: " minecraftWorldSaveDir
        minecraftWorldSaveDir=$(eval echo "$minecraftWorldSaveDir")
        minecraftWorldSaveDirName=$(basename "$minecraftWorldSaveDir")
        echo
        if [ -d "$minecraftWorldSaveDir" ]; then
            break
        else
            echo "Error: That is not a valid directory. Please enter a valid directory."
            read -p "Press enter to retry or type 'exit' to exit" backupSkipExitCheck
        fi
        if [[ "$backupSkipExitCheck" == "exit" ]]; then
            exit
        else
            continue
        fi
    done
fi

function dimensionCheck() {
    while true; do
    read -p "Which dimension? overworld, nether, or paradise : " dimensionAnswer
        case $dimensionAnswer in
            [Oo][Vv][Ee][Rr][Ww][Oo][Rr][Ll][Dd])
                return 0
                ;;
            [Nn][Ee][Tt][Hh][Ee][Rr])
                return 1
                ;;
            [Pp][Aa][Rr][Aa][Dd][Ii][Ss][Ee])
                return 2
                ;;
            *)
                echo "Please input a valid dimension."
                ;;
        esac
    done
}
#Add check for BTA, and then ask which dimensions we're deleting
#for bta, overworld is 0, nether is 1, paradise is 2
clear
dimensionCheck
dimensionsFolderNumber=$?


echo "Now we are going to figure out which chunks you want deleted."
echo
echo "Select two XZ coordinates on the corners of the chunks you want deleted."
echo
echo "The chunks you select will not be deleted, but they will form the outside of a rectangle that WILL be deleted."
echo
echo
read -p "Press enter once you have your two sets of coordinates to continue"

while true; do

    echo
    read -p "What is the first X coordinate? Whole numbers only! : " userXCoord1
    read -p "What is the first Z coordinate? Whole numbers only! : " userZCoord1
    read -p "What is the second X coordinate? Whole numbers only! : " userXCoord2
    read -p "What is the second Z coordinate? Whole numbers only! : " userZCoord2

    # Input Validation brought to you by chatgpt, love that thing
    if ! [[ $userXCoord1 =~ ^-?[0-9]+$ && $userZCoord1 =~ ^-?[0-9]+$ && $userXCoord2 =~ ^-?[0-9]+$ && $userZCoord2 =~ ^-?[0-9]+$ ]]; then
    echo "Error: Please enter whole numbers only."
    continue
    fi


    # Check for divide by zero
    if [[ $userXCoord1 -eq 0 || $userZCoord1 -eq 0 || $userXCoord2 -eq 0 || $userZCoord2 -eq 0 ]]; then
        echo "Error: Coordinates cannot be zero."
        continue
    fi

    chunkXCoord1=$((userXCoord1 >= 0 ? userXCoord1 / 16 : (userXCoord1 - 15) / 16))
    chunkZCoord1=$((userZCoord1 >= 0 ? userZCoord1 / 16 : (userZCoord1 - 15) / 16))
    chunkXCoord2=$((userXCoord2 >= 0 ? userXCoord2 / 16 : (userXCoord2 - 15) / 16))
    chunkZCoord2=$((userZCoord2 >= 0 ? userZCoord2 / 16 : (userZCoord2 - 15) / 16))


    mcrX1=$((chunkXCoord1 >> 5))
    mcrZ1=$((chunkZCoord1 >> 5))
    mcrX2=$((chunkXCoord2 >> 5))
    mcrZ2=$((chunkZCoord2 >> 5))

    # Calculate the absolute differences
    abs_diff_x=$((mcrX1 - mcrX2))
    abs_diff_z=$((mcrZ1 - mcrZ2))
    abs_diff_x_abs=${abs_diff_x#-}
    abs_diff_z_abs=${abs_diff_z#-}

    # Check if absolute differences are less than or equal to 2
    if (( abs_diff_x_abs <= 2 )) || (( abs_diff_z_abs <= 2 )); then
        echo
        echo "Chunks are too close together. Try selecting coordinates farther apart."
        if (( abs_diff_x_abs <= 2 )); then
            echo "Error: Your X coordinates are too close together"
        fi
        if (( abs_diff_z_abs <= 2 )); then
            echo "Error: Your Z coordinates are too close together"
        fi
        read -p "Press enter to input new coordinates or type 'exit' to exit the program. : " coordCalcExitCheck
        if [ "$coordCalcExitCheck" == "exit" ]; then
            exit
        else
            continue
        fi
    else
        break
    fi

done

#calculating inside square corner boundaries: MCA if x1 smaller than x2, add one to x1 and subtract one from x2 or vice versa.
#same with z coords
if ((mcrX1 < mcrX2)); then
    mcrX1=$(( mcrX1 + 1 ))
    mcrX2=$(( mcrX2 - 1 ))
else
    mcrX2=$(( mcrX2 - 1 ))
    mcrX1=$(( mcrX1 + 1 ))
fi

if ((mcrZ1 < mcrZ2)); then
    mcrZ1=$(( mcrZ1 + 1 ))
    mcrZ2=$(( mcrZ2 - 1 ))
else
    mcrZ2=$(( mcrZ2 - 1 ))
    mcrZ1=$(( mcrZ1 + 1 ))
fi

#using seq or something, make list of MCRs to be deleted. I'm thinking one array of X coords and one array of matching Y coords

if ((mcrX1 < mcrX2)); then
    mcrXArray=($(seq $mcrX1 1 $mcrX2))
else
    mcrXArray=($(seq $mcrX1 -1 $mcrX2))
fi

if ((mcrZ1 < mcrZ2)); then
    mcrZArray=($(seq $mcrZ1 1 $mcrZ2))
else
    mcrZArray=($(seq $mcrZ1 -1 $mcrZ2))
fi

echo "Deleting chunks! This may take a moment"
for xcoord in "${mcrXArray[@]}"; do
    for ycoord in "${mcrZArray[@]}"; do
        #echo "deleting $minecraftWorldSaveDir/dimensions/$dimensionsFolderNumber/region/r.$xcoord.$ycoord.mcr"
        rm -rf "$minecraftWorldSaveDir/dimensions/$dimensionsFolderNumber/region/r.$xcoord.$ycoord.mcr"
    done
done
echo
echo "Done!"
