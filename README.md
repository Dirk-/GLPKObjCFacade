# GLPK Framework Facade for Objective C

This project is a wrapper framework around [GLPK (GNU Linear Programming Kit)](https://www.gnu.org/software/glpk/) so it can be easily used from Objective C for macOS or iOS projects.

The current version is based on GLPK 4.65. One change had to be made to the GLPK source: 
The line `#define zmemcmp memcmp` was added to `zutil.h`.

## Credits

This framework is based on the corresponding [GLPK Swift framework](https://github.com/Allezxandre/GLPK-Swift) by Alexandre Jouandin. I first wanted to contribute the Objective C version, but the Swift dependency is not ideal for pure Objective C programs. Maybe the Objective C versions can be added as seperate targets later.
