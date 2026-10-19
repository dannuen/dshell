# Migrations

Small scripts that update an existing install after a change in the repo.
`update.sh` runs every script whose number is higher than the last one it ran,
in order, and stores the last number in `~/.local/state/dshell/migration`.

Name: `NNN_short_name.sh` (three digits, then an underscore).
Each script is plain bash, run from any directory, and must be safe to run once.
