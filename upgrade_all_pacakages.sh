#!/bin/bash

# See https://unix.stackexchange.com/questions/17040/how-to-diff-files-ignoring-comments-lines-starting-with

set -e

for dir in packages/*
do 
    source $dir/vars
    git_repository_url=${GIT_REPO_URL%/} 

    echo "Upgrade ${dir##*/}:"
    
	if [[ $git_repository_url != "" ]]; then
		echo "Pull sources from $git_repository_url"
		git pull $dir
	fi

	# Upgrade README.md
    res_diff="$(diff -y --suppress-common-lines src/README.md $dir/README.md | sed 's/^.*<.*>.*//')"
    	
    if [[ $res_diff != "" ]]; then
		echo "  Update README.md"
    	cp -f src/README.md $dir/README.md
    else
    	echo "  README.md up to date"
	fi

	# Upgrade README.md
    res_diff="$(diff -y --suppress-common-lines src/LICENSE $dir/LICENSE)"
    	
    if [[ $res_diff != "" ]]; then
		echo "  Update LICENSE"
    	cp -f src/LICENSE $dir/LICENSE
    else
    	echo "  LICENSE up to date"
	fi

    # Upgrade manifest.json
  	res_diff="$(diff -y --suppress-common-lines src/manifest.json $dir/manifest.json | sed 's/^.*<.*>.*//')"

  	if [[ $res_diff != "" ]]; then

    	#diff -y --suppress-common-lines src/${file##*/} $file 

    	echo "  Update manifest.json"
    	#rm -f manifest.json
    	cp -f src/manifest.json $dir/manifest.json
    	sed -i "s@<APP>@$APP@g" $dir/manifest.json
		sed -i "s@<ID>@$ID@g" $dir/manifest.json
		sed -i "s@<URL>@$URL@g" $dir/manifest.json
		sed -i "s@<LICENCE>@$LICENCE@g" $dir/manifest.json
		sed -i "s@<NAME>@$NAME@g" $dir/manifest.json
		sed -i "s@<EMAIL>@$EMAIL@g" $dir/manifest.json
		sed -i "s@<VERSION>@$VERSION@g" $dir/manifest.json
		echo "Done"
	else
    	echo "  mannifest.json up to date"
	fi

    # Upgrade build directory
    echo "  Upgrade build directory..." 
	for file in $dir/build/*
	do	
		res_diff="$(diff -y --suppress-common-lines src/build/${file##*/} $file)"
		
		if [[ $res_diff != "" ]]; then

			#diff -y --suppress-common-lines src/build/${file##*/} $file

			echo "  Update ${file##*/}"
			#rm -f TODO
    		cp -f src/build/${file##*/} $file
    		echo "Done"

    	else
    		echo "    ${file##*/} is up to date"
    	fi 
    done

    # Upgrade conf directory
    echo "  Upgrade conf directory..." 
	for file in $dir/conf/*
	do	
		res_diff="$(diff -y --suppress-common-lines src/conf/${file##*/} $file)"

		if [[ $res_diff != "" ]]; then

			#diff -y --suppress-common-lines src/conf/${file##*/} $file

			echo "  Update ${file##*/}"
			#rm -f TODO
    		cp -f src/conf/${file##*/} $file
    		echo "Done"

    	else
    		echo "    ${file##*/} is up to date"
    	fi
    done

    # Upgrade scripts directory
    echo "  Upgrade scripts directory..." 
	for file in $dir/scripts/*
	do
  		res_diff="$(diff -y --suppress-common-lines src/scripts/${file##*/} $file | sed 's/^.*<.*>.*//')"
  		
    	if [[ $res_diff != "" ]]; then

    		#diff -y --suppress-common-lines src/scripts/${file##*/} $file 

    		case $file in
    		
			"install")
				# Generate install scripts
				echo "    Update ${file##*/}"
    			#rm -f $file
    			cp -f src/scripts/${file##*/} $file
				sed -i "s@<REDIRECTED_PORT>@$REDIRECTED_PORT@g" $file
				sed -i "s@<NOT_REDIRECTED_PORTS>@$NOT_REDIRECTED_PORTS@g" $file
				sed -i "s@<MULTI_USERS>@$MULTI_USERS@g" $file
				sed -i "s@<DOKERHUB_IMAGE>@$DOKERHUB_IMAGE@g" $file
				echo "Done"
				;;

			"upgrade")
				# Generate upgrade scripts
				echo "    Update ${file##*/}"
    		    #rm -f $file
    		    cp -f src/scripts/${file##*/} $file
				sed -i "s@<REDIRECTED_PORT>@$REDIRECTED_PORT@g" $file
				sed -i "s@<NOT_REDIRECTED_PORTS>@$NOT_REDIRECTED_PORTS@g" $file
				sed -i "s@<MULTI_USERS>@$MULTI_USERS@g" $file
				sed -i "s@<DOKERHUB_IMAGE>@$DOKERHUB_IMAGE@g" $file
				echo "Done"
				;;

			"remove")
				# Generate remove scripts
				echo "    Update ${file##*/}"
    		    #rm -f $file
    		    cp -f src/scripts/${file##*/} $file
				echo "Generate remove script..."
				sed -i "s@<NOT_REDIRECTED_PORTS>@$NOT_REDIRECTED_PORTS@g" $file
				sed -i "s@<DOKERHUB_IMAGE>@$DOKERHUB_IMAGE@g" $file
				echo "Done"
				;;

			*)
				echo "    Update ${file##*/}"
				#rm -f TODO
    			cp -f src/scripts/${file##*/} $file
    			echo "Done"
    			;;

    	    esac
		else
			echo "    ${file##*/} is up to date"
 		fi
	done

	# Check package with linter
	echo ""
    echo "Check $dir package with linter:"
    ./package_linter/package_linter.py $dir

    # Push git repository
	if [[ $git_repository_url != "" ]]; then
		echo "Push update to $git_repository_url"
		git add ${package_path}/*
		git commit ${package_path} -m "Upgrade packages"
		git push  origin master
	fi

done	



