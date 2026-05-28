# OEL9 on VMware with cloud-init, Terraform, and Ansible Automation Platform
! THIS README IS A WORK IN PROGRESS !

This starter kit builds reusable Oracle Linux 9 VMs on VMware vSphere using Terraform modules, cloud-init via VMware GuestInfo, and Ansible as the orchestration entry point.

## Security update

This version removes the vCenter password from Terraform variable files and Ansible-rendered tfvars content.

Use one of these patterns instead:

1. Preferred for AAP: store the vCenter password in an AAP credential and inject it as `TF_VAR_vsphere_password`.
2. Acceptable for non-AAP use: export `TF_VAR_vsphere_password` in the shell before running Terraform.
3. Optional fallback: store the password in Ansible Vault and inject it only into the task environment, never into `terraform.tfvars`.

## What this includes

- Modular Terraform layout for reusable vSphere VM provisioning
- Support for multiple NICs per VM
- Support for optional extra disks per VM
- VM `type` profiles (for example `generic`, `app`, `db`) to apply opinionated defaults
- cloud-init templates for Oracle Linux 9 using VMware GuestInfo metadata and userdata
- Ansible playbook structure suited for Ansible Automation Platform job templates and surveys
- Example AAP survey spec you can translate into an AAP Survey
- `.gitignore` tuned to avoid committing secrets and local Terraform state
- Example custom credential injector for AAP
- Optional Ansible Vault vars example

## Recommended build pattern

1. Build and harden an Oracle Linux 9 golden template first.
2. Ensure `cloud-init` and `open-vm-tools` are installed in the template.
3. Prefer VMware GuestInfo transport for cloud-init rather than mixing classic guest customization and cloud-init.
4. Clean cloud-init state before converting the source VM into a template:
   - `cloud-init clean --logs --machine-id`
5. Shut down and convert to template.

## Secret handling

### Preferred: AAP credential injection

Create or reuse an AAP credential that injects the vCenter password into the job runtime as:

```bash
TF_VAR_vsphere_password
```

You can also inject `TF_VAR_vsphere_user` and `TF_VAR_vsphere_server` if you want all provider credentials to stay outside files.

### Local CLI example

```bash
export TF_VAR_vsphere_password='super-secret-password'
cd terraform
terraform init
terraform apply
```

### Optional Ansible Vault fallback

Store the password in `group_vars/all/vault.yml` or another vaulted vars file, then pass it only into the Terraform task environment.

## Template prerequisites

On the OEL9 template, verify at minimum:

```bash
sudo dnf install -y cloud-init open-vm-tools
sudo systemctl enable --now vmtoolsd
sudo systemctl enable cloud-init-local.service cloud-init.service cloud-config.service cloud-final.service
```

Create `/etc/cloud/cloud.cfg.d/99-vsphere.cfg`:

```yaml
datasource_list: [ VMware, None ]
```

If your environment uses any VMware guest customization workflow alongside cloud-init, update `open-vm-tools` and set a larger timeout in `/etc/vmware-tools/tools.conf`:

```ini
[deploypkg]
wait-cloudinit-timeout=300
```

## Repository layout

```text
terraform/
  main.tf
  variables.tf
  terraform.tfvars.example
  outputs.tf
  modules/
    vm/
      main.tf
      variables.tf
      outputs.tf
  templates/
    metadata.yaml.tftpl
    userdata.yaml.tftpl
ansible/
  inventories/
    hosts.yml
  playbooks/
    provision_vm.yml
  roles/
    terraform_runner/
      tasks/main.yml
      templates/terraform.auto.tfvars.json.j2
  group_vars/
    all/
      vault.yml.example
security/
  aap_custom_credential_type.yml
.gitignore
```

## AAP credential example

The `security/aap_custom_credential_type.yml` file shows an example custom credential type that injects secrets into environment variables. In many shops, built-in VMware or machine credentials plus controller-managed secret injection are enough, but the custom type is useful when you want Terraform-native `TF_VAR_*` injection.

## Suggested AAP survey fields

- `vm_name`
- `vm_type` with choices `generic`, `app`, `db`
- `environment`
- `vsphere_datacenter`
- `vsphere_cluster`
- `vsphere_datastore`
- `vsphere_networks_json`
- `extra_disks_json`
- `template_name`
- `cpu_override`
- `memory_override_mb`
- `dns_servers_csv`
- `ansible_ssh_public_key`

Do not collect `vsphere_password` in the survey.

## Example run locally

```bash
export TF_VAR_vsphere_password='super-secret-password'
cd terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

## Example run from Ansible

```bash
ansible-playbook ansible/playbooks/provision_vm.yml -e @extra_vars.yml --vault-id dev@prompt
```
