# Postman Integration Boundary

Dotfiles supplies the authored role policy in
`config/tmux-a2a-postman/postman.md`. Package and Skill installation use the
ordinary pinned flake input and shared agent-Skill configuration.

Postman owns its CLI, configuration format, mailbox/native identity,
notifications, execution coordination, diagnostics and transport tests. Use
its installed help, shipped Skills and upstream documentation for those
contracts. Dotfiles does not provide another Postman command, launcher,
configuration compiler, test framework or update program.

Edit topology and declared parent/child relationships in `postman.md` using
Postman's configuration reference. Starting an agent is independent of that
configuration. Clients start directly; the complete Markdown returned by POP
carries the common and recipient-role policy.

Develop and validate Postman in its own repository. Its
[contributor guide](https://github.com/i9wa4/tmux-a2a-postman/blob/main/CONTRIBUTING.md)
owns native terminal and recursive transport verification. Dotfiles checks its
own declarative configuration and role-policy source, without duplicating the
transport implementation or test driver.

Keep the explicit compatible Postman revision in `flake.nix` and refresh its
lock entry with ordinary Nix commands when choosing a new revision. Source
checks do not activate the installed configuration or prove a live-fleet switch.
