# Welcome to Petr4

The Petr4 project is developing the formal semantics of the [P4
Language](https://p4.org) backed by an independent reference
implementation.

## Getting Started

### Installing Petr4

1. Install [OPAM](https://opam.ocaml.org/).
   ```
   sudo apt-get install opam
   opam init
   eval `opam env`
   ```

1. Install external dependencies:
   ```
   sudo apt-get install m4 libgmp-dev
   ```

#### Installing from OPAM
1. Install petr4 from the opam repository. This will take a while the first time
   because it installs OPAM dependencies.
   ```
   opam install petr4
   ```

#### Installing from source
1. Check the installed version of OCaml:
    ```
    ocamlc -v
    ```
    If the version is less than 4.09.0, upgrade:
    ```
    opam switch 4.09.0
    ```

1. Install [p4pp](https://github.com/cornell-netlab/p4pp) from source.

1. Use OPAM to build and install Petr4. This will take a while the first time
   because it installs OPAM dependencies.
   ```
   opam pin add petr4 <path to root of petr4 repo>
   ```

### Running Petr4

Currently `petr4` is merely a P4 front-end. By default, it will parse
a source program to an abstract syntax tree and print it out, either
as P4 or encoded into JSON.

Run `petr4 -help` to see the list of currently-supported options.

### Web user interface

`petr4` uses `js_of_ocaml` to provide a web interface. To compile to javascript,
run `make build_js`. Then open `index.html` in `html_build` in a browser.

## Contributing

Petr4 is an open-source project. We encourage contributions!
Please file issues on
[Github](https://github.com/cornell-netlab/petr4/issues).

## Credits

See the list of [contributors](CONTRIBUTORS).

## License

Petr4 is released under the [Apache2 License](LICENSE).
