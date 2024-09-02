
# load necessary libraries
library(readxl)
library(dplyr)

# read the data from the Excel file
RawData = read_excel("/Users/eraich/Downloads/Copy of BioRep4_quant_plus_cAMP_round2.xlsx") # Cytation 5 data output 
treatment = read.csv("/Users/eraich/Downloads/Practice.csv",header=FALSE) # .csv file listing treatment names in column 1
names(treatment)[1]<-paste("Treatment") # renaming treatment variable column

# convert data to matrix
rawdata = as.matrix(RawData) 

# find the indices where the first column equals 1 (indicating where the start of each table/"image" is)
num_images = which(rawdata[, 1] == 1)

# initialize an empty list to store the tables as a data list
tables = list()

# loop through each image, isolate the data, and store it in the list
for (i in 1:(length(num_images) - 1)) {
  image = rawdata[num_images[i]:(num_images[i + 1] - 1), ]
  tables[[i]] = image
}

# process each table
for (i in 1:length(tables)) {
  image = tables[[i]]
  
  # remove rows with NaN in any column and rows where the first column is not numeric (isolate only the data for ith image)
  image = na.omit(image)
  image = image[!is.na(as.numeric(image[,1])),]
  
  # add an extra column for labeling the cell type
  image = cbind(image, rep("", nrow(image)))
  
  # label the cell types based on the conditions
  j = 1
  while (j <= nrow(image)) {
    if (as.numeric(image[j, 6]) == 0 && as.numeric(image[j, 8]) == 0 && as.numeric(image[j, 10]) == 0) {
      image = image[-j, ] # delete the row if mean_GFP, mean_RFP, and mean_CY5 = 0 (columns 6, 8, and 10 = 0)
    } else {
      if (as.numeric(image[j, 8]) > as.numeric(image[j, 6])) {
        image[j, 11] = "astrocyte" # if mean_RFP > mean_GFP, then cell is an astrocyte (if column 8 > 6)
      } else if (as.numeric(image[j, 10]) > 26000) {
        image[j, 11] = "neuron" # if mean_CYP > 26,000, then cell is a neuron (if column 10 > 26,000)
      } else if (as.numeric(image[j, 6]) == 0 && as.numeric(image[j, 8]) == 0) {
        image[j, 11] = "neuron" # if mean_GFP + mean_RFP = 0 and mean_CYP <= 26,000, cell is a neuron (if columns 6 & 8 are both 0, even if column 10 < 26000)
      } else {
        image[j, 11] = "progenitor" # if none of these conditions are met, cell is a progenitor
      }
      j = j + 1
    }
  }
  tables[[i]] = image
}

# initialize summary table outputting total # of cells, # of each cell type and % of each cell type
summary_table = data.frame(Treatment = treatment,Total_Cell_Count = integer(length(tables)),Astrocyte_Count = integer(length(tables)),
                            Neuron_Count = integer(length(tables)),Progenitor_Count = integer(length(tables)),Astrocyte_Percent = numeric(length(tables)),
                            Neuron_Percent = numeric(length(tables)),Progenitor_Percent = numeric(length(tables)))

# input data from each image into summary table
for (i in 1:length(tables)) {
  image = tables[[i]]
  total_rows = nrow(image) # total number of rows
  astrocyte_count = sum(image[, 11] == "astrocyte") # sum the total number of rows labeled as astrocyte
  neuron_count = sum(image[, 11] == "neuron") # sum the total number of rows labeled as neuron
  progenitor_count = sum(image[, 11] == "progenitor") # sum the total number of rows labeled as progenitor
  
  summary_table[i, "Total_Cell_Count"] = total_rows
  summary_table[i, "Astrocyte_Count"] = astrocyte_count
  summary_table[i, "Neuron_Count"] = neuron_count
  summary_table[i, "Progenitor_Count"] = progenitor_count
  # calculate percentages of each cell type out of the total number of cells
  summary_table[i, "Astrocyte_Percent"] = (astrocyte_count / total_rows) * 100
  summary_table[i, "Neuron_Percent"] = (neuron_count / total_rows) * 100
  summary_table[i, "Progenitor_Percent"] = (progenitor_count / total_rows) * 100
}
print(summary_table)
