#!/bin/bash

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
				wybranyTok=${toks[$(($REPLY-1))]}
				chmod +x $wybranyTok
				source $wybranyTok
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

zapisGry() 
{
	# tworzy liste sciezek plikow .sav i wycina z nich wszystko poza sama nazwa pliku
	if [ ! -d "./saves" ]; then
		mkdir saves
	fi
	zapisaneNazwy=($(find ./saves -name "*.sav" | rev | cut -d'/' -f1 | rev | cut -d'.' -f1))
	zapisane=($(find ./saves -name "*.sav"))
	if [ ${#zapisane[*]} -gt 0 ]; then
		# znaleziono przynajmniej jeden .sav
		for (( i=0; i<${#zapisane[*]}; i++ ))
		do
			zawartoscWybranyTok=`grep -m 1 '^wybranyTok' "${zapisane[i]}" | cut -d'=' -f2`
			zawartoscDataZapisu=`grep -m 1 '^dataZapisu' "${zapisane[i]}" | cut -d'=' -f2 | tr -d \'`
			zapisaneSzczegoly+="["$zawartoscDataZapisu"] ["$zawartoscWybranyTok"] "${zapisaneNazwy[i]}"\n"
			unset zawartoscWybranyTok
			unset zawartoscDataZapisu
		done
		echo -e "\nZapisane gry:\n"
		echo -e $zapisaneSzczegoly | sort -k1 -r
		unset zapisaneSzczegoly
	fi
	echo -e "\nNazwij plik zapisu: "
	read nazwaZapisu
	if [ ${#zapisane[*]} -gt 0 ]; then
		if [ `grep -o $nazwaZapisu <<< ${zapisaneNazwy[*]} | wc -l` -gt 0 ]; then
			echo -e "\nTaki plik juz istnieje. Nadpisac?"
			select opt in OK Anuluj
			do
				case $opt in
					"OK" ) 	
						break
						;;
					"Anuluj" )
						scenaWstrzymana
						return
						;;
				esac
			done
		fi
	fi
	dataZapisu=$(date +"%Y-%m-%d %T")
	nazwaZapisu=""$nazwaZapisu".sav" 
	grep -vxFe "$tokVars" <<<"$( set -o posix ; set )"| grep -v ^tokVars= > ./saves/"$nazwaZapisu"
	unset dataZapisu
	unset nazwaZapisu
	echo -e "\nZapisano pomyslnie!"
	scenaWstrzymana
}

wczytanieGry()
{
	if [ -d ./saves ]; then
		zapisane=($(find ./saves -name "*.sav"))
		zapisaneNazwy=($(find ./saves -name "*sav" | rev | cut -d'/' -f1 | rev | cut -d'.' -f1))
		if [ ${#zapisane[*]} -gt 0 ]; then
			for (( i=0; i<${#zapisane[*]}; i++ ))
			do
				zawartoscWybranyTok=`grep -m 1 '^wybranyTok' "${zapisane[i]}" | cut -d'=' -f2`
				zawartoscDataZapisu=`grep -m 1 '^dataZapisu' "${zapisane[i]}" | cut -d'=' -f2 | tr -d \'`
				zapisaneSzczegoly+="["$zawartoscDataZapisu"] ["$zawartoscWybranyTok"] "${zapisaneNazwy[i]}""
				zapisaneSzczegoly+=';'
				IFS=';' read -a zapisaneZbior <<< "$zapisaneSzczegoly"
				unset zawartoscWybranyTok
				unset zawartoscDataZapisu
			done
			unset zapisaneSzczegoly
			echo -e "\nZapisane gry:\n"
			PS3="Wybierz stan gry do wczytania lub wpisz 0 aby anulowac: "
			select opt in "${zapisaneZbior[@]}";
			do
				if [ "$REPLY" -le "${#zapisaneZbior[@]}" ] && [ "$REPLY" -gt 0 ]; then
					wczytanyTok=`grep -m 1 '^wybranyTok' "${zapisane[$REPLY-1]}" | cut -d'=' -f2`
					chmod +x $wczytanyTok
					source $wczytanyTok
					chmod +x ${zapisane[$REPLY-1]}
					source ${zapisane[$REPLY-1]}
					echo -e "\nWczytano pomyslnie!\n"
					scenaWstrzymana
					return
				elif [ "$REPLY" -eq 0 ]; then
					scenaWstrzymana
					return
				else
					echo -e "\nNie ma takiego stanu gry.\n"
				fi 
			done
		else
			echo -e "\nNie znaleziono zadnych zapisanych gier."
			scenaWstrzymana
		fi
	else
		echo -e "\nNie znaleziono zadnych zapisanych gier."
		scenaWstrzymana
	fi
}

scenaMENU() 
{
	wMenu=true
	T="[Menu]"
	O+=("Powrot do gry")
	K+=("scenaWstrzymana")
	O+=("$nazwaEkranuGracza")
	K+=("")
	O+=("Zapisz gre")
	K+=("zapisGry")
	O+=("Wczytaj gre")
	K+=("wczytanieGry")
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
	echo -e "$T"
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

tokVars="`set -o posix ; set`"
loadTOK
scenaINTRO

clear
sleep 1

wMenu=false
wstrzymanaKonsekwencja=scenaINTRO
if [ -z "$nazwaEkranuGracza" ]; then
	nazwaEkranuGracza="Stan postaci"
fi

while [ true ]
do
	gameLoop
done
