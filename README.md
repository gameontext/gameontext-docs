# Game On! Hands-on adventures in cloud native development.

Blog and book, markdown and asciidoc, all together in one place.

To build locally (hints for some of these steps can be found in .github/workflows)

1. Install asciidoctor
2. Install hugo
3. Run `./wrap_asciidoc.sh`
4. Update local path (just that terminal window): `export PATH=$PWD/bin:$PATH`
    * `which asciidoctor` should return `./bin/asciidoctor`
5. Build site / use hugo:

    ```bash
    cd site
    hugo
    ```
