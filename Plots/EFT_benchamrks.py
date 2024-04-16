import matplotlib.pyplot as plt
import uproot
import sys

def getLimits(fname):
  f = uproot.open(fname)
  return f["limit/limit"].array()

limit_files = {fname.split("bm")[1].split(".")[0]: fname for fname in sys.argv[1:]}

#bms = limit_files.keys()
bms = ["1", "2", "3", "4", "5", "6", "7", "8", "8a", "9", "10", "11", "12"]

limits = {bm: getLimits(fname) for bm,fname in limit_files.items()}

print(limits)

xticks = []
labels = []

for i, bm in enumerate(bms):
  xticks.append(i)
  labels.append(bm)

  w = 0.4

  x = [i-w, i+w]

  plt.plot(x, [limits[bm][2], limits[bm][2]], 'k', linestyle="dashed")
  plt.plot(x, [limits[bm][5], limits[bm][5]], 'k')
  plt.fill_between(x, limits[bm][0], limits[bm][4], color=(1, 0.8, 0))
  plt.fill_between(x, limits[bm][1], limits[bm][3], color=(0, 0.8, 0))

plt.xticks(xticks, labels)
plt.yscale("log")

plt.savefig("eft.png")
