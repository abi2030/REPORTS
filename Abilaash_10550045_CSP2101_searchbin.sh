#!/bin/bash
#STUDENT NAME: Abilaash KETHEESWARAN
#STUDENT NUMBER:10550045

#To develop the script and solve the task, I validated the presence of at least one option (-l) to avoid script execution without any arguments.
#Next, I navigated to the /bin directory and copied the listing to a file in the working directory. 
#I used the getopts function to parse command-line options and arguments (Module 06). For the -s option, I searched for a specific string within file names, displayed the count of matches, 
#and printed the matching file names and sizes using grep and awk (Module 08). The -b option involved comparing file sizes based on the provided operator and byte value, and printing the matching files. 
#If the -l option was present, I searched for symbolic links, extracted their names and corresponding file names using grep extended pattern matching(module 05), and used sed for remove pattern("->").(module 07).
#Then use for loop to format the out for -l option Throughout the script,(Workshop 8)
#I implemented error handling and provided appropriate error messages. Lastly, I removed temporary files created during script execution.


RED='\033[0;31m' # to colour error messages
GREEN='\033[0;32m' # to highlight key output values
BLUE='\033[0;34m' # for output headers
NC='\033[0m' # switches off the application of a colour to oputput

#delcaring variables for headers to be used in awk formating
FILE_NAME="${BLUE}NAME${NC}"
FILE_SIZE="${BLUE}SIZE${NC}"
SYMBOLIC_FILE="${BLUE}SYMBOLIC${NC}"
FILE_POINTS="${BLUE}POINTS-TO${NC}" 

matchError="${BLUE}No match found.${NC}" #error message for no match found

SERACH_OPTION="" #store string provided by user
BYTE_OPTION="" #store comparsion type
BYTE_VALUE="" #store comparsion byte value provided by user
LINKS="" 
match_count=0 #declaring variable for couting matched value

#validting atleast one option(-l) is given
if [ $# -lt 1 ]; then
    echo -e "${RED}No option/arg(s) provided. Exiting...${NC}"
    exit 1
fi

#moving to bin directory from working directory  
dir=$(pwd)
cd 
cd /bin
ls -l > "$dir/output.txt" # coping the bin directory listing to working directory and creating text file for later use
cd 

while getopts "s:b:l" opt ;do  #s and b should accompained with argument other error message will printed
    case $opt in 
        s) 
            SERACH_OPTION=$OPTARG  #assigning argument passed by user to a variable 
            match_count=$(grep -ic "$SERACH_OPTION" $dir/output.txt) #getting number of matchs found

            if [[ $match_count -eq 0 ]]; then #exit with error message if match is 0
                echo -e $matchError
                exit 1
            
            else 
                echo -e "${GREEN}$match_count${NC} found" #print number of matches found and appropriate header 
                echo "Header" | awk 'BEGIN {variable1="'$FILE_NAME'"; variable2="'$FILE_SIZE'"} {printf "%-40s  %-20s\n", variable1, variable2}'
                echo -e "${BLUE}====================================${NC}"
                cat $dir/output.txt | grep -i "$SERACH_OPTION" | awk '{printf "%-30s %-.2f\n", $9, $5}' #reading file then pipe to getting matching string and formating using awk for output  
            fi
        ;;
        b)
            BYTE_OPTION=$OPTARG #assigning argument passed by user to a variable 
            BYTE_OPTION=$(echo $BYTE_OPTION |tr [:lower:] [:upper:]) #converting operator/argument to uppercase to aviod case-sensitivity issue 

                if [[  $BYTE_OPTION  =~ ^(GT|LT|LE|GE|EQ|NE),[0-9]+$ ]]; then #vaildating argument passed by user
                    BYTE_VALUE=$(echo $BYTE_OPTION| cut -d ',' -f 2) #split argument  and assiging numeric value to variable
                    BYTE_OPTION=$(echo $BYTE_OPTION | cut -d ',' -f 1) #spilt argument and assiging operator to varible for later use 

                else  #error handiling - for invalid operator and argument
                    echo -e "${RED}Invalid comparator/argument(s) passed - exiting...${NC}" && exit 01
                fi

                if [[ ! -z $BYTE_VALUE ]]; then #validating byte value
                    #case statment to handle different operator
                    case $BYTE_OPTION in #each operator compare and byte value and write matched file to comp.txt in working directory
                        GT) awk '{ if ($5 > byte) printf "%-25s  %.2fb\n", $9, $5 }' byte="$BYTE_VALUE" > $dir/comp.txt;;
                        LT) awk '{ if ($5 < byte) printf "%-25s  %.2fb\n", $9, $5 }' byte="$BYTE_VALUE" >  $dir/comp.txt;;
                        LE) awk '{ if ($5 <= byte) printf "%-25s  %sb\n", $9, $5 }' byte="$BYTE_VALUE" >  $dir/comp.txt;;
                        GE) awk '{ if ($5 >= byte) printf "%-25s  %sb\n", $9, $5 }' byte="$BYTE_VALUE" >  $dir/comp.txt;;
                        EQ) awk '{ if ($5 == byte) printf "%-25s  %sb\n", $9, $5 }' byte="$BYTE_VALUE" >  $dir/comp.txt;;
                        NE) awk '{ if ($5 != byte) printf "%-25s  %sb\n", $9, $5 }' byte="$BYTE_VALUE" >  $dir/comp.txt;;
                        *) echo -e "${BLUE}Invalid  value passed. Exiting...${NC}" && exit 1
                        ;;
                        
                    esac < $dir/output.txt #text file with bin directory listing provided to case statment

                    match_count=$(cat $dir/comp.txt | wc -l) #getting count of match found

                    if [[ $match_count -eq 0 ]];then #validating found matchs
                        echo -e $matchError #error handling - print no match found if match is 0

                    else #print number of matches found and appropriate header 
                        echo -e "${GREEN}$match_count${NC} found"
                        echo "Header" | awk 'BEGIN {variable1="'$FILE_NAME'"; variable2="'$FILE_SIZE'"} {printf "%-36s  %-20s\n", variable1, variable2}'
                        echo -e "${BLUE}===============================${NC}"
                        cat $dir/comp.txt #print formated match file from previous comparion to terminal
                    fi
                
                else #error handling - for invaild byte value
                    echo -e "${RED}Invalid bytes value  passed. Exiting....${NC}" && exit 1
                fi
        ;;
        
        l)

            LINKS=true #decalring variable to true for later use
        ;;
        #error handling - for invlaid options/flag  
        *) echo -e "${RED}Invalid flag passed - exiting...${NC}" && exit 1
        ;;
    esac 
