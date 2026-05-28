# templates/ directory

Use this directory for **Jinja2 template files** that Ansible renders before copying to managed hosts.

Templates are useful when:

- Configuration differs by host, group, or environment.
- Values should come from variables (inventories, group_vars, host_vars, or extra vars).
- You want one source file to generate many similar configs.

Typical examples:

- Service configs (e.g., `nginx.conf.j2`, `httpd.conf.j2`, `sshd_config.j2`)
- Systemd unit files (e.g., `myapp.service.j2`)
- Application config files (e.g., `appsettings.yml.j2`, `logging.conf.j2`)
- Script templates that embed variable values (e.g., `backup.sh.j2`)

Basic usage in a task:

```yaml
- name: Deploy templated sshd config
  ansible.builtin.template:
    src: sshd_config.j2
    dest: /etc/ssh/sshd_config
    owner: root
    group: root
    mode: "0600"
```

Guidelines:

- Use clear, descriptive names ending with .j2.

- Keep logic in templates simple; prefer variables and defaults over complex Jinja expressions.

- Put files that do not need variable substitution in the files/ directory instead.