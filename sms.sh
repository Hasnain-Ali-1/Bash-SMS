#!/bin/bash

#Name: Hasnain Ali
#ID: JL69013
#Class: CMSC 433, SU23
#Prof: Dixon
#Filename: sms.sh

# if just help was entered
if [[ ($1 = "help") && (-z "$2") ]]; then
    echo -e
    echo -e "Typing */sms.sh help* (without the asterisks) prints a synopsis of available commands.\n"
    echo -e "Typing */sms.sh send 123 456 "\""Hello""\"* (without the asterisks) would send a message from phone number 123 to phone number 456 that says "\""Hello""\".
Follow this pattern for other numbers/messages (remember to place double quotes around your message).\n"
    echo -e "Typing */sms.sh remove 123 456* (without the asterisks) would remove all correspondences between phone numbers 123 and 456.
Follow this pattern for other phone numbers whose correspondences you wish to remove.\n"
    echo -e "Typing */sms.sh search "\""you""\" --message* (without the asterisks) would look for all messages that have "\""you""\" in it.
Follow this pattern for other words/phrases you wish to search for (remember to place double quotes around your message).\n"
    echo -e "Typing */sms.sh search 123 --destination* (without the asterisks) would look for all messages addressed to the number 123.
Follow this pattern for other numbers you wish to use.\n"
    echo -e "Typing */sms.sh search "\""you""\" --message 123 --destination* (without the asterisks) would look for all messages addressed to the number 123 that have "\""you""\" in it.
Follow this pattern for other words/phrases/numbers you wish to search for (remember to place double quotes around your message).\n"
     echo -e "Typing */sms.sh search 123 --destination "\""you""\" --message* (without the asterisks) does the exact same thing as the previous command.\n"
# if send is the command entered, and the second, third, and fourth commands are not empty
elif [[ (($1 = "send") && (! -z "$2") && (! -z "$3") && (! -z "$4") && (-z "$5")) ]]; then
    # if the .messages directory does not exist, creates it
    if [[ ! -d ~/.messages ]]; then
	mkdir ~/.messages
    fi
    sendNumber=$2
    destNumber=$3
    message=$4
    cd ~/.messages
    # adds the messages to it's respective log
    echo "o;$message;@${destNumber//-}" >> "${sendNumber//-}".txt
    echo "i;$message;@${sendNumber//-}" >> "${destNumber//-}".txt
# if remove is the command entered, and the second and third commands are not empty
elif [[ (($1 = "remove") && (! -z "$2") && (! -z "$3") && (-z "$4")) ]]; then
    # checks to see if the .messages drirectory exists
    if [[ -d ~/.messages ]]; then
	echo -e
	read -p "Are you sure you wish to delete the chain between these two numbers? (enter y or n): " choice
	# input validation
	while [[ (($choice != "y") && ($choice != "n")) ]]
	do
	    echo -e
	    read -p "Are you sure you wish to delete the chain between these two numbers? (enter y or n): " choice
	done
	echo -e
	# if the user wishes to delete after confirmation
	if [[ ($choice = "y") ]]; then
	    number1=$2
	    number2=$3
	    cd ~/.messages
	    # checks to see if both numbers have messages
	    if [[ -e "${number1//-}".txt ]] && [[ -e "${number2//-}".txt ]]; then
		# the following section is for looking thorugh the logs for number 1
		# looks through the logs for number 1 and adds the lines without number 2 to a temp file
		while read line
		do
		    if ! [[ $line =~ "${number2//-}" ]]; then
			echo "$line" >> temp_file1.txt
		    fi
		done < "${number1//-}".txt
		# If there is a temp file for number 1, overwrites the log for number 1 with its data
		if [[ -e temp_file1.txt ]]; then
		    while read line
		    do
			echo "$line" > "${number1//-}".txt 
		    done < temp_file1.txt
		    rm temp_file1.txt
		else
		    # This means the only items in the log for number 1 are items we wish to remove
		    rm "${number1//-}".txt
		fi
		# the following section is for looking thorugh the logs for number 2
		# looks through the logs for number 2 and adds the lines without number 1 to a temp file
		while read line
		do
                    if ! [[ $line =~ "${number1//-}" ]]; then
			echo "$line" >> temp_file2.txt
                    fi
		done < "${number2//-}".txt
		# If there is a temp file for number 2, overwrites the log for number 2 with its data
		if [[ -e temp_file2.txt ]]; then
                    while read line
                    do
			echo "$line" > "${number2//-}".txt
                    done < temp_file2.txt
                    rm temp_file2.txt
		else
                    # This means the only items in the log for number 2 are items we wish to remove
                    rm "${number2//-}".txt
		fi
	    else
		echo "One or both numbers don't have any messages"
		echo -e
	    fi
	fi
    else
	echo "There are no messages that can be deleted"
    fi
