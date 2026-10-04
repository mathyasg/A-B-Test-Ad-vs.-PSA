"""
Marketing A/B Test – Statistical Analysis & Visualisation
"""

import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import chi2_contingency

# -------------------------------------------------
# 1. Contingency table (from SQL Section 5)
# -------------------------------------------------
# ad:  converted, not_converted
# psa: converted, not_converted
contingency = np.array([
    [14423, 550154],   # ad
    [420,   23104]     # psa
])

chi2, p, dof, expected = chi2_contingency(contingency)

print("=" * 50)
print("CHI-SQUARE TEST RESULTS")
print("=" * 50)
print(f"Chi-square statistic : {chi2:.2f}")
print(f"Degrees of freedom   : {dof}")
print(f"p-value              : {p:.2e}")
print()
if p < 0.001:
    print("→ Result is statistically significant (p < 0.001)")
else:
    print("→ Result is not statistically significant at 0.001 level")
print("=" * 50)


# -------------------------------------------------
# 2. Key metrics for plotting
# -------------------------------------------------
ad_converted   = 14423
ad_total       = 14423 + 550154
psa_converted  = 420
psa_total      = 420 + 23104

ad_rate  = ad_converted  / ad_total * 100
psa_rate = psa_converted / psa_total * 100


# -------------------------------------------------
# 3. Visualisation – Conversion Rate Comparison
# -------------------------------------------------
fig, ax = plt.subplots(figsize=(8, 5))

groups = ['PSA (Control)', 'Ad (Treatment)']
rates  = [psa_rate, ad_rate]
colors = ['#6c757d', '#0d6efd']

bars = ax.bar(groups, rates, color=colors, width=0.55, edgecolor='white')

# Add value labels on bars
for bar, rate in zip(bars, rates):
    height = bar.get_height()
    ax.annotate(f'{rate:.2f}%',
                xy=(bar.get_x() + bar.get_width() / 2, height),
                xytext=(0, 6),
                textcoords="offset points",
                ha='center', va='bottom',
                fontsize=12, fontweight='bold')

ax.set_ylabel('Conversion Rate (%)', fontsize=12)
ax.set_title('Conversion Rate: Ad vs PSA', fontsize=14, fontweight='bold', pad=15)
ax.set_ylim(0, max(rates) * 1.25)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.yaxis.grid(True, linestyle='--', alpha=0.4)
ax.set_axisbelow(True)

plt.tight_layout()
plt.savefig('images/conversion_rates.png', dpi=150, bbox_inches='tight')
print("Saved: images/conversion_rates.png")
plt.close()


print("\nDone.")