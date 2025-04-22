#!/bin/bash

#VARIABLE DECLARATION

BACKUP=$(pwd)/ModBackup
LOG=$(pwd)/DataCleanerLog.txt
PROTON="$HOME/.steam/steam/steamapps/common/Proton - Experimental/proton"
TITLE="\033[1;33mSoufants Wreckfest 2 Mod Handler"
ERROR="\033[0;31m"
SUCCESS="\033[0;32m"
RESET="\033[0m"


#FUNCTION DECLARATION

# Prerun checks to ensure the script is run in the correct environment
prerun_checks() {
    echo -e "Prerun Checks in Progress...\n"
    # Check if in Wreckfest2 root directory
    if [ ! -f "Wreckfest2.exe" ]; then
        echo -e "${ERROR}Error: Wreckfest2.exe not found.${RESET}\nPlease run this in the Wreckfest 2 directory."
        echo -e "\nPress Enter to exit."
        read
        clear
        exit 1
    # Check if DataCleaner.exe exists
    elif [ ! -f "DataCleaner.exe" ]; then
        echo -e "${ERROR}Error: DataCleaner.exe not found.${RESET}\nPlease validate your game installation."
        echo -e "\nPress Enter to exit."
        read
        clear
        exit 1
    # Check if Proton is installed
    elif [ ! -f "$PROTON" ]; then
        echo -e "${ERROR}Error: Proton Experimental not found.${RESET}\nPlease install Proton Experimental via Steam and try again."
        echo -e "\nPress Enter to exit."
        read
        clear
        exit 1
    else
        echo -e "${SUCCESS}Prerun Checks Passed!${RESET}"
        sleep 1
    fi
}

# Run DataCleaner and write to log
run_datacleaner() {
    # Run DataCleaner with Proton
    STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.steam/steam" \
    STEAM_COMPAT_DATA_PATH="$(mktemp -d)" \
    "$PROTON" run ./DataCleaner.exe
    # Convert path to Unix format and write to .tmp
    grep "Would Deleted:  " "$LOG" | cut -c17- | sed -e 's/\\/\//g' -e 's/^/.\//' -e 's/\r$/\n/' > "$LOG.tmp" 2>/dev/null
}

# Postrun cleanup to remove unneeded files
postrun_cleanup() {
    # Remove DataCleaner logs
    rm -f "$LOG" "$LOG.tmp"
    clear
    exit 0
}

# Backup mod files to a directory
backup_dir() {
    # Read each line from .tmp
    while IFS= read -r line; do
        # Remove Newline characters
        line=$(echo "$line")
        # Create the backup directory structure
        DIR_PATH=$(dirname "$line")
        DEST_PATH="$BACKUP/$DIR_PATH"
        mkdir -p "$DEST_PATH"
        # Move the file to the backup directory
        mv "$line" "$DEST_PATH"
    done < "$LOG.tmp"
}

# Backup mod files to a tar file
backup_tar() {
    tar -cf ModBackup.tar -T "$LOG.tmp"
    delete
}

# Backup mod files to a tar.gz file
backup_targz() {
    tar -czf ModBackup.tar.gz -T "$LOG.tmp"
    delete
}

# Delete mod files
delete() {
    # Read each line from .tmp
    while IFS= read -r line; do
        # Remove Newline characters
        line=$(echo "$line")
        # Remove the file
        rm -f "$line"
    done < "$LOG.tmp"
}

