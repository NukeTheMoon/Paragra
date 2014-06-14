#!/bin/bash

function loadTOK() {
	toks=($(find . -name "*.tok" | rev | cut -d'/' -f1 | rev))
	if [ "${#toks[@]}" -gt 1 ]; then
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
			source ${toks[0]}
		else
			echo "Nie znaleziono zadnego pliku z gra."
			echo "Pliki .tok musza byc w tym samym folderze co plik .sh." 
			exit
		fi
	fi
}

function zapisGry() {
	echo "Zapisane gry:"
	#wypisz pliki .sav wraz z data zgrepowana z np pierwszej linijki i pasujaca do 
	#pliku tok
	zapisane=($(find ./saves -name "*.sav" | rev | cut -d'/' -f1 | rev | cut -d'.' -f1))
	echo "Nazwij plik zapisu: "
	read nazwa
	#stworz plik, lub zapytaj czy nadpisac
	}

function scenaOPCJE() {
	T="[Opcje]"
	O+=("Powrot do gry")
	K+=("")
	O+=("Stan postaci")
	K+=("")
	O+=("Zapisz gre")
	K+=("zapisGry")
	O+=("Wczytaj gre")
	K+=("")
	O+=("Wyjdz z gry")
	K+=("scenaOUTRO")
}

function gameLoop() {
	echo "$T"
	echo
	if [ "$T" != "[Opcje]" ]; then
		O+=("Opcje")
		K+=("scenaOPCJE")
	fi
	PS3="Twoj wybor: "
	select opt in "${O[@]}";
	do
		if [ "$REPLY" -le "${#O[@]}" ]; then
			if [ ${K[$(($REPLY-1))]} = "scenaOpcje" ]; then
				wstrzymanaScena=${K[$(($REPLY-1))]}
			fi
			nowaScena=${K[$(($REPLY-1))]}
			unset T
			unset O
			unset K
			$nowaScena
			break
		else
			echo "co?"	
		fi
	done
	echo
}

loadTOK

scenaINTRO

clear
sleep 1

while [ true ]
do
	gameLoop
done
