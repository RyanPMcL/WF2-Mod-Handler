# Soufants Wreckfest 2 Mod Handler
A tool for backing up and restoring mod files for Wreckfest 2 on Linux (including Steam Deck)

Soufants Wreckfest 2 Mod Handler is a tool I wrote in response to [Wreckfest 2 Mod Files Extractor by STRm0ds](https://www.nexusmods.com/wreckfest2/mods/4) only being available for Windows. I have completely remade the script for Linux using bash script and proton, and added many useful features in the process.

This tool allows you to:
- Backup mods to a directory
- Backup mods to a tarball (both tar and tar.gz)
- Delete mods
- Restore mods from a directory or tarball
- Validate Wreckfest 2 Steam files

The script requires Proton Experimental to be installed via Steam.  
To run the script simply save it in your Wreckfest 2 root directory, give it execution permission, and run it in the terminal.

```
chmod +x WF2ModHandler.sh;
./WF2ModHandler
```

The script can also be found on [Nexus Mods](https://www.nexusmods.com/wreckfest2/mods/15)
