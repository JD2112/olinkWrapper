# Linear Regression Fix - February 17, 2026

## Issue

After reverting to the previous linear regression code, the results were incorrect. Instead of running regressions per protein (Assay), it was running regressions for ALL numeric columns (including metadata like `Lpnummer`, `Index`, `NPX`, `MissingFreq`, `LOD`).

## Root Cause

The reverted code was treating every numeric column as a "biomarker" and running:
```r
DependentVariable ~ NumericColumn1
DependentVariable ~ NumericColumn2
...
```

This is wrong because it doesn't filter by Assay (protein).

## Correct Behavior (Option 1)

The linear regression should:
1. **Iterate over each Assay** (protein)
2. **Filter data** for that specific protein
3. **Run regression:** `DependentVariable ~ NPX + Covariates`
4. **Extract NPX coefficient** for each protein

### Model Structure

**For each protein:**
```r
DependentVariable ~ NPX + Covariate1 + Covariate2 + ...
```

**Example:**
- Dependent Variable: Age
- Covariates: Sex, BMI
- For protein NPPB: `Age ~ NPX + Sex + BMI` (using only NPPB data)
- For protein TNNI3: `Age ~ NPX + Sex + BMI` (using only TNNI3 data)
- etc.

## What Was Fixed

### Server Logic (`server_linear_regression.R`)

1. **Check for Assay column** - Ensure data has protein identifiers
2. **Get unique assays** - `assays <- unique(df$Assay)`
3. **Filter by assay** - `assay_data <- df %>% filter(Assay == assay)`
4. **Build correct formula** - `DependentVariable ~ NPX + Covariates`
5. **Extract NPX coefficient** - `filter(term == npx_var)`
6. **Add metadata** - Include OlinkID, UniProt, Panel
7. **Format output** - Match original format with conf.int

### UI (`ui_linear_regression.R`)

1. **Added description** - Clarify what the model does
2. **Show model structure** - "DependentVariable ~ NPX + Covariates"
3. **Reorder elements** - Dependent variable first, then covariates
4. **Clarify covariates** - "Number of Covariates (optional)"

## Expected Output

The results should now match the original working version:

| Assay | OlinkID | UniProt | Panel | estimate | conf.low | conf.high | statistic | p.value | Adjusted_pval |
|-------|---------|---------|-------|----------|----------|-----------|-----------|---------|---------------|
| NPPB | OID20049 | P16860 | Cardiometabolic | -0.122 | -0.808 | 0.564 | -0.351 | 0.726 | 0.986 |
| TNNI3 | OID20050 | P19429 | Cardiometabolic | 0.476 | -0.066 | 1.018 | 1.732 | 0.085 | 0.986 |
| ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |

## Key Differences from Previous Incorrect Output

**Before (Wrong):**
- Ran regression for metadata columns (Lpnummer, Index, etc.)
- Used entire dataset for each regression
- No protein-specific filtering

**After (Correct):**
- Runs regression only for proteins (Assays)
- Filters data by protein before regression
- Includes protein metadata (OlinkID, UniProt, Panel)
- Includes confidence intervals
- Matches original working format

## Testing

To verify the fix works:
1. Select a dependent variable (e.g., Age, BMI, disease status)
2. Optionally add covariates (e.g., Sex, Treatment)
3. Choose NPX type (Raw or Z-score)
4. Run regression
5. Verify output shows:
   - One row per protein (Assay)
   - Protein metadata columns
   - Estimate, confidence intervals, p-values
   - Results sorted by p-value

---

**Fixed:** February 17, 2026
**Files Modified:**
- `app/server/server_linear_regression.R`
- `app/ui/ui_linear_regression.R`
