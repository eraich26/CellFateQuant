# CellFateQuant
Cell Fate Quantification Code

The Cell Fate Quantification code determines cell type proportions of DAPI+ human iPSC-derived midbrain neural progenitor cells from Biotek Cytation5 Cell Imaging Multimode Reader fluorescent intensities. 
To use this code, two files are required:
(1) a .xlsx file containing the raw data of fluorescent intensities from the Cytation5 
(2) a .csv file containing the all of the treatment groups included in the raw data file, with each treatment name listed in column 1 of the file.

The code determines cell type as follows:

For a given row, if the sum of the following 3 columns = 0, then the row was completely deleted from the table.

•	“Mean_2[Tsf[ZProj[GFP469,525]]]” – aka the fluorescently green cells, which is stained for the protein Nestin, a marker of a neural progenitor cell

•	“Mean_2[Tsf[ZProj[RFP 531,593]]]” – aka the fluorescently orange cells, which is stained for the protein Gfap, a marker of astrocyte cells

•	“Mean_2[Tsf[ZProj[CY5 628,685]]]” – aka the fluorescently red/dark pink cells, which is stained for the protein NeuN, a marker of mature neurons.

If the numerical value of the “Mean_2[Tsf[ZProj[RFP 531,593]]]” > the value of “Mean_2[Tsf[ZProj[GFP 469,525]]]” for a given row, then this row (cell) is defined as an astrocyte, otherwise, the remaining cells are defined as “progenitors”. No further parameters are used to define these astrocytes.

For the remaining “progenitor” rows, if “Mean_2[Tsf[ZProj[CY5 628,685]]]” > 26000, that cell is defined as a neuron. If not, it is a progenitor. However, if “Mean_2[Tsf[ZProj[GFP 469,525]]]” + “Mean_2[Tsf[ZProj[RFP 531,593]]]” for a given row = 0, and “Mean_2[Tsf[ZProj[CY5 628,685]]]” is < (or equal to) 26000, that cell is still defined as a neuron.

All remaining cells are progenitors.
