"""Author-only figures, derived from the same café CSV used by learners.

Run from the repository root: python authoring/visuals.py
Students do not need Python or matplotlib.
"""
from pathlib import Path
import csv
from collections import defaultdict
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.font_manager import FontProperties, fontManager
from matplotlib.ticker import MaxNLocator

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "authoring/assets/v4"
BLUE, ORANGE, INK = "#4E73FF", "#FF9A3C", "#1A1F4D"

def make_bar(labels, values, title, filename, average=False):
    fig, ax = plt.subplots(figsize=(8, 3.3))
    fig.patch.set_facecolor("white")
    bars = ax.bar(labels, values,
                  color=[ORANGE if v == max(values) else BLUE for v in values],
                  width=.57)
    for bar, value in zip(bars, values):
        ax.annotate(f"{value:g}", (bar.get_x()+bar.get_width()/2, value),
                    xytext=(0, 7), textcoords="offset points", ha="center",
                    color=INK, fontsize=17, fontweight="bold")
    if average:
        mean = sum(values)/len(values)
        ax.axhline(mean, color="#A34A00", linestyle="--", linewidth=1.6)
        ax.text(.98, mean+1, f"Moyenne : {mean:g} TND", transform=ax.get_yaxis_transform(),
                ha="right", va="bottom", color="#A34A00", fontsize=12,
                bbox=dict(facecolor="white", edgecolor="none", pad=2))
    ax.set_title(title, loc="left", fontsize=17, fontweight="bold", pad=20)
    ax.set_ylabel("Chiffre d’affaires (TND)", fontsize=13)
    ax.set_ylim(0, max(values)*1.32)
    ax.yaxis.set_major_locator(MaxNLocator(integer=True, nbins=4))
    ax.tick_params(axis="both", length=0, labelsize=13, pad=8, colors=INK)
    ax.set_axisbelow(True)
    ax.grid(axis="y", color="#E6E4EE", linewidth=.8)
    for spine in ax.spines.values(): spine.set_visible(False)
    fig.tight_layout(pad=1.1)
    fig.savefig(OUT/filename, format="svg", facecolor="white")
    plt.close(fig)

def main():
    OUT.mkdir(parents=True, exist_ok=True)
    font = ROOT/"authoring/fonts/Inter-400.ttf"
    fontManager.addfont(str(font))
    plt.rcParams.update({"font.family": FontProperties(fname=font).get_name(),
                         "text.color": INK, "axes.labelcolor": INK,
                         "svg.fonttype": "path"})
    with (ROOT/"data/orders_clean_reference.csv").open(newline="", encoding="utf-8") as f:
        rows = list(csv.DictReader(f))
    days, products = defaultdict(float), defaultdict(float)
    for row in rows:
        revenue = float(row["quantite"]) * float(row["prix_unitaire"])
        days[row["date"]] += revenue
        products[row["produit"]] += revenue
    assert sum(days.values()) == 100 and len(rows) == 12
    make_bar([f"Jour {i}" for i in range(1,5)], list(days.values()),
             "Quatre jours, un total de 100 TND", "chiffre_affaires_jours.svg")
    make_bar([f"Jour {i}" for i in range(1,5)], list(days.values()),
             "Partager 100 TND en quatre parts égales", "moyenne_jours.svg", average=True)
    product_names = sorted(products)
    make_bar([{"Cafe":"Café", "The":"Thé"}.get(k,k) for k in product_names],
             [products[k] for k in product_names],
             "Quel produit apporte le plus de ventes ?", "chiffre_affaires_produits.svg")

if __name__ == "__main__": main()
