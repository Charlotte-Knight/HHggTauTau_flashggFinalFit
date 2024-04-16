import sys

in_path = sys.argv[1]
out_path = sys.argv[2]

with open(in_path, "r") as f:
  datacard = f.read()

replace_dict = {
  "HHggTauTaukl1_2016_hgg": "ggHH_kl_1_kt_1_2016_hgghtt",
  "HHggTauTaukl2p45_2016_hgg": "ggHH_kl_2p45_kt_1_2016_hgghtt",
  "HHggTauTaukl5_2016_hgg": "ggHH_kl_5_kt_1_2016_hgghtt",
  "HHggWWdileptonickl1_2016_hgg": "ggHH_kl_1_kt_1_2016_hgghwwll",
  "HHggWWdileptonickl2p45_2016_hgg": "ggHH_kl_2p45_kt_1_2016_hgghwwll",
  "HHggWWdileptonickl5_2016_hgg": "ggHH_kl_5_kt_1_2016_hgghwwll",
  "HHggWWsemileptonickl1_2016_hgg": "ggHH_kl_1_kt_1_2016_hgghwwql",
  "HHggWWsemileptonickl2p45_2016_hgg": "ggHH_kl_2p45_kt_1_2016_hgghwwql",
  "HHggWWsemileptonickl5_2016_hgg": "ggHH_kl_5_kt_1_2016_hgghwwql"
}
for key, item in replace_dict.copy().items():
  replace_dict[key.replace("2016", "2017")] = item.replace("2016", "2017")
  replace_dict[key.replace("2016", "2018")] = item.replace("2016", "2018")

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

datacard_replacement = "\n".join(new_datacard_lines)

with open(out_path, "w") as f:
  f.write(datacard_replacement)

