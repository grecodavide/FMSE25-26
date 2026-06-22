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

#let todo(ctx) = {
    text(stroke: red, fill: red, size: 15pt)[#ctx]
}

= Design choices<sec:design-choices>
== Master-slave approach<sec:master-slave-approach>
Since at every tick both the world and the player must move, we decided to take
a master-slave approach: at each tick, the world moves first, and notifies a
global urgent channel, from which the player listens. As soon as the world
ticked, the player performs its "turn", which is:
- checking if the world movement killed him
- if not, perform a movement (which can either be to go up or to stay still)
- check if the movement killed him:
    - if so, we must reset
    - if not, we go back to waiting state (unless we are in `MAX_Y` row, in
        which case we just occupied a home bay and we must reset)

This way we are sure that the world and player movement are synchronized, and
that there is never a configuration that would kill the player that goes
unnoticed.

// End of subsection (level 2) "Master-slave approach"

== World movement (symbolic)<sec:world-movement>
Since all elements of a row move at the same speed (at least for the symbolic
version, see #todo([link to stochastic handling of trucks])), to reduce
state-space size we decided to model the world as an array of rows that move
with the speed of the elements occupying the given row. To achieve this we used:
- A matrix containing the initial state of the world: each row has 18 + 2
    columns, to handle the warping that takes two more steps. Each cell is an
    int representing the type of the cell, which can be
    #figure(
        table(
            columns: 3,
            align: left,
            table.header([*Number*], [*Name*], [*Description*]),
            [$-1$], [`C_WARP`], [not a real cell, but the space of warping],
            [ $0$],
            [`C_EMPTY`],
            [a cell in which there is no entity (not considering the player)],

            [ $1$],
            [`C_OBJ`],
            [either a car (in the first 6 rows), or a wall (in the last row)],

            [ $2$], [`C_LOG`], [a log (only in rows 7-11)],
            [ $3$],
            [`C_TURTLE`],
            [a regular (i.e. not diving) turtle (only in rows 7-11)],

            [ $4$], [`C_DIVING`], [a diving turtle (only in rows 7-11)],
        ),
    )
- An array of speeds (one for each row). As per specification, the speed of a
    row is the number of ticks between two consecutive movements.
- An array of directions (one for each row). When we want to get a specific
    cell, we need to multiply the current offset with the direction of the
    current row. We must however pay attention to a detail: without loss of
    generality, let's assume that we are looking at a row that moves from left
    to right. Since we are moving the whole row, when it moves all its elements
    will be shifted to the right by one, so the element now occupying cell `X`
    is the element in the original matrix occupying cell `X-1`: this means that
    we must use `-1` for left-to-right movement, and `1` for right-to-left
    movement.
- An array of offsets (one for each row). Each tick, if the current number of
    ticks is divisible by the speed of the current row, this will increase by
    one (with modulo `MATRIX_COLS`).
- The function `int[-1,4] get_cell(int[0, MAX_Y] row, int[0, MATRIX_COLS] col)`,
    which makes use of all the aforementioned structures to get the type of cell
    currently occupying a given position.

#sbs(
    [In this way, we have a single automata for all the rows that, at each
        ticks, updates all the rows (and hence all the elements of the rows).
        Moreover, it also results in a very simple automata: every tick of its
        clock, update the world according to the rules we just described and
        notify the channel. One other thing this automata checks is the state of
        the diving turtles: since we only care about what the turtles do to the
        player, we only care about the moments in which they kill the player
        (submerged), and the moments they don't kill the player (submerging,
        emerging, emerged). This is handled by a boolean,
        `are_diving_turtles_up`, which gets set according to the time units
        described in the specification.],

    align(center + horizon)[#figure(
        image("assets/2026-06-22-11-31-04.png", width: 80%),
        caption: [World automata],
    )],
)

// End of subsection (level 2) "World movement"

== Player modeling (symbolic)<sec:player-modeling>
The player needs to handle a lot of different scenarios, so it will naturally be
more complex:
#figure(
    image("assets/2026-06-22-11-29-36.png", width: 100%),
)

We start in the `Reset` state, and we stay there for 2 seconds (which
corresponds to 20 time units). After that time period, it goes in the `Waiting`
state, from which it can exit only if one of two conditions is met:
- the `world_ticked` channel pushed a notification: we must perform the player
    turn
