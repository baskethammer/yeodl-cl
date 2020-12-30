# YEODL-cl

This is a set of common lisp functions to access [YEODL](https://github.com/baskethammer/yeodl) in a relatively conveninent way.

## License

GNU General Public License V3

## Description

The best entry points are probably (get-instruments-from-tickers), for interactive work, or (get-instruments-from-file) to build a scan from a base SQL query of the YEODL database.

## Getting Started

Clone or download this to a directory where [quicklisp](https://www.quicklisp.org/beta/) can find it. Then (ql:quickload :yeodl-cl), (in-package :yeodl) to begin playing.  Yeodl-cl does not read the YEODL config yet, so supply full pathname strings where called for.

### Dependencies

Depends on [YEODL](https://github.com/baskethammer/yeodl) and a Common Lisp implementation (this was developed with [SBCL](https://www.sbcl.org))

## Authors


Basket Hammer  
[@baskethammer](https://twitter.com/baskethammer)

## Version History

* 0.1
    * Initial Release

## License

This project is licensed under the GNU General Public License (v3) - see the LICENSE.md file for details

