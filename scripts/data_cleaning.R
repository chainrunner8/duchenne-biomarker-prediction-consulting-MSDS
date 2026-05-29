
# This script slices out the visits after LoA and handles inconsistencies in the selected data.
# For this script to work properly, please create a folder named "data" in the root
# directory of the repository, and put the original data file in this "data" folder.

data = read.csv('data/data.csv')
# View(data)

# in this section, the data is grouped by patient, and all the rows after an
# NSAA_tot value of 0 (where applicable) are discarded, and the rest of the rows
# until LoA is preserved. The patients that did not reach LoA during their follow-up have
# their rows preserved as well (ambulant_patients).
# The NAs that remain after this process are also preserved.

ambulant_patients = data |> group_by(Patient_ID) |>
  summarise(has_zero=any(NSAA_tot==0)) |> filter(!has_zero|is.na(has_zero))
(ambulant_patients_id = ambulant_patients$Patient_ID)

# step 1: handle special case of patients 1 and 33 (missing visit: LoA but no NSAA_tot=0)
# step 2: extract the rows of the patients without LoA: new df_ambulant
# step 3: slice out the NAs after LoA of the remaining patients: new df_until_LoA
# step 4: merge the 2 df's: clean data.

# step 1 and 2:
df_ambulant = subset(data, Patient_ID %in% ambulant_patients_id)
(idx_to_discard = which(df_ambulant$Patient_ID==33 & df_ambulant$LoA==1))
df_ambulant = df_ambulant[-idx_to_discard,]
# View(df_ambulant)

# step 3:
df_until_LoA = subset(data, !Patient_ID %in% ambulant_patients_id)
df_until_LoA = df_until_LoA |> group_by(Patient_ID) |> slice(1:which(NSAA_tot==0))

# step 4:
df_final = rbind(df_ambulant, df_until_LoA)
df_final = df_final[order(df_final$Patient_ID, df_final$age),]
rownames(df_final) = NULL
# View(df_final)
write.csv(df_final, 'data/data_up_to_LoA.csv', row.names = F)