- the timer reached the maximum value allowed: it counts as player death
In the former, the turn is the one described in @sec:master-slave-approach. If
the player reached the last row, it means it occupied a home bay: this means we
must mark the home bay as occupied (hence making it unreachable in the next
round), and check if we won the whole level. If that is the case, in the
symbolic mode we must stop. The same applies if the player dies and its lives
reach 0.

// End of subsection (level 2) "Player modeling"

// End of section (level 1) "Design choices"

= Symbolic version results<sec:symbolic-version-results>
Note that there are two different system declarations: the "complete" one, and
the "partial" one. For the former, ensure that in `System declarations` the line
`system frogger, world;` is uncommented and `system world;` is commented; while
for the latter the opposite must be verified. The first two queries will use
"partial" system, while the others the "complete" one.

== First query<sec:first-query>
=== Assignment
the game never reaches a deadlock state
// End of subsubsection (level 3) "Assignment"

=== Query used
```txt
A[] not deadlock
```

// End of subsubsection (level 3) "Query used"

=== Results
The query is trivially verified.

// End of subsubsection (level 3) "Results"

// End of subsection (level 2) "First query"

== Second query<sec:second-query>
=== Assignment
all vehicles and floating objects can only move inside their predefined row

=== Query used
```txt
A[] (offsets[1] >= 0 && offsets[1] < MATRIX_COLS &&
     offsets[2] >= 0 && offsets[2] < MATRIX_COLS &&
     offsets[3] >= 0 && offsets[3] < MATRIX_COLS &&
     offsets[4] >= 0 && offsets[4] < MATRIX_COLS &&
     offsets[5] >= 0 && offsets[5] < MATRIX_COLS &&
     offsets[7] >= 0 && offsets[7] < MATRIX_COLS &&
     offsets[8] >= 0 && offsets[8] < MATRIX_COLS &&
     offsets[9] >= 0 && offsets[9] < MATRIX_COLS &&
     offsets[10] >= 0 && offsets[10] < MATRIX_COLS &&
     offsets[11] >= 0 && offsets[11] < MATRIX_COLS)
```


=== Results
The query is true by construction since the rows themselves move, but we can
easily run it and see it is verified.

// End of subsection (level 2) "Second query"

== Third query<sec:third-query>
=== Assignment
Frogger can reach the home bay in position (0,12)–(1,12)

=== Query used
```txt
E<> frogger.y == 12 && (frogger.x == 0 || frogger.x == 1)
```

=== Results
Easily verified: 0.324s

// End of subsection (level 2) "Third query"

== Fourth query<sec:fourth-query>
=== Assignment
Frogger can score 17 points reaching the home bay in position (8,12)–(9,12)

=== Query used
```txt
E<> frogger.points == 17 && frogger.home_bays_occupied[2] &&
    frogger.y == 12 && (frogger.x == 8 || frogger.x == 9)
```

=== Results
We need to check the point immediately after occupying the home bay, so we must
check that the home bay is marked as occupied (so its points have been added),
and the position is still the one required (no other movement). Verified in
0.245 s
// End of subsection (level 2) "Fourth query"

== Fifth query<sec:fifth-query>
=== Assignment
Frogger can reach a yellow cell in row 6 after the player has lost two lives

=== Query used
```txt
E<> frogger.lives == 3 && frogger.y == 6
```

=== Results
Easily verified: 0.03s

// End of subsection (level 2) "Fifth query"

== Sixth query<sec:sixth-query>
=== Assignment
Frogger may stand on a log (with five lives) 10 seconds after the game starts

=== Query used
```txt
E<> frogger.lives == 5 &&
    frogger.on_cell == C_LOG &&
    global_clock == 10*time_unit_to_s
```

=== Results
Verified: 3.756s

// End of subsection (level 2) "Sixth query"

== Seventh query<sec:seventh-query>
=== Assignment
Frogger can die riding a diving turtle that transitions to the submerged state

=== Query used
```txt
E<> frogger.died_by_submerging
```

=== Results
This query is simple thanks to the `died_by_submerging` attribute: it is always
false, except when we die while on a diving turtle before moving: this means the
player died specifically because of the submerging of the turtles. Because of
this, it is easily verified: 0.325s

// End of subsection (level 2) "Seventh query"

// End of section (level 1) "Symbolic version results"
