.386
; Sa se determine minimul si maximul dintr-un sir de numere cu semn reprezentate pe cuvant si sa se scrie valorile gasite ın memorie.
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem msvcrt.lib, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern fopen: proc
extern fclose: proc
extern printf: proc
extern scanf: proc
extern fprintf: proc
extern fscanf: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;mesaje si formate
zero DD 0
chr DB "-",0
msj_meniu0 DB "Selecteaza operatia",10,13,0
msj_meniu1 DB "1.Histograma",10,13,0
msj_meniu2 DB "2.Calculul mediei bazat pe histograma",10,13,0
msj_meniu3 DB "3.Calcului deviatiei standard",10,13,0
msj_meniu4 DB "4.Eliminare valori",10,13,0
msj_salvare_minmax DB "salvat in minmax.txt",10,13,0
msj_salvare_medie DB "ati ales media aritmetica; salvat in medie.txt",10,13,0
msj_salvare_histograma DB "ati ales histograma; salvat in histograma.txt",10,13,0
msj_salvare_deviatie DB "ati ales deviatia standard; salvat in deviatie.txt",10,13,0
msj_file DB "incarcare fisier: ",10,13,0
mode_read DB "r",0
mode_write DB "w",0
format_string DB "%s",0
format_int DB "%d",0
format_out DB "%d, ",0
format_meniu DB "%s %s %s %s %s",0
msj_minmax DB "min=%d, max=%d ",10,13,0
format_histograma DB "[%d]:%d ",0
format_histograma1 DB "[-%d]:%d ",0
format_medie DB "%d,%d",10,13,0
msj_0uri DB "0",0
patru dd 4
;variabile
file_deviatie DB "deviatie.txt",0
file_medie DB "medie.txt",0
file_histograma DB "histograma.txt",0
file_minmax DB "minmax.txt",0
file_name DB "necunoscut",0;fisieru din care citim vectorul
operatie DD 0              ; cand operatia nu e 1,2,3,4 se termina programul
n DD 12         		   ;numarul de elemente ale sirului
sir DD 100 dup(0)          ;sirul in care citim elementele
min DD 0
max DD 0
hgm_pozitive DD 256 dup(0)
hgm_negative DD 256 dup(0)
suma DD 0
sumasq DD 0
medie_int DD 0            ;partea intreaga a mediei
medie_float DD 0          ;primele patru cifre dupa virgula
num_float DD 0
num_int DD 0 
t2_int DD 0
t2_float DD 0
t3_int DD 0
t3_float DD 0
ds_int DD 0
ds_float DD 0
;constante
semn DD -1
mii DD 10000
a DD 0
b DD 0
ds_final DQ 16
chr2 db "%lf ",10,13,0
format_char db "%c",0
chr3 db 'a'
.code
start:
	pusha
	push offset msj_file
	call printf
	add ESP,4
	popa
	
	pusha
	push offset file_name
	push offset format_string
	call scanf
	add ESP,8
	popa
	
	pusha
	push offset mode_read
	push offset file_name
	call fopen
	add ESP,8
	mov EBX,EAX
	
	
	;avem fisierul de citire deschis, in EAX si EBX avem pointer spre el
	pusha
	push offset n
	push offset format_int
	push EAX
	call fscanf
	add ESP,12
	popa
	;am citit n-ul
	
	
	mov EDI,0
	citire_vector:
	mov EDX,0
	mov EAX,4
	mul EDI
	add EAX,offset sir
	pusha
	push EAX
	push offset format_int
	push EBX
	call fscanf
	add ESP,12
	popa
	inc EDI
	cmp EDI,n
	JNE citire_vector
	
	push EBX
	call fclose
	add ESP,4
	popa;am terminat cu fisierul de citire
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;calculam min si max si dupa le afisam
	
	redo:
	pusha
	lea ESI, offset sir
	mov EDI, 1;contor
	mov EAX,[ESI];maximul
	mov EBX,[ESI];minimul
	add ESI, 4
	
	et1:
	cmp EAX, [ESI]
	JL maxx
	cmp EBX, [ESI]
	JG minn
	add ESI, 4
	inc EDI
	cmp EDI,n
	JNE et1
	JMP next
	maxx: mov EAX, [ESI]
	JMP et1
	minn: mov EBX, [ESI]
	JMP et1
	next: 
	mov min, EBX
	mov max, EAX
	
	push max
	push min
	push offset msj_minmax
	call printf
	add ESP,12
	;urmeaza sa le salvam in minmax.txt
	push offset mode_write
	push offset file_minmax
	call fopen
	add ESP,8
	pusha
	push max
	push min
	push offset msj_minmax
	push EAX
	call fprintf
	add ESP,16
	popa
	push EAX
	call fclose
	push offset msj_salvare_minmax
	call printf
	add ESP,4
	
	popa;AM TERMINAT SI CU MIN SI MAX
	;facem si histograma, media si deviatia
	
	pusha
	mov ESI,0
	jmp while2
	pozitiv: inc [offset hgm_pozitive + 4*EAX ]
	jmp next2
	while2:
	mov EAX,[offset sir+4*ESI]
	cmp EAX,0
	JGE pozitiv
	mov EDX,0
	
	mul semn
	inc [offset hgm_negative + 4*EAX]
	next2:
	inc ESI
	cmp ESI,n
	JNE while2
	
	
	popa
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;cream media aritmetica cu ajutorul histogramei
	mov ESI,0
	while3:
	mov EDX,0
	mov EAX,[4*ESI+hgm_pozitive]
	mul ESI
	add suma,EAX
	inc ESI
	cmp ESI,256
	JNE while3
	
	mov ESI, 1
	while4:
	mov EDX,0
	mov EAX,[4*ESI + hgm_negative]
	mov EDX,0
	mul ESI
	sub suma,EAX
	inc ESI
	cmp ESI,256
	JNE while4
	
	;avem suma, acum impartim la n
	mov EDX,0
	mov EAX,suma
	div n
	mov medie_int,EAX
	mov EAX,EDX
	mov EDX,0
	mul mii
	div n
	mov medie_float,EAX
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;construim deviatia
	mov ESI, 1
	et4:
	mov EDX,0
	mov EAX, [hgm_negative + 4*ESI]
	mul ESI
	mul ESI
	add sumasq,EAX
	mov EDX,0
	mov EAX,[hgm_pozitive + 4*ESI]
	mul ESI
	mul ESI
	add sumasq,EAX
	add ESI,1
	cmp ESI,256
	JNE et4
	;cream t2
	mov EDX,0
	mov EAX,2
	mul suma
	mul medie_int
	mov t2_int, EAX
	div medie_int
	mul medie_float
	div mii
	add t2_int,EAX
	mov t2_float,EDX
	
	mov EDX,0
	mov EAX, 2
	mul medie_int
	mul medie_float
	div mii; in eax avem int ul si in edx avem float ul
	mov t3_int,EAX
	mov t3_float,EDX
	mov EDX,0
	mov EAX, medie_int
	mul medie_int
	add t3_int,EAX
	mov EAX,medie_float
	mul medie_float
	div mii
	add t3_float,EAX;;;;pana aici luna si bec
	mov EAX, t3_int
	mul n
	mov t3_int,EAX
	mov EAX,t3_float
	mul n
	div mii
	add t3_int,EAX
	mov t3_float,EDX
	
	;cream numitorul
	mov EAX,sumasq
	add EAX,t3_int
	sub EAX,t2_int
	mov num_int,EAX
	mov EAX,t3_float
	sub EAX,t2_float
	
	cmp EAX,0
	JGE caz2
	mov EDX,0
	mul semn
	mov EDX,0
	div mii
	sub num_int,EAX
	mov EAX,mii
	sub EAX,EDX
	cmp EAX,mii
	JNE ep1
	mov num_float,0
	JMP next1
	ep1:dec num_int
	mov num_float,EAX
	JMP next1
	caz2:
	mov EDX,0
	div mii
	add num_float,EDX
	add num_int,EAX
	next1:
	;cam atat cu numitorul
	
	;okk incepem sa impartim
	mov EAX,num_int
	mov EDX,0
	dec n
	div n
	mov ds_int, EAX
	mov EAX,EDX
	mul mii
	div n
	mov ds_float,EAX
	mov EAX, num_float
	mov EDX,0
	div n
	inc n;aducem n ul la val initiala
	add ds_float, EAX
	mov EDX,0
	mov EAX,ds_float
	div mii
	add ds_int,EAX
	mov ds_float,EDX
	
	mov EBX,ds_int
	mov dword ptr [ds_final], EBX
	
	finit
	fild ds_final
	fsqrt
	fstp ds_final
	
	JMP afisare_meniu
	;PANA AICI AM CALCULAT PRIMELE TREI CERINTE, URMEAZA SA ELIMINAM DIN SIR VALORILE CERUE DUPA CARE REFACEM CELE TREI CERINTE PT NOUL SIR
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	afisare_deviatie:
	pusha
	push offset mode_write
	push offset file_deviatie
	call fopen
	add ESP,8
	pusha
	push dword ptr [ds_final+4]
	push dword ptr [ds_final]
	push offset chr2
	push EAX
	call fprintf
	add ESP,16
	popa  
	
	pusha
	push EAX
	call fclose
	popa
	
	popa
	
	pusha
	push offset msj_salvare_deviatie
	push offset format_string
	call printf
	add ESP,8
	popa
	JMP afisare_meniu
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;afisarea mediei
	afisare_medie:
	pusha
	push offset mode_write
	push offset file_medie
	call fopen
	add ESP,8
	
	pusha
	push medie_float
	push medie_int
	push offset format_medie
	push EAX
	call fprintf
	add ESP, 16
	popa
	push EAX
	call fclose
	add ESP,4
	popa
	
	pusha
	push offset msj_salvare_medie
	push offset format_string
	call printf
	add ESP,8
	popa
	JMP afisare_meniu
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;afisarea histogramei
	afisare_histograma:
	mov ESI,0
	
	push offset mode_write
	push offset file_histograma
	call fopen
	add ESP,8
	mov EBX,EAX
	
	while_afis:
	
	pusha
	push [4*ESI+hgm_pozitive]
	push ESI
	push offset format_histograma
	push EBX
	call fprintf
	add ESP,16
	popa
	inc ESI
	cmp ESI, 256
	JNE while_afis
	
	;afisam numerele negative
	mov EDX,0
	mov ESI,1
	
	
	while_afis2:
	pusha
	push [4*ESI+hgm_negative]
	push ESI
	push offset format_histograma1
	push EBX
	call fprintf
	add ESP,16
	popa
	inc ESI
	cmp ESI, 256
	JNE while_afis2
	push EBX
	call fclose
	pusha
	push offset msj_salvare_histograma
	push offset format_string
	call printf
	add ESP,8
	popa
	JMP afisare_meniu
	;aceasta a fost afisarea histogramei
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;aici eliminam VALORI
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	eliminare_valori:
	pusha
	push offset mode_read
	push offset file_deviatie
	call fopen
	add ESP,8
	
	pusha
	push offset a
	push offset format_int
	push EAX
	call fscanf
	add ESP,12
	popa
	
	pusha
	push EAX
	call fclose
	popa
	
	mov EAX,a
	add EAX,a
	mov EDX,0
	mov b,EAX
	mul semn
	mov a,EAX
	popa
	;avem capetele intervalului
	mov EDI,0
	jmp while5
	ultimul:dec n
	jmp ultimul_salt
	elimin:
	cmp EDI,n
	JMP ultimul
	mov ESI,EDI
	dec n
	while_aux:
	mov ECX,[sir+4*ESI+4]
	mov [sir+4*ESI],ECX
	inc ESI
	cmp ESI,n
	JNE while_aux
	jmp salt
	while5:
	mov EAX,[sir+4*EDI]
	cmp a,EAX
	JG elimin
	cmp b,EAX
	JL elimin
	inc EDI
	salt:
	cmp EDI,n
	JNE while5
	
	ultimul_salt:
	pusha
	mov ESI,0
	while6:
	pusha
	mov EDX, [4*ESI+sir]
	push EDX
	push offset format_out
	call printf
	add ESP,8
	popa
	inc ESI
	cmp ESI,n
	JNE while6
	popa
	
	mov ESI,0
	while7:
	mov EAX,0
	mov [hgm_pozitive + 4*ESI],EAX
	inc ESI
	cmp ESI, 256
	JNE while7
	
	mov ESI,0
	while8:
	mov EAX,0
	mov [hgm_negative + 4*ESI],EAX
	inc ESI
	cmp ESI, 256
	JNE while8

	
	
	JMP redo
	JMP afisare_meniu
	afisare_meniu:
	pusha
	push offset msj_meniu4
	push offset msj_meniu3
	push offset msj_meniu2
	push offset msj_meniu1
	push offset msj_meniu0
	push offset format_meniu
	call printf
	add ESP,24
	popa
	pusha
	push offset operatie
	push offset format_int
	call scanf
	add ESP,4
	popa
	
	cmp operatie,1
	JE afisare_histograma
	cmp operatie,2
	JE afisare_medie
	cmp operatie,3
	JE afisare_deviatie
	cmp operatie,4
	JE eliminare_valori
	;terminarea programului
	
	push 0
	call exit
end start