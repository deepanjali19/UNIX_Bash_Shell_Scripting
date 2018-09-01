flag=0

if [ $# == 0 ]
then
	flag=1 
	filename=$(pwd)
elif [[ $# == 1 && -e $1 ]]
then
	flag=1
	filename=$1
elif [[ $# == 1 && ! -e $1 ]]
then	
	echo "$1 is not a valid filename">&2
	exit 1
else
	echo "Usage: vchmod [ filename ]">&2
	exit 1
fi

if [ $flag == 1 ]
then
	levels=0
	current_level=0
	total_hor=9
	cur_hor=9
	h=6
	clear


	printf "  Owner   Group   Other   Filename\n  -----   -----   -----   --------\n\n"

	for file in /$(echo $filename|tr '/' ' ')
	do
		((levels++))
		current_level=$levels

		if [ -d $file ]
		then	
			cd $file
			working="ls -ld $(pwd)"
		else
			working="ls -l $file"
		fi

		read=$($working|cut -c1-4|sed 's/./& /g')
               	write=$($working|cut -c5-7|sed 's/./& /g')
               	execute=$($working|cut -c8-10|sed 's/./& /g')

		printf "%7s%8s%8s%3s%-30s\n\n" "$read" "$write" "$execute" " " "$file"
	done

	tput cup $(($(tput lines) - 4)) 0 
	printf "Valid keys: k (up), j (down): move between filenames\n\t    h (left), l (right): move between permissions\n\t    r, w, x, -:change permissions;   q: quit"
	tput cup $(($current_level*2 +1)) 27

	key=
	while [ "$key" != "q" ]
	do
		print_level=0

		for file in /$(echo $filename|tr '/' ' ')
		do
			((print_level++))

			if [ -d $file ]
			then
				cd $file
				working2="ls -ld $(pwd)"
			else
				working2="ls -l $file"
			fi

			link=$($working2|sed -r 's/ +/ /g'|cut -d' ' -f2)
                       	own=$($working2|sed -r 's/ +/ /g'|cut -d' ' -f3)
                       	group=$($working2|sed -r 's/ +/ /g'|cut -d' ' -f4)
                       	size=$($working2|sed -r 's/ +/ /g'|cut -d' ' -f5)                      	
			modify=$($working2|sed -r 's/ +/ /g'|cut -d' ' -f6-8)

			if [ $print_level == $current_level ]
			then
				printf "\n  Links: $link  Owner: $own  Group: $group  Size: $size  Modified: $modify"
		 		tput cup $(($current_level*2 + 1)) $(($cur_hor*2+$h))
			fi
		done
   		key=
   		read -s -n 1 -r key 
		
 tput cup $(($current_level*2 +2)) 0
 
		if [[ "$key" == "u" && "$current_level" > 1 ]]
		then
			((current_level--))
   		elif [[ "$key" == "d" && "$current_level" < "$levels" ]]
		then
			((current_level++))
   		fi

		if [[ "$key" == "u" || "$key" == "d" ]]
		then
			tput el
		fi
		
		if [[ "$key" == "h" && "$cur_hor" > 0 ]]
		then 
			((cur_hor--))		
		fi

		if [[ "$key" == "l" && "$cur_hor" < 9 ]]
                then
                        ((cur_hor++))
              fi

	 if (( "$cur_hor" == 9 ))
        then
        	h=6      
 	elif (( "$cur_hor" >= 0 && "$cur_hor" <= 2 ))
        then
                h=0
        elif (( "$cur_hor" >= 3 && "$cur_hor" <= 5 ))
        then
                h=2
        elif (( "$cur_hor" >= 6 && "$cur_hor" <= 8 ))
        then
                h=4
        fi

tput cup $(($current_level*2+1)) $(($cur_hor*2+$h))

done
	tput cup $(tput lines) 0
	exit 0
fi
