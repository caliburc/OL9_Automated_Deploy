**⚠️ WARNING**: This role performs critical database patching. Always test in non-production environments, maintain backups, and have a rollback plan before running in production.

# Oracle Patch Ansible Role

Automates end-to-end Oracle Database patching including OPatch upgrades, Release Updates (RU), Release Update Revisions (RUR), one-off patches, and datapatch execution. Intended to be used within the deployment project for fresh DB installs.

## Overview

This role manages the complete Oracle patching lifecycle:

- **OPatch Tool Upgrade** – Updates Oracle's patching utility to the required version
- **Patch Staging** – Downloads and unpacks patches from a source location
- **Conflict Detection** – Checks for patch compatibility before applying
- **Database Shutdown** – Gracefully stops the database and listener
- **Patch Application** – Applies RU, RUR, and one-off patches offline
- **Database Startup** – Restarts the database and listener
- **Datapatch Execution** – Applies necessary SQL schema changes
- **Verification** – Confirms patches installed successfully
- **Cleanup** – Removes temporary patch files

## Role Workflow

```
1. Create staging directory
   ↓
2. Record pre-patch inventory
   ↓
3. Upgrade OPatch (if needed)
   ↓
4. Copy & unzip all patches
   ↓
5. Check for conflicts (database online)
   ↓
6. Shutdown database & listener
   ↓
7. Apply patches (offline)
   ↓
8. Start database & listener
   ↓
9. Run datapatch (SQL changes)
   ↓
10. Verify patches installed
   ↓
11. Cleanup temporary files
```

## Requirements

### System Requirements
- Oracle Database 19c
- Ansible 2.9+
- OPatch pre-installed on target system
- SSH access to target hosts
- sudo privileges for oracle user

### Connectivity
- Source patches must be accessible to Ansible controller or target
- ORACLE_HOME must exist and be writable by oracle user
- `/etc/oratab` must exist and be properly configured

## Configuration

### Required Variables

Vars for this playbook live in `ansible\vars\oracle19c-vars.yml`

```yaml
# ── Oracle User / Group ──────────────────────────────────────────────────────
oracle_user: oracle
oracle_group: oinstall
oracle_dba_group: dba

# ── Oracle Home / Base ───────────────────────────────────────────────────────
oracle_base: /app/oracle
oracle_home: /app/oracle/db19
oracle_inventory: /app/oracle/db19/oraInventory

# ── Global patch toggle ───────────────────────────────────────────────────────
oracle_patching_enabled: true

# ── Staging paths ─────────────────────────────────────────────────────────────
# Paths to where Oracle CPU Patches exist, the stage_src should never change
# current_cpu_src should change quartlery after being downloaded by DBAs
oracle_patch_stage_src: /depot/software/Oracle/lnx/cpus
oracle_patch_current_cpu_src: "26aprCPU/19c"

# Temporary directory on the target server
oracle_patch_stage_dir: /tmp/oracle_patches

# ── OPatch upgrade ────────────────────────────────────────────────────────────
# Download latest OPatch
oracle_opatch_upgrade_enabled: true
oracle_opatch_zip: "p6880880_190000_Linux-x86-64.zip"
oracle_opatch_version_expected: "12.2.0.1.49"   # used for post-check assertion

# ── Release Update (RU) ───────────────────────────────────────────────────────
# Patch numbers change every quarter; update oracle_ru_patch_id and filename.
oracle_ru_apply_enabled: true
oracle_ru_patch_id: "39034528"                        # MOS patch number
oracle_ru_zip: "p39034528_190000_Linux-x86-64.zip"   # filename on controller
oracle_ru_description: "Oracle 19.31.0.0.260421 Database Release Update"

# ── Release Update Revision (RUR) - optional ─────────────────────────────────
# Apply a RUR on top of the RU (uncommon; leave enabled: false unless needed)
oracle_rur_apply_enabled: false
oracle_rur_patch_id: ""
oracle_rur_zip: ""
oracle_rur_description: ""

# ── One-off patches - ordered list, applied after RU ─────────────────────────
# Add / remove entries freely; the role iterates the list.
# This list should include things like the OJVM and JDK upgrades if applicable
# Set oracle_oneoff_patches: [] to skip entirely.
oracle_oneoff_patches:
  - patch_id: "38906621"
    zip: "p38906621_190000_Linux-x86-64.zip"
    description: "OJVM RELEASE UPDATE 19.31.0.0.260421"
  - patch_id: "38930593"
    zip: "p38930593_190000_Linux-x86-64.zip"
    description: "Oracle JDK8u491"

# ── Datapatch ─────────────────────────────────────────────────────────────────
# Run datapatch after all patches are applied (required for SQL changes in RU)
oracle_datapatch_enabled: true

# ── OPatch conflict check ─────────────────────────────────────────────────────
# Abort if OPatch conflict detected (recommended: true)
oracle_opatch_conflict_check: true

# ── Patch timeout (seconds) ───────────────────────────────────────────────────
oracle_patch_timeout: 3600
```

### Optional Variables

```yaml
# Skip listener stop/start
oracle_listener_name: "LMT"  # Default listener name

# Dry-run mode (no changes)
oracle_patch_dry_run: false
```
---
### Available Tags

