# tools

A personal collection of the things I use and reuse when working with code:

- **Scripts**: small utilities and automation I find myself writing more than once.
- **Tools**: notes on the software I rely on and how I configure it.
- **Workflows**: ways of doing things, such as checklists, conventions and habits that work.
- **Computer setup**: how to set up a new machine, including installs, dotfiles, settings and shell config.
- **Projects**: small code projects and experiments that don't need a repo of their own.

## Layout

Each topic gets its own folder as it's added. Planned:

```
scripts/     reusable scripts and one-off utilities
setup/       machine setup, dotfiles and config
workflows/   notes on ways of doing things
projects/    small projects and experiments
```

## Conventions

- Every folder has a short `README.md` that says what's in it and how to use it.
- Scripts start with a comment explaining what they do and how to run them.
- No secrets in the repo. Keep keys and tokens in `.env` files, which git ignores.
