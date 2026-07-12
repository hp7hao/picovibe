# Firework Simulators Physical Preview Design

**Status:** Implemented
**Owning authority:** `projects/picovibe/docs/specs/picovibe_spec.md §8`

## Intent

Teach the physical form of each selectable firework before it is launched. The
selection view presents a large, rotating, low-poly model; firing switches back
to the existing full sky simulation.

## Interaction

- Idle selection replaces the sky region, approximately `y=10..80`, with the
  preview stage.
- Left and right select the previous or next model without firing.
- The selected model continuously spins around its vertical axis.
- Fire hides the stage immediately and launches the selected effect.
- The preview returns after particles and scheduled launch jobs finish.
- Selection during an effect clears the active simulation and shows the newly
  selected model.
- The bottom name, power, description, and controls remain available.

## Model Language

| Firework | Physical model |
|---|---|
| Fountain | Wide truncated cone and top nozzle |
| Roman candle | Tall narrow launch tube |
| Rocket shell | Pointed rocket body and guide stick |
| Peony | Faceted spherical aerial shell and short fuse |
| Chrysanthemum | Faceted spherical shell with a wrapping band |
| Willow | Large oval shell and fuse cap |
| Palm | Long cylindrical shell with reinforcing bands |
| Ring | Disc-shaped aerial shell |
| Crackle | Compact clustered canister |
| Finale | Rectangular cake rack with multiple launch tubes |

## Renderer

Models are compact vertex-and-face data inside the cart. A shared renderer
rotates vertices around the vertical axis, applies a fixed elevated camera, and
projects them into the preview stage. Faces are ordered back-to-front by average
depth. Each model uses a dark outline plus three or four palette shades selected
from face orientation; a flattened ellipse supplies the ground shadow.

This is a visual teaching aid, not a general-purpose 3D engine. It has no free
camera, model interaction, external assets, texture mapping, or multi-axis
tumbling.

## State and Data Flow

The cart has two presentation modes: `preview` and `launched`. Selection enters
`preview`; Fire enters `launched`. Existing particles and jobs remain the source
of truth for launch activity. When both collections are empty after a launch,
the cart returns to `preview`. Model angle advances only for presentation and
does not affect launch physics.

## Verification

- Validate the edited cartridge with the repository `p8mod-author` validator.
- Export through the standalone playable conversion path and reach `running`.
- Add a focused static test proving all ten firework records map to distinct
  physical model definitions and that selection/launch modes exist.
- Capture preview frames at separated times and verify that their hashes differ.
- Trigger Fire and verify the preview stage is absent while the effect runs and
  returns after jobs and particles drain.
