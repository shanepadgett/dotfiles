# Dotfiles skill

Use this skill when editing Shane's dotfiles repo or diagnosing dotfile drift.

## Source of truth

Always start with active chezmoi source:

```bash
chezmoi source-path
cd "$(chezmoi source-path)"
git status --short
chezmoi status
```

Do not edit another dotfiles clone unless explicitly requested.

## Profiles

Machines use chezmoi data:

```toml
[data]
profile = "work" # or "personal"
email = "name@example.com"
```

Use `.profile` for work/personal separation. Hostname checks are fallback only.

## App-edited configs

Editable app configs use profile-specific symlink backing files under `app-configs/`.

Example target:

```text
~/.config/zed/settings.json
```

Work profile points to:

```text
app-configs/zed/settings.work.json
```

Personal profile points to:

```text
app-configs/zed/settings.personal.json
```

If app changes settings, app writes through symlink into correct repo-backed file. Commit that backing file.

## Work secrets

Work secrets live in 1Password vault `Shane Work`. Items use `username` and `credential` fields. `credential` contains PAT/token value.

Use chezmoi `onepasswordRead` in templates:

```gotemplate
{{ onepasswordRead "op://Shane Work/Jira/credential" }}
```

Managed work token targets:

```text
~/.bitbucket_token
~/.confluence_token
~/.jira_token
~/.jenkins_token_pxjnk_nonprod
```

Managed work env target:

```text
~/.config/work/env.sh
```

`.zshrc` sources `~/.config/work/env.sh` on work profile. Env file exports:

```text
BITBUCKET_USER
BITBUCKET_PERSONAL_TOKEN
CONFLUENCE_USER
CONFLUENCE_PERSONAL_TOKEN
JIRA_USER
JIRA_PERSONAL_TOKEN
JENKINS_USER
JENKINS_PERSONAL_TOKEN
```

Codex work config stays token-free. It references environment variables such as `${JIRA_PERSONAL_TOKEN}` instead of storing PATs.

## Pi and Crumbs

Pi config uses profile-specific symlink backing files:

```text
~/.pi/agent/settings.json -> app-configs/pi/settings.work.json
```

The work Pi settings may source `~/.config/work/env.sh` through `shellCommandPrefix`. Personal Pi settings omit work env setup.

Crumbs config uses profile-specific symlink backing files:

```text
~/.agents/crumbs/crumbs.json -> app-configs/crumbs/crumbs.work.json
```

Do not manage `.agents/skills/agent-browser/**` or `.agents/skills/frontend-design/**`. Those are intentionally unmanaged.

Do not commit Crumbs MCP API keys. Disabled test MCP servers may stay in config with `enabled: false`, but remove secret headers such as `x-api-key`.

## Drift workflow

Use these commands before and after changes:

```bash
chezmoi status
chezmoi diff
chezmoi managed
chezmoi unmanaged
chezmoi verify
```

Use `chezmoi re-add <path>` for normal chezmoi-managed files. Prefer app-config backing files for app-edited configs.

## Safety rules

- Do not commit tokens, credentials, histories, caches, or app state.
- Use `onepasswordRead`, encryption, or local unmanaged files for secrets.
- Store 1Password references in repo, never raw secret values.
- Keep work-only values behind `profile = "work"`.
- Keep personal-only values behind `profile = "personal"`.
- Prefer smallest change that preserves repeatable install on new machines.