| Tag | Description |
|-----|-------------|
| `patch_stage` | Create staging dir, copy & unzip patches |
| `patch_inventory` | Record pre/post patch inventories |
| `opatch_upgrade` | Upgrade OPatch tool |
| `patch_conflict` | Check for patch conflicts |
| `patch_shutdown` | Stop database and listener |
| `patch_apply` | Apply RU, RUR, one-off patches |
| `patch_startup` | Start database and listener |
| `datapatch` | Run datapatch for SQL changes |
| `patch_verify` | Verify patches installed |
| `patch_cleanup` | Delete temporary patch files |
| `patch` | Run all patching tasks |

## Task Descriptions
### Phase 1: Preparation

| Task | Purpose |
|------|---------|
| Create patch staging directory | Sets up temporary directory for patches |
| Record pre-patch OPatch lsinventory | Captures baseline installed patches for diagnostic purposes |

### Phase 2: OPatch Upgrade

| Task | Purpose |
|------|---------|
| Check current OPatch version | Verifies if upgrade needed |
| Copy OPatch zip to target | Transfers new OPatch version from source to server |
| Back up existing OPatch | Preserves old version for rollback |
| Unzip new OPatch | Installs new OPatch version |
| Verify upgraded OPatch version | Confirms upgrade successful |

### Phase 3: Patch Staging

| Task | Purpose |
|------|---------|
| Copy Release Update zip | Downloads RU patch |
| Copy RUR zip | Downloads RUR patch (optional) |
| Copy one-off patch zips | Downloads Non-Primary DB patches (JVM, JDK, etc) |
| Unzip patches | Extracts patches for application |

### Phase 4: Conflict Detection

| Task | Purpose |
|------|---------|
| Check RU conflicts | Verifies RU patch compatibility |
| Check one-off patch conflicts | Verifies one-off patch compatibility |

### Phase 5: DB Shutdown

| Task | Purpose |
|------|---------|
| Stop Oracle listener | Disables database connections |
| Read active SIDs from /etc/oratab | Identifies running databases |
| Shutdown Oracle DB (immediate) | Stops database with no checkpoint |

### Phase 6: Patch Database Software

| Task | Purpose |
|------|---------|
| Apply Release Update | Applies RU patch |
| Apply RUR | Applies RUR patch (if enabled) |
| Apply one-off patches | Applies custom patches (if any) |

### Phase 7: Startup & Datapatch

| Task | Purpose |
|------|---------|
| Start Oracle DB after patching | Brings database online |
| Start Oracle listener | Re-enables connections |
| Run datapatch | Applies database schema changes |

### Phase 8: Verification & Cleanup

| Task | Purpose |
|------|---------|
| OPatch lsinventory after patching | Captures final patch inventory |
| Confirm RU patch installed | Verifies successful patch installation |
| Remove patch zips | Cleans up temporary files |

## Output Files

The role creates the following files in `oracle_patch_stage_dir`:

```
/tmp/oracle_patches
├── YYYYMMDD_hhmm_pre_patch_lsinventory.txt       # Pre-patch inventory report
├── YYYYMMDD_hhmm_post_patch_lsinventory.txt      # Post-patch inventory report
├── 34545844/                                     # Extracted RU patch
├── 34668163/                                     # Extracted RUR patch
└── 12345678/                                     # Extracted one-off patches
```

Patch zip files are deleted after extraction and application.

## Rollback
### Manual Rollback Steps

If patching fails, rollback is manual:

1. **Restore OPatch** (if upgraded):
   ```bash
   mv $ORACLE_HOME/OPatch $ORACLE_HOME/OPatch.new
   mv $ORACLE_HOME/OPatch.bak.YYYYMMDDHHMMSS $ORACLE_HOME/OPatch
   ```

2. **Restore from RMAN backup** (if available):
   ```bash
   # Use Cohesity to restore database from pre-patch backup
   ```

3. **Manual opatch rollback**:
   ```bash
   cd $ORACLE_HOME/OPatch
   ./opatch rollback -id <patch_id>
   ```

## Error Handling

The role includes safeguards:

- **Conflict checking** – Stops before shutdown if conflicts detected
- **Version assertions** – Fails if OPatch version doesn't match expected
- **Patch verification** – Confirms patches in final inventory
- **Datapatch validation** – Displays output for manual review

### Common Issues

**OPatch version mismatch**
```
FAILED – Assertion failed: OPatch version mismatch
```
Solution: Verify `oracle_opatch_version_expected` matches patch requirements.

**Patch not found in inventory**
```
FAILED – Patch not found in lsinventory after apply!
```
Solution: Check `oracle_ru_patch_id` and patch zip filename match.

**Conflict check failure**
```
FAILED – OPatch conflict check returned error
```
Solution: Review conflict output, resolve incompatibilities, or set `oracle_opatch_conflict_check: false` to continue (not recommended).

**Database won't start**
```
Failed to start database
```
Solution: Log into target, review alert log at `$ORACLE_BASE/diag/rdbms/*/[SID]/trace/alert_*.log`


## Author

Jason Johnson 

Last Updated: 2026/05/27