# Restore mod files from a directory
restore_dir() {
    # Move data directory from ModBackup to parent directory
    cp -r "$BACKUP"/* ./
    # Remove backup directory
    rm -rf "$BACKUP"
}

# Restore mod files from a tar file
restore_tar() {
    # Extract the tar file
    tar -xf ModBackup.tar
    # Remove the tar file
    rm -f ModBackup.tar
}

# Restore mod files from a tar.gz file
restore_targz() {
    # Extract the tar.gz file
    tar -xzf ModBackup.tar.gz
    # Remove the tar.gz file
    rm -f ModBackup.tar.gz
}



#USER INTERFACE

# Welcome Message
clear
echo -e "$TITLE${RESET}\n"
echo -e "Welcome to Soufants Wreckfest 2 Mod Handler!\n"
echo -e "Press Enter to continue or Ctrl+C to cancel."
read

clear
echo -e "$TITLE${RESET}\n"
prerun_checks

clear
echo -e "$TITLE${RESET}\n"
echo -e "Do you want to remove mods or restore mods?\n"
echo -e "1. Remove mods from Wreckfest 2"
echo -e "2. Restore mods to Wreckfest 2"
read -p "Enter your choice (1-2): " mode_choice

clear
if [[ "$mode_choice" -eq 1 ]]; then
    echo -e "$TITLE > Remove Mods${RESET}\n"
    echo -e "Do you want to backup to a directory, tarball, or delete?\n"
    echo -e "1. Backup to directory"
    echo -e "2. Backup to tarball"
    echo -e "3. Delete mods"
    read -p "Enter your choice (1-3): " backup_choice
    if [[ "$backup_choice" -eq 1 ]]; then
        clear
        echo -e "$TITLE > Backup to Directory${RESET}\n"
        echo -e "Backing up mods to directory..."
        run_datacleaner
        backup_dir
        echo -e "${SUCCESS}Backup completed!${RESET}"
        echo -e "\nBackup directory created at $BACKUP"
        echo -e "\nPress Enter to exit."
        read
    elif [[ "$backup_choice" -eq 2 ]]; then
        clear
        echo -e "$TITLE > Backup to Tarball${RESET}\n"
        echo -e "Do you want to backup to tar or tar.gz?"
        echo -e "1. Backup to tar"
        echo -e "2. Backup to tar.gz"
        read -p "Enter your choice (1-2): " tar_choice
        if [[ "$tar_choice" -eq 1 ]]; then
            clear
            echo -e "$TITLE > Backup to tar${RESET}\n"
            echo -e "Backing up mods to tar..."
            run_datacleaner
            backup_tar
            echo -e "${SUCCESS}Backup completed!${RESET}"
            echo -e "\nBackup tarball created at $BACKUP.tar"
            echo -e "\nPress Enter to exit."
            read
            
        elif [[ "$tar_choice" -eq 2 ]]; then
            clear
            echo -e "$TITLE > Backup to tar.gz${RESET}\n"
            echo -e "Backing up mods to tar.gz..."
            run_datacleaner
            backup_targz
            echo -e "${SUCCESS}Backup completed!${RESET}"
            echo -e "\nBackup tarball created at $BACKUP.tar.gz"
            echo -e "\nPress Enter to exit."
            read
        else
            echo -e "${ERROR}Invalid choice, press Enter to exit.${RESET}"
            read
            clear
            exit 1
        fi
    elif [[ "$backup_choice" -eq 3 ]]; then
        clear
        echo -e "$TITLE > Delete Mods${RESET}\n"
        echo -e "Are you sure you want to delete all mods?\nPlease type 'delete' to confirm."
        read -p "" confirm_delete
        if [[ "$confirm_delete" != "delete" ]]; then
            echo -e "${ERROR}Invalid confirmation, press Enter to exit.${RESET}"
            read
            clear
            exit 1
        fi
        echo -e "Deleting mods..."
        run_datacleaner
        delete
        echo -e "${SUCCESS}Mods deleted!${RESET}"
        echo -e "\nPress Enter to exit."
        read
    else
        echo -e "${ERROR}Invalid choice, press Enter to exit.${RESET}"
        read
        clear
        exit 1
    fi
    echo -e "$TITLE > Validate Steam Files${RESET}\n"
    echo -e "Do you want to validate the Steam files?\nUseful if your mods overwrote original game files."
    echo -e "1. Yes"
    echo -e "2. No"
    read -p "Enter your choice (1-2): " validate_choice
    if [[ "$validate_choice" -eq 1 ]]; then
        clear
        echo -e "$TITLE > Validate Steam Files${RESET}\n"
        echo -e "Validating Steam files..."
        xdg-open "steam://validate/1203190" &>/dev/null
        echo -e "${SUCCESS}Validation started!${RESET}"
        echo -e "Check your Steam client for progress."
        echo -e "\nPress Enter to exit."
        read
    else
        echo -e "${SUCCESS}Skipping validation.${RESET}"
    fi

elif [[ "$mode_choice" -eq 2 ]]; then
    echo -e "$TITLE > Restore Mods${RESET}\n"
    echo -e "Do you want to restore from a directory or tarball?\n"
    echo -e "1. Restore from directory"
    echo -e "2. Restore from tarball"
    read -p "Enter your choice (1-2): " restore_choice
    if [[ "$restore_choice" -eq 1 ]]; then
        clear
        echo -e "$TITLE > Restore from Directory${RESET}\n"
        echo -e "Restoring mods from directory..."
        restore_dir
        echo -e "${SUCCESS}Restore completed!${RESET}"
        echo -e "\nRestored mods from $BACKUP"
        echo -e "\nPress Enter to exit."
        read
    elif [[ "$restore_choice" -eq 2 ]]; then
        clear
        echo -e "$TITLE > Restore from Tarball${RESET}\n"
        echo -e "Do you want to restore from tar or tar.gz?"
        echo -e "1. Restore from tar"
        echo -e "2. Restore from tar.gz"
        read -p "Enter your choice (1-2): " tar_choice
        if [[ "$tar_choice" -eq 1 ]]; then
            clear
            echo -e "$TITLE > Restore from tar${RESET}\n"
            restore_tar
            echo -e "${SUCCESS}Restore completed!${RESET}"
            echo -e "\nRestored mods from $BACKUP.tar"
            echo -e "\nPress Enter to exit."
            read
        elif [[ "$tar_choice" -eq 2 ]]; then
            clear
            echo -e "$TITLE > Restore from tar.gz${RESET}\n"
            restore_targz
            echo -e "${SUCCESS}Restore completed!${RESET}"
            echo -e "\nRestored mods from $BACKUP.tar.gz"
            echo -e "\nPress Enter to exit."
            read
        else
            echo -e "${ERROR}Invalid choice, press Enter to exit.${RESET}"
            read
            clear
            exit 1
        fi
    else
        echo -e "${ERROR}Invalid choice, press Enter to exit.${RESET}"
        read
        clear
        exit 1
    fi
 
else
    echo -e "${ERROR}Invalid choice, press Enter to exit.${RESET}"
    read
    clear
    exit 1
fi
postrun_cleanup