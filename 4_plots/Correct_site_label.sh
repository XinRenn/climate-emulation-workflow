# 1.删掉 site_LB, site_LD,
# 2.把site_LC改成site_LB, 
# 3.site_LE改成site_LC
# 4.rm site_S[BCDEFGI]，只保留SA和SH
# 5.把SH改为SB
file_path="/Users/bo20541/Library/CloudStorage/OneDrive-UniversityofBristol/TONIC-Oligocene/NWS_emulation/prediction/results_on_sites/low_reso_sites"
to_be_del=("LB" "LD" "SB" "SC" "SD" "SE" "SF" "SG" "SI")
for item in "${to_be_del[@]}"; do
  rm -r "${file_path}/site_${item}"
done
mv ${file_path}/site_LC ${file_path}/site_LB
mv ${file_path}/site_LE ${file_path}/site_LC
mv ${file_path}/site_SH ${file_path}/site_SB

# 做完上面的步骤后
for item in ${file_path}/site_LB/* ; do
    mv "$item" "${item%???????}LB.txt"
done

for item in ${file_path}/site_LC/* ; do
    mv "$item" "${item%??????}LC.txt"
done
    
for item in ${file_path}/site_SB/* ; do
    mv "$item" "${item%??????}SB.txt"
done
