#!/bin/bash

# UWAGA: Kod jest niesanitarny. Zaladowanie falszywego lub niepoprawnie skonstruowanego
# skryptu .tok moze spowodowac nieodwracalne szkody. Korzystac WYLACZNIE ze skryptow .tok
# pochodzacych z zaufanego zrodla.

loadTOK() 
{
	# znajduje sciezke wszystkich plikow .tok i wycina wszystko poza nazwa pliku
	toks=($(find . -name "*.tok" | rev | cut -d'/' -f1 | rev))	
	if [ "${#toks[@]}" -gt 1 ]; then
		# znaleziono wiecej niz jeden .tok 
		clear
		sleep 1
		PS3="Wybierz plik z gra: "
		select file in "${toks[@]}";
		do
			if [ "$REPLY" -le "${#toks[@]}" ]; then
				source ${toks[$(($REPLY-1))]}
				break
			else	
				echo "Niepoprawny plik. "
			fi
		done
	else 
		if [ "${#toks[@]}" -eq 1 ]; then
			# znaleziono tylko jeden .tok
			source ${toks[0]}
		else
			# ani jednego .tok
			echo "Nie znaleziono zadnego pliku z gra."
			echo "Pliki .tok musza byc w tym samym folderze co plik .sh." 
			exit
		fi
	fi
}


czyPowtorzenie() 
{ 
	for (( i=0; i<${#zapisane[*]}; i++ ))
	do
		wycietaNazwa="$(echo "${zapisane[i]}" | cut -d'_' -f3)"
		echo ""$wycietaNazwa" "$nazwaZapisu""
		if [ "$wycietaNazwa" = "$nazwaZapisu" ]; then
			# nazwa pliku zapisu jest unikalna
			return 0
		fi
	done
	# w folderze istnieje juz plik zapisu o takiej nazwie
	return 1
}

zapisGry() 
{
	# tworzy liste sciezek plikow .sav i wycina z nich wszystko poza sama nazwa pliku
	zapisane=($(find ./saves -name "*.sav" | sort -k1 -r | rev | cut -d'/' -f1 | rev | cut -d'.' -f1))
	if [ ${#zapisane[*]} -gt 0 ]; then
		# znaleziono przynajmniej jeden .sav
		echo -e "\nZapisane gry:\n"
		for (( i=0; i<${#zapisane[*]}; i++ ))
		do
			echo "${zapisane[i]}"
		done
	fi
	echo -e "\nNazwij plik zapisu: "
	read nazwaZapisu
	# skopana logika tutaj
	# brakowalo ifa sprawdzajacego czy przypadkiem nie ma 0 save'ow
	# ale i tak to jest do poprawienia
	if [ ${#zapisane[*]} -gt 0 ]; then
		for (( i=0; i<${#zapisane[*]}; i++ ))
		do
			wycietaNazwa=($(echo "${zapisane[i]}" | cut -d'_' -f3))
			if [ "$wycietaNazwa" = "$nazwaZapisu" ]; then
				echo "Taki plik juz istnieje. Nadpisac?"
				select opt in OK Anuluj
				do
					case $opt in
						"OK") 	
							nadpisOk=1
							break
					esac
				done
			break
			fi
		done
		if [ "$nadpisOk" = 1 ]; then
			unset nadpisOk
			break
		fi
	else
		break
	fi
	dataZapisu="$(date +"%Y-%m-%d_%T")"
	nazwaZapisu=""$dataZapisu"_"${nazwaZapisu}""
	#nazwaZapisu=$(echo "$nazwaZapisu" | tr '\n' ' ')
	nazwaZapisu+=".sav"
	#( set -o posix ; set ) > /tmp/tokvars.after
	#diff /tmp/tokvars.before /tmp/tokvars.after > ./saves/$nazwaZapisu
	#rm /tmp/tokvars.after
	#echo "$tokVars
	grep -vxFe "$tokVars" <<<"$( set -o posix ; set )"| grep -v ^tokVars= > ./saves/"$nazwaZapisu"
	echo -e "\nZapisano pomyslnie!\n"
	scenaWstrzymana
}

scenaMENU() 
{
	wMenu=true
	T="[Menu]"
	O+=("Powrot do gry")
	K+=("scenaWstrzymana")
	O+=("Stan postaci")
	K+=("")
	O+=("Zapisz gre")
	K+=("zapisGry")
	O+=("Wczytaj gre")
	K+=("")
	O+=("Wyjdz z gry")
	K+=("scenaOUTRO")
}

scenaWstrzymana()
{
	wMenu=false
	$wstrzymanaKonsekwencja
}

gameLoop() 
{
	# wyswietla tekst sceny
	echo "$T"
	echo
	# jezeli user nie znajduje sie w menu to daje mu taka opcje
	if [ "$T" != "[Menu]" ]; then
		O+=("Menu")
		K+=("scenaMENU")
	fi
	PS3="Twoj wybor: "
	select opt in "${O[@]}";
	do
		if [ "$REPLY" -le "${#O[@]}" ]; then
			if [ "${K[$(($REPLY-1))]}" != "scenaMENU" ] && [ "$wMenu" = false ]; then
				echo "debug: wchodze w if"
				wstrzymanaKonsekwencja=${K[$(($REPLY-1))]}
			fi
			nowaScena=${K[$(($REPLY-1))]}
			unset T
			unset O
			unset K
			$nowaScena
			break
		else
			# user dal nierozpoznany input
			echo "co?"	
		fi
	done
	echo
}

loadTOK
tokVars="`set -o posix ; set`"
#( set -o posix ; set ) > /tmp/tokvars.before
scenaINTRO

clear
sleep 1
wMenu=false

while [ true ]
do
	gameLoop
done
