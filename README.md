# Vanilla CI Scripts

This repositority contains various Vanilla Forums scripts for CircleCI.

## Orbs

Vanilla has some orbs to help share CI configuration.

### vanilla/core

This is defined in `core.yml`. This contains

-   Shared executors.
-   Shared commands that can apply to all repos. (Like checkout)

### vanilla/jobs

This contains jobs meant to run in "secondary" repositories.

"Secondary" repositories are repos containing extensions to Vanilla.
They require cloning vanilla in order to run their CI.

## Auto-Publishing

Orbs are automatically published through pull requests and merges:

### On a pull request

At any give time, the latest commit for any modified orbs will be avaible with the following tag:

```
// PR branch: fix/some-bug

vanilla/orb-name@dev:fix/some-bug
```

### On `master`

Master branch automatically attempts to publish a production semver
version of modified orbs using the `publishVersion` field in the orb.

**_Be sure to increment this when changing them!!!_**
