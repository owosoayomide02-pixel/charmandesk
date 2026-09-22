# Charmdesk

Cosmetic clicker for Roblox. **Coming soon** as a public place. Playable now in Studio.

## Play in Studio

1. Install [Rojo](https://rojo.space/docs/v7/getting-started/installation/) and the Rojo Studio plugin.
2. In this folder: `rojo serve`
3. In Roblox Studio: Plugins → Rojo → Connect.
4. Press Play. Click the gold core or press Space. Shop → Get (Studio) while product IDs are `0`.

If DataStores are off, the game uses an in-memory profile for that session.

## Creator Hub product IDs

I cannot create these on your account. You have to.

1. [create.roblox.com](https://create.roblox.com) → your experience → Monetization → Passes & Products.
2. Create **11 developer products** with the names and prices in `src/ReplicatedStorage/COSG/Products.lua`.
3. Create **1 Game Pass** named Charmdesk VIP at 399 R$.
4. Paste the numeric IDs into `Products.lua` and restart the server.

Until then, Studio grants shop items for testing. A live public server will not take Robux for cosmetics.

## Publish a public test

1. File → Publish to Roblox (new experience).
2. Game Settings → Security → enable **Studio Access to API Services** (DataStores).
3. Maturity: All Ages. Genre: Idle.
4. Upload `art/thumbnail.png` and `art/icon.png` when you have them.
5. Set the experience to **Public**.
6. Do not turn on paid randoms. Do not sell click power.

## What works now

- Play: click, combo, crit, Glint, click upgrades, 5 Operators
- Shop: 48 evergreen cosmetics, weekly limited, Studio grant or live prompt
- Prestige: keep cosmetics, +10% Glint, reset the run
- Desk + gold core in the place
- Procedural trail/theme colors (vinyl art still to commission)

## What you still do

- Paste product IDs
- Commission 48 vinyl-toy icons
- Publish the experience on your account
