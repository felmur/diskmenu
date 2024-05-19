# diskmenu
A floppy disk menu for C64. Save it as first program of your own disk!

# Description
Do you remember the times of the C64 and its legendary 1541 drive?
Well, if you still have them or if you like playing with the C64 emulator (for example VICE) and would like to customize your floppy disk collections by inserting in each of them a menu that allows you to run the various files, well, this " diskmenu" is for you.

Save it as the first file, so that it will be loaded with:
```
LOAD "*",8
RUN
```

When you then type "RUN", a window will automatically open with the first 13 files on your floppy, allowing you to choose the one you want to run.

The main routine resides starting at $C000. In case of reset, therefore, the program should still be activated by typing:
```
SYS49152
```

The program is written in 6502-Assembly. The only file you have to save on your disk is "MENU.PRG".

# Compile from source
To compile from source, you must use tass64 (find it [here](https://sourceforge.net/projects/tass64/)).
```
$> tass64 main.asm -o main.prg
$> tass64 menu.asm -o menu.prg
```

