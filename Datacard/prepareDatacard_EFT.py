import sys

in_path = sys.argv[1]
out_path = sys.argv[2]

with open(in_path, "r") as f:
  datacard = f.read()

bms=["1", "2", "3", "4", "5", "6", "7", "8", "8a", "9", "10", "11", "12"]
template = {
  "HHggTauTauBM_YEAR_hgg": "ggHH_YEAR_hgghtt",
  "HHggWWdileptonicBM_YEAR_hgg": "ggHH_YEAR_hgghwwll",
  "HHggWWsemileptonicBM_YEAR_hgg": "ggHH_YEAR_hgghwwql"
}
replace_dict = {}
for bm in bms:
  for year in ["2016", "2017", "2018"]:
    replace_dict.update({key.replace("BM", bm).replace("YEAR", year) : item.replace("BM", bm).replace("YEAR", year) for key,item in template.items()})

datacard_lines = datacard.split("\n")
new_datacard_lines = []
for i, line in enumerate(datacard_lines):
  if line[:6] == "shapes":
    first_half = line.split("SR")[0]
    second_half = "SR".join(line.split("SR")[1:])

    second_half = second_half.replace("./Models/signal/", "shapes/")
    second_half = second_half.replace("./Models/background/", "shapes/")

    first_half_replacement = first_half
    for key, item in replace_dict.copy().items():
      if key in first_half:
        first_half_replacement = first_half.replace(key, item)
      
    line_replacement = first_half_replacement.strip().ljust(60) + "SR" + second_half
    #datacard_lines[i] = line_replacement
    new_datacard_lines.append(line_replacement)

  elif line[:7] == "process":
    line_replacement = line
    for key, item in replace_dict.copy().items():
      if key in line:
        line = line.replace(key, item)
    #datacard_lines[i] = line
    new_datacard_lines.append(line)

  elif line[:13] == "QCDscale_ggHH":
    pass

  else:
    new_datacard_lines.append(line)

for line in new_datacard_lines:
  if line[:7] == "process":
    proc_ordering = line.split()
    break

for i, line in enumerate(new_datacard_lines):
  if line[:4] == "rate":
    rates = line.split()
    
    for j in range(len(rates)):
      if "ggHH" in proc_ordering[j]:
        rates[j] = "250000.0"

    new_datacard_lines[i] = "\t".join(rates)
    break
    
datacard_replacement = "\n".join(new_datacard_lines)

with open(out_path, "w") as f:
  f.write(datacard_replacement)

