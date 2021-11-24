#BAMfolder = "BAMS/"
echo "$BAMfolder"
for i in `cat BAMS/TumorNormal_matched_Conpair.txt`
 do
 #echo $i
 IFS=$','
 read -ra ADDR <<< "$i"
  for j in "${ADDR[@]}"
  do
  if echo "$j" | grep -q "T.sorted.bam"
   then nameT="BAMS/""$j"
  fi
  if echo "$j" | grep -q "N.sorted.bam"
   then nameN="BAMS/""$j"
  fi
 done
 echo $nameT
 echo $nameN
 sh runConpair_H_option.sh -t $nameT -n $nameN -p JSREP1
done
