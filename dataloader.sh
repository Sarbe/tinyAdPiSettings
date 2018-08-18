for file in $logFIles
do
	echo "$file"
	curl -F "upload=@$file;filename=$file" $uploadURL
	rc=$?
	
	if [ "$rc" -eq 0 ] 
	then
		echo "Audit log file :$file uploaded successfully @logDt" >> $log
		#rm $file
	else
		echo "Error while uploadig file :$file"
	fi
done