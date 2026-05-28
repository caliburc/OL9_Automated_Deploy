# roles/ directory

Use this directory to store **Ansible roles**, which are self‑contained units of automation that bundle tasks, handlers, variables, files, templates, and defaults for a specific function.

Roles help you:

- Reuse common logic across many playbooks.
- Enforce consistent patterns and standards.
- Keep playbooks small, readable, and focused on orchestration.

---

## What is a role?

A role is a structured collection of Ansible content for one responsibility, for example:

- `linux_baseline` – OS hardening, packages, services, sysctl, SSH config.
- `f5_virtual_server` – create and manage a virtual server on F5.
- `mysql_server` – install, configure, and manage MySQL.
- `windows_baseline` – baseline policies, services, and security settings on Windows.

A typical role structure:

```text
roles/
  linux_baseline/
    tasks/
      └── main.yml
    handlers/
      └── main.yml
    templates/
    files/
    vars/
      └── main.yml
    defaults/
      └── main.yml
    meta/
      └── main.yml
    README.md
```

Each subdirectory has a specific purpose (tasks to run, handlers to notify, templates to render, etc.).

### Create a role
To create a role, run the following:

`ansible-galaxy role init <role name>`

## When to use a role
Create or use a role when:

- The same logic is needed in multiple playbooks (e.g., OS hardening, user creation, monitoring agent install).

- You want to encapsulate a well‑defined function with clear inputs (vars) and outputs (configured system state).

- The task list in a playbook becomes long or complex and needs structure.

- You want to share automation between teams or publish it as a reusable component.

Roles are not ideal when:

- You have a one‑off, very small change that is unlikely to be reused.

- You’re prototyping or experimenting with a couple of tasks (start in a playbook; extract into a role once it stabilizes).

## Guidelines for creating roles

- Give roles clear, descriptive names (linux_baseline, vmware_guest, gitlab_runner).

- Keep roles focused on a single responsibility.

- Put reusable logic into roles; keep playbooks for orchestration and composition.

- Document role variables and behaviour in README.md inside each role.