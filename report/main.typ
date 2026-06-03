#import "./preamble.typ": *
// Example of glossary:
// glossary: (
//     example: (
//         short: "EX",
//         long: "Example",
//         description: "This is a toy example"
//     ),
// ),

#show: setup-document.with(
    title: [Formal Methods for Software Engineering homework report],
    author: ("Davide Greco", "Edoardo Egidio"),
    glossary: (),
)

= Design choices<sec:design-choices>
== World movement<sec:world-movement>
Since all elements of a row move with the same speed, to reduce the state-space
size, we decided to make the whole row move with that speed: we declared a
matrix containing the initial state of the world, and an array of offsets, one
per row. Then, every time the world's clock ticks, for each row we check if the
number of ticks is a multiple of the row's speed and, if so, we increase the
offset of that row. To get the current element in a cell, we just need to look
at the matrix in the cell at the given `x` *minus* the offset multiplied by the
direction of the row ($1 $ for left-to-right movement, $-1 $ for right-to-left
movement): let's assume the row moves from left to right, and we have an offset
of 1. What it means is that the current cell corresponding to `x` is actually
the cell just before, as the whole row just shifted one to the right.

// End of subsection (level 2) "World movement"

// End of section (level 1) "Design choices"
