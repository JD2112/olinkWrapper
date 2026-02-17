# QC Warning Exclusion - Corrected Implementation

## Issue Found

The initial implementation misunderstood how Olink's `QC_Warning` column works.

### How Olink QC_Warning Actually Works

In Olink data, the `QC_Warning` column contains:
- **"PASS"** - The measurement passed QC
- **Protein name** (e.g., "BMP6", "EPHX2", "PGLYRP1") - That specific protein measurement failed QC for that sample

### What Was Wrong

The initial fix looked for `QC_Warning == "EXCLUDED"`, which doesn't exist in Olink data. This caused it to not find any QC warnings.

### Correct Implementation

The fix now:
1. **Filters rows** where `QC_Warning != "PASS"`
2. **Removes** all measurements that failed QC (protein-level failures)
3. **Keeps** all samples, but only their valid measurements

### Example

If you have:
- Sample A with measurements for proteins X, Y, Z
- Protein Y failed QC for Sample A (QC_Warning = "Y")

**Result:**
- Sample A is kept
- Measurements for proteins X and Z are kept
- Measurement for protein Y is removed

### What Gets Removed

- Individual protein measurements that failed QC
- NOT entire samples (unless all their measurements failed)
- NOT entire proteins (unless all their measurements failed)

### Summary Output

The new summary shows:
1. **Number of measurements removed** (rows with QC_Warning != "PASS")
2. **Which proteins had failures** and how many
3. **How many samples were affected** (had at least one failed measurement)
4. **Before/after counts** for samples, proteins, and total measurements

### Expected Behavior

For your dataset with BMP6, EPHX2, and PGLYRP1 failing QC:
- All samples should be retained
- Most proteins should be retained
- Only the specific failed measurements for those 3 proteins should be removed
- You should have data remaining for analysis

---

**Fixed:** February 17, 2026
**File:** `app/server/server_data_preview.R`
