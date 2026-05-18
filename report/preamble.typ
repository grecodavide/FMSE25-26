// algos
#import "@preview/algorithmic:1.0.0"
#import algorithmic: algorithm
#let algorithm = algorithm

#let red = rgb("#C5282F")
#let green = green.darken(20%)
#let blue = rgb("#1565C0")
#let yellow = rgb("#F57F17")
#let purple = rgb("#6A1B9A")

// better math (gradients, derivatives, ...)
#import "@preview/physica:0.9.5": *

// acronyms
#import "@preview/glossy:0.8.0": *

// drawings
#import "@preview/cetz:0.4.0" // basic

// #let draw =

/// Shows two blocks side by side
///
/// - first (block): Left block
/// - second (block): Right block
/// -> grid
#let sbs(first, second, caption: []) = {
    if caption != [] {
        return figure(
            grid(
                columns: (50%, 50%),
                gutter: 4pt,
                rows: auto,
                first, second,
            ),
            caption: caption,
        )
    } else {
        return grid(
            columns: (50%, 50%),
            gutter: 4pt,
            rows: auto,
            first, second,
        )
    }
}

#let sim = math.class("binary", $tilde$)

#let monofont = "JetBrainsMonoNL NF"

/// Inline slanted fraction
///
/// - num (content): numerator
/// - den (content): denumerator
/// -> content
#let nicefrac(num, den) = math.frac(num, den, style: "skewed")

#let overset(a, b) = {
    math.attach(math.limits(a), t: b)
}

#let inline_color = red.darken(40%)
#let inline(code) = { text(fill: inline_color)[#code] }

// tables should not be breakable
#show table: it => block(breakable: false)[#it]


/// Create a tree from a list of contents.
///
/// - body (array): The tree's element
/// -> figure
///
/// Usage example:
/// ```typ
/// #tree((
///     [A], [B], ([C], [D], [E])
///))
///```
///This will produce a tree with `A` as father of `B` and `C`, and `C` father of `D` and `E`
#let tree(body) = {
    figure(cetz.canvas({
        import cetz.draw: *
        import cetz: *

        set-style(
            content: (padding: .2),
            fill: gray.lighten(70%),
            stroke: gray.lighten(70%),
        )

        tree.tree(
            (
                body
            ),
            spread: 1.8,
            grow: 2,
            draw-edge: (from, to, ..) => {
                line(
                    (a: from, number: .6, b: to),
                    (a: to, number: .6, b: from),
                    mark: (end: ">"),
                    fill: black,
                    stroke: black,
                )
            },
            name: "tree",
        )
    }))
}

#let al(body) = {
    align(center)[
        #math.equation(numbering: none, block: true)[
            #body
        ]
    ]
}

#let tbl(caption: [], cols, ..body) = {
    if caption != [] and caption != "" and caption != none {
        return figure(
            table(
                columns: (auto,) * cols,
                inset: 8pt,
                ..body
            ),
            caption: caption,
        )
    }
    return figure(table(
        columns: (auto,) * cols,
        inset: 8pt,
        ..body
    ))
}


#let nameref(label) = context {
    let elements = query(label)
    if elements.len() == 0 {
        return [Unknown Reference]
    }
    let target = elements.first()

    // Determine the supplement (Section, Figure, etc.)
    let supplement = if target.has("supplement") {
        target.supplement
    } else {
        ""
    }

    // Get the name/title/caption
    let name = if target.has("caption") {
        if target.caption == none {
            target.counter.at(label).at(0)
        } else {
            target.caption.at("body")
        }
    } else if target.has("body") {
        target.body
    } else {
        [Unknown]
    }

    link(target.location())[#supplement "#name"]
}


// codly
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *

#let fontsize = 12pt

#let todo = txt => {
    block()[
        #set text(size: fontsize + 10pt, fill: red)
        *TODO*: #txt
    ]
}



// note: `show` passes the whole doc as a parameter

/// Document setup template.
///
/// - title (content): The document title
/// - author (string): The document author (not mandatory)
/// - glossary (dictionary): The document's glossary
/// - doc (content): document body
#let setup-document(
    title: none,
    author,
    glossary: (),
    number_page: true,
    doc,
) = {
    // ===== PAGE SETUP =====
    set text(
        fontsize,
        font: "Caladea",
    )
    show math.equation: set text(font: "STIX Two Math")

    // raw = monospace
    show raw: set text(font: monofont)
    // // change bg of monospaced inline
    // show raw.where(block: false): box.with(
    //     fill: luma(240),
    //     inset: (x: 3pt, y: 0pt),
    //     outset: (y: 3pt),
    //     radius: 2pt,
    // )
    show raw.where(block: false): set text(fill: inline_color)

    set terms(separator: [: ])

    set page(numbering: "1", number-align: right + bottom, margin: (
        x: 1.5cm,
        y: 1.5cm,
    )) if number_page

    show ref: it => {
        underline(text(fill: blue.darken(20%))[#it])
    }

    show link: it => {
        text(fill: blue.darken(20%))[#it]
    }

    // make image breakable if their content is breakable. Mainly for boxes
    show figure: set block(breakable: true)

    // ===== NUMBERING =====
    set heading(numbering: "1.")
    // reset math counter and environments counters every time a new heading of level 1 (section) is created
    show heading.where(level: 1): it => {
        counter(math.equation).update(0)
        for env in theorems {
            counter(figure.where(kind: env)).update(0)
        }

        it
    }

    // math numbering in references
    set math.equation(numbering: it => {
        let count = counter(heading.where(level: 1)).at(here()).first()
        if count > 0 {
            numbering("1.1", count, it)
        } else {
            numbering("1", it)
        }
    })

    // ===== PLUGIN INIT ======
    show: codly-init.with()

    codly(
        languages: codly-languages,
        zebra-fill: none,
        radius: 0pt,
        stroke: none,
        fill: white.darken(5%),
        lang-stroke: none,
        lang-fill: lang => white.darken(5%),
        number-align: right + horizon,
    )

    // NOTE: This goes after underline of ref, or they all will be blue and highlighted
    show: init-glossary.with(glossary)

    let auth_label = "Author"
    if type(author) == array {
        auth_label = "Authors"
        author = author.join(", ")
    }

    // ===== SETUP DOC =====
    set document(title: title, author: author)

    set align(center)
    text(fontsize + 7pt, context document.title)
    linebreak()
    text(fontsize + 1pt, [#auth_label: #context author])
    set align(left)

    outline(title: "Table of Contents")
    pagebreak()

    doc
}