# if search is the first argument
elif [[ ($1 = "search") ]]; then
    # if the .messages directory exists
    if [[ -d ~/.messages ]]; then
	# if just the fromNumber is given
	if [[ (! -z "$2") && (-z "$3") ]]; then
	    fromNumber=$2
	    cd ~/.messages
	    # if there are text records for the fromNumber
	    if [[ -e "${fromNumber//-}".txt ]]; then
		echo -e
		printf "%-15s %-15s %-35s\n" From To Message
		echo "-------------------------------------------------------"
		while read line
		do
		    if [[ $line =~ ^o ]]; then
			IFS=';' read -r -a array <<< $line
			printf "%-15s %-15s %-35s\n" "${fromNumber//-}" "${array[2]:1}" "${array[1]}"
		    fi
                done < "${fromNumber//-}".txt
		echo -e
	    else
		echo -e
		echo "There are no messages from this number"
		echo -e
	    fi
	# if two flags were given, with the third being --message
	elif [[ ((! -z "$2") && (! -z "$3") && ($3 == "--message") && (-z "$4")) ]]; then
	    message=$2
	    echo -e
	    printf "%-15s %-15s %-35s\n" From To Message
            echo "-------------------------------------------------------"
	    for file in ~/.messages/*; do
		while read line
                do
                    if [[ $line =~ ^o ]] && [[ $line =~ "$message" ]]; then
			fromNumber="${file##*/}"
			fromNumber=${fromNumber:0:${#fromNumber}-4}
                        IFS=';' read -r -a array <<< $line
                        printf "%-15s %-15s %-35s\n" "$fromNumber" "${array[2]:1}" "${array[1]}"
                    fi
                done < "$file"
	    done
	    echo -e
	# if two flags were given, with the third being --destination
        elif [[ ((! -z "$2") && (! -z "$3") && ($3 == "--destination") && (-z "$4")) ]]; then
	    destNumber=$2
	    echo -e
	    printf "%-15s %-15s %-35s\n" From To Message
            echo "-------------------------------------------------------"
            for file in ~/.messages/*; do
                while read line
                do
                    if [[ $line =~ ^o ]] && [[ $line =~ "${destNumber//-}" ]]; then
                        fromNumber="${file##*/}"
                        fromNumber=${fromNumber:0:${#fromNumber}-4}
                        IFS=';' read -r -a array <<< $line
                        printf "%-15s %-15s %-35s\n" "$fromNumber" "${array[2]:1}" "${array[1]}"
                    fi
                done < "$file"
            done
	    echo -e
	# if four flags were given, with the third being --message and the fifth being --destination
	elif [[ ((! -z "$2") && (! -z "$3") && ($3 == "--message") && (! -z "$4") && (! -z "$5") && ($5 == "--destination") && (-z "$6")) ]]; then
            message=$2
	    destNumber=$4
	    echo -e
	    printf "%-15s %-15s %-35s\n" From To Message
            echo "-------------------------------------------------------"
            for file in ~/.messages/*; do
                while read line
                do
                    if [[ $line =~ ^o ]] && [[ $line =~ "${destNumber//-}" ]] && [[ $line =~ "$message" ]]; then
                        fromNumber="${file##*/}"
                        fromNumber=${fromNumber:0:${#fromNumber}-4}
                        IFS=';' read -r -a array <<< $line
                        printf "%-15s %-15s %-35s\n" "$fromNumber" "${array[2]:1}" "${array[1]}"
                    fi
                done < "$file"
            done
	    echo -e
	# if four flags were given, with the third being --message and the fifth being --destination
        elif [[ ((! -z "$2") && (! -z "$3") && ($3 == "--destination") && (! -z "$4") && (! -z "$5") && ($5 == "--message") && (-z "$6")) ]]; then
            message=$4
            destNumber=$2
	    echo -e
            printf "%-15s %-15s %-35s\n" From To Message
            echo "-------------------------------------------------------"
            for file in ~/.messages/*; do
                while read line
                do
                    if [[ $line =~ ^o ]] && [[ $line =~ "${destNumber//-}" ]] && [[ $line =~ "$message" ]]; then
                        fromNumber="${file##*/}"
                        fromNumber=${fromNumber:0:${#fromNumber}-4}
                        IFS=';' read -r -a array <<< $line
                        printf "%-15s %-15s %-35s\n" "$fromNumber" "${array[2]:1}" "${array[1]}"
                    fi
                done < "$file"
            done
	    echo -e
	else
	    echo -e
	    echo "Not a valid command"
	    echo -e
	fi
    else
	echo -e
	echo "There are no messages that can be searched for"
	echo -e
    fi
# if the entered command is not help, add, remove, or search 
else
    echo -e
    echo "Not a valid command"
    echo -e
fi
