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
matrix containing the initial state of the world. Then, we declared an array of
offsets

// End of subsection (level 2) "World movement"

// End of section (level 1) "Design choices"