#suppressing terminal error message 
#provideing text file with bin dictory listing to while loop for processing
done < $dir/output.txt 2> /dev/null 

#checking lINK variable from previous 
if [[ $LINKS == true ]]; then
    
    #using extended pattern matching getting symbolic files and writting them to text file
    grep -oE '[^ ]+ -> [^-]+' $dir/output.txt | sed 's/\->//' > $dir/tem.txt 

    match_count=$(cat $dir/tem.txt | wc -l) #counting matches found and assign them to variable

    if [[ $match_count -eq 0 ]];then  #validating found matchs
        echo -e $matchError #error handling - print no match found if match is 0
        exit

    else
        #print number of matches found and appropriate header to terminal
        echo -e "${GREEN}$match_count${NC} found"
        echo "Header" | awk 'BEGIN {variable1="'$SYMBOLIC_FILE'"; variable2="'$FILE_POINTS'"} {printf "%-40s  %-15s\n", variable1, variable2}'
        #echo -e "${BLUE}-----------------------------------------${NC}"
    
        IFS=orgin_ifs #storing IFS to a variable
        IFS=$'\n' #changing variable to newline so for loop can read each line 
        
        #loop through each line of symbolic files found
        for item in $(cat tem.txt)
        do  
            linkfile=$(echo $item |awk '{print $1}') # assign first colum with file name to variable

            fname=$(echo $item | awk '{print $2}') #spilt second colum using awk
            linkname=$(basename "$fname") #get appropriate file name from path /*/*/

            #write formated symbolic file to text file in requried output format
            echo $linkfile $linkname | awk '{printf "%-30s %-s\n", $1, $2}' >> $dir/tempt.txt
        
        done
        #printt result to terminal
        cat $dir/tempt.txt
    fi
     
fi

#removing every tempory file at end of script 
if [[ -f $dir/output.txt ]];then  
 
    rm $dir/output.txt
fi
if [[ -f $dir/tempt.txt ]];then
    rm $dir/tempt.txt
fi
if [[ -f $dir/tem.txt ]];then
    rm $dir/tem.txt
fi

orgin_ifs=IFS #restoring IFS back to orginal value (space)

exit 1