.model small   
.386

skBufDydis  EQU 400 
raBufDydis  EQU 50

.stack 100h
.data                     
    baitai      db skBufDydis dup (?) 
    ats         db raBufDydis dup (20h) 
                
    klAtidarant db "Klaida atidarant faila", 0Ah, 0Dh, 24h
    klSkaitant  db "Klaida skaitant$", 0Ah, 0Dh, 24h  
    valio       db "Programa baige darba sekmingai$", 0Ah, 0Dh, 24h  
	mazai_parametru	db "Ivestas netinkamas kiekis parametru$", 0Ah, 0Dh, 24h
	pagalbosPranesimas 			db "Programos autorius: Audrius Kumpis, PS 2 gr", 0Ah, 0Dh, "Programa atpazista masinini koda ir isveda pagal ji asemblerio komandas", 0Ah, 0Dh, 24h
    	
    duomenuFailas		   	db 15 dup (0)
	rezultatuFailas			db 15 dup (0)
                   
    esamosKomandosPradzia   dw 0
        
    mov_msg     db "mov $"
    push_msg    db "push $"  
    pop_msg     db "pop $"   
    add_msg     db "add $"  
    inc_msg     db "inc $"     
    dec_msg     db "dec $"      
    sub_msg     db "sub $"  
    cmp_msg     db "cmp $"     
    mul_msg     db "mul $"   
    div_msg     db "div $"   
    call_msg    db "call $"   
    ret_msg     db "ret $"  
    iret_msg    db "iret $"
    retf_msg    db "retf $"
    jmp_msg     db "jmp $" 
    loop_msg    db "loop $"        
    int_msg     db "int $"
	xor_msg		db "xor $"
    
    ;----------------------
    jo_msg          db "jo $$"  ;00
    jno_msg         db "jno $"
    jb_msg          db "jb $$"
    jae_msg         db "jae $"
    je_msg          db "je $$"
    jne_msg         db "jne $"
    jbe_msg         db "jbe $"
    ja_msg          db "ja $$"
    js_msg          db "js $$"
    jns_msg         db "jns $"
    jp_msg          db "jp $$"
    jnp_msg         db "jnp $"
    jl_msg          db "jl $$"
    jge_msg         db "jge $"
    jle_msg         db "jle $"
    jg_msg          db "jg $$"   ; 0F
    
    ax_msg  db "ax$"
    bx_msg  db "bx$"
    cx_msg  db "cx$"
    dx_msg  db "dx$"  
    
    sp_msg  db "sp$"
    bp_msg  db "bp$"
    si_msg  db "si$"
    di_msg  db "di$"    
    
    ah_msg  db "ah$"
    bh_msg  db "bh$"
    ch_msg  db "ch$"
    dh_msg  db "dh$"
    
    al_msg  db "al$"
    bl_msg  db "bl$"
    cl_msg  db "cl$"
    dl_msg  db "dl$"  
    
    es_msg  db "es$"
    cs_msg  db "cs$"
    ss_msg  db "ss$"
    ds_msg  db "ds$"     
    
    kablelis_tarpas db ", $"   
    dvitaskis       db ":$"
    
    mod_dalis db ?
    reg_dalis db ?
    rm_dalis  db ?  
    dw_dalis  db ?
    
    poslinkis1  db 0
    poslinkis2   db 0   
    
    bob1    db 0
    bob2    db 0 
    
    dabartinisIp    dw 0100h  
    komandosDydis   dw 01h
    
    nezinau db "neatpazinau$" 
    enteris db 0Ah, 24h 
    
    ;------------------------
    
    dFail   dw 0  
    rfail   dw 0
    rez     db "rezFile.lis", 0
    duom    db "pvz.com", 0  
    failoDydis dw 0
    
.code      

start:   

    mov ax, @data
    mov ds, ax 
	
	call gaukParametrus
    
    call openFile 
    call rez_failo_sukurimas
    
	xor cx, cx
	xor di, di
	xor si, si
	xor ax, ax
	xor bx, bx
    
    mov cx, failoDydis       ; ******baitu kiekis
    ;mov cx, 0Bh
 mainloop:            
    ;***********************************
    ; mainlooop
    ; ********************************** 
    
    call nusinulink_ats 
    xor di, di
    
    mov dx, dabartinisIP
    sub dx, 100h  
    
    mov poslinkis1, 0h
    mov poslinkis2, 0h  
    
    mov bob1, 0h
    mov bob2, 0h 
    xor ax, ax
    
    mov esamosKomandosPradzia, dx
    
    mov komandosDydis, 01h

    mov bx, offset baitai 
    mov si, esamosKomandosPradzia
    mov al, byte ptr [bx+si]        
 
; ieskom komandu
 
 toliau_mod_plet_rm:  ; formatas mod XXX rm [poslinkis]
    cmp al, 0FFh
    je taip_mod_plet_rm
    
    cmp al, 08Fh
    je taip_mod_plet_rm
    jmp toliau_inc_dec_rm 
    
 toliau_inc_dec_rm:
    cmp al, 0FEh
    je taip_mod_plet_rm
    
 toliau_mul_div:
    cmp al, 0F6h
    je taip_mul_div
    cmp al, 0F7h
    je taip_mul_div 
    
 toliau_jmp_kiti:
    
    cmp al, 0EAh
    je taip_jmp_isorinis_tiesioginis
    
    cmp al, 0EBh
    je taip_jmp_vidinis_artimas 
    
    cmp al, 0E9h
    je taip_jmp_vidinis_tiesioginis
 
 toliau_call_vidinis:
    cmp al, 0E8h
    je taip_call_vidinis
    
 toliau_loop:
    cmp al, 0E2h
    je taip_loop  
    
 toliau_iret:
    cmp al, 0CFh
    je taip_iret
    
 toliau_int:
    cmp al, 0CDh
    je taip_int
    
 toliau_retf:
    cmp al, 0CAh
    je taip_retf    
    
 toliau_ret:
    cmp al, 0C3h
    je taip_ret
    
 toliau_ret_bob:
    cmp al, 0C2h
    je taip_ret_bob
    
 toliau_mov_ilgasis:
    cmp al, 0C6h
    jae gal_mov_ilgasis
    jmp toliau_mov_wreg
    
 gal_mov_ilgasis:
    cmp al, 0C7h
    jbe taip_mov_ilgasis
    
 toliau_mov_wreg:
    cmp al, 0B0h
    jae gal_mov_wreg
    jmp toliau_mov_atm_akum1
    
 gal_mov_wreg:
    cmp al, 0BFh
    jbe taip_mov_wreg 
 
 toliau_mov_atm_akum1:
    cmp al, 0A2h
    je taip_mov_akum_atm
 
 toliau_mov_atm_akum2:
    cmp al, 0A3h
    je taip_mov_akum_atm
    
 toliau_mov_akum_atm1:
    cmp al, 0A0h
    je taip_mov_akum_atm 
    
 toliau_mov_akum_atm2:
    cmp al, 0A1h
    je taip_mov_akum_atm 
    
 toliau_call_isorinis:
    cmp al, 09Ah
    je taip_call_isorinis
    
 toliau_mov_segreg:
    cmp al, 08Ch
    je taip_mov_segreg 
    
 gal_mov_segreg:
    cmp al, 08Eh
    je taip_mov_segreg       
    
 toliau_mov_reg_rm:   
    cmp al, 088h
    jae gal_mov_reg_rm 
    jmp toliau_ilgieji_add_sub_cmp  
 
    
 gal_mov_reg_rm:
    cmp al, 08Bh
    jbe spausdink_mov_reg_rm 
    
 toliau_ilgieji_add_sub_cmp:
    cmp al, 080h
    jae gal_ilgieji_add_sub_cmp
    jmp toliau_salyginiai_jmp
    
 gal_ilgieji_add_sub_cmp:
    cmp al, 083h
    jbe taip_ilgieji
                      
 toliau_salyginiai_jmp:
    cmp al, 070h
    jae gal_salyginiai_jmp 
    jmp toliau_popreg
    
 gal_salyginiai_jmp:
    cmp al, 07Fh
    jbe taip_salyginiai_jmp 
    
 toliau_popreg:
    cmp al, 058h
    jae gal_popreg
    jmp toliau_pushreg
    
 gal_popreg:
    cmp al, 05Fh
    jbe taip_popreg 
    
 toliau_pushreg:
    cmp al, 050h
    jae gal_pushreg
    jmp toliau_decreg
    
 gal_pushreg:
    cmp al, 05Fh
    jbe taip_pushreg 
    
 toliau_decreg:
    cmp al, 048h
    jae gal_decreg
    jmp toliau_increg
 
 gal_decreg:
    cmp al, 04Fh
    jbe taip_decreg
 
 toliau_increg:
    cmp al, 040h
    jae gal_increg
    jmp toliau_cmp_akum
    
 gal_increg:
    cmp al, 047h
    jbe taip_increg 
    
 toliau_cmp_akum:
    cmp al, 03Ch
    je taip_cmp_akum   
    
    cmp al, 03Dh
    je taip_cmp_akum 
	
toliau_xor:
	cmp al, 030h
	jae gal_xor
	jmp toliau_ds
gal_xor:
	cmp al, 033h
	jbe taip_xor
    
 toliau_ds:
    cmp al, 03Eh
    je taip_ds
    
 toliau_ss:
    cmp al, 036h
    je taip_ss
    
 toliau_cs:
    cmp al, 02Eh
    je taip_cs 
    
 toliau_es:
    cmp al, 026h
    je taip_es
        
 toliau_sub_akum:
    cmp al, 02Ch
    je taip_sub_akum
    
    cmp al, 02Dh
    je taip_sub_akum
    jmp toliau_sub
    
 toliau_sub:
    cmp al, 028h
    jae gal_sub
    jmp toliau_cmp
    
 gal_sub:
    cmp al, 02Dh
    jbe spausdink_sub
    
 toliau_cmp:
    cmp al, 38h
    jae gal_cmp
    jmp toliau_pop_segreg
    
 gal_cmp:
    cmp al, 3Bh
    jbe spausdink_cmp 
    
 toliau_pop_segreg:
    cmp al, 07h
    jae gal_pop_segreg
    jmp toliau_add_akum
    
 gal_pop_segreg:
    cmp al, 01Fh
    jbe taip_pop_segreg 
    
 toliau_add_akum:
    cmp al, 04h
    je taip_add_akum
    
    cmp al, 05h
    je taip_add_akum
    jmp toliau_push_segreg
    
 toliau_push_segreg:
    cmp al, 06h
    jae gal_push_segreg
    jmp toliau_add
    
 gal_push_segreg:
    cmp al, 01Fh
    jbe taip_push_segreg
    
 toliau_add:
    cmp al, 0h
    jae gal_add
    jmp neatpazinau
    
 gal_add:
    cmp al, 03h
    jbe spausdink_add
    jmp neatpazinau 
    
 
    ;*********************************  
    
  taip_jmp_vidinis_tiesioginis:
    mov dx, offset jmp_msg 
    jmp vidinis_tiesioginis
  taip_call_vidinis:
    mov dx, offset call_msg
    jmp vidinis_tiesioginis
    
  vidinis_tiesioginis:
    mov komandosDydis, 03h
    call spausdink_be_komandos_eilute
    call skaiciuok_vidinis_tiesioginis
    jmp loopas
    
  taip_jmp_isorinis_tiesioginis: 
    mov dx, offset jmp_msg  
    jmp isorinis_toliau
    
  taip_call_isorinis:
    mov dx, offset call_msg
  
  isorinis_toliau:
    mov komandosDydis, 05h
    call spausdink_be_komandos_eilute
    call skaiciuok_isorinis
   
    jmp loopas
    
  taip_jmp_vidinis_artimas:
    mov komandosDydis, 02h
    mov dx, offset jmp_msg
    call spausdink_be_komandos_eilute 
    call spausdink_2bPoslinki_vidinis_artimas 
    jmp loopas                     
      
  taip_salyginiai_jmp:
    mov komandosDydis, 02h 
    
    push ax
    sub al, 070h 
    
    push bx
    mov bx, 05h
    
    mul bx  
    pop bx
    
    mov dx, offset jo_msg
    add dx, ax
    pop ax
    
    call spausdink_be_komandos_eilute
    call spausdink_2bPoslinki_vidinis_artimas 
    jmp loopas
    
  taip_ret_bob:
    mov dx, offset ret_msg   
    mov komandosDydis, 03h
    jmp taip_call_paprasti_toliau_kiti
  
  taip_iret:
    mov dx, offset iret_msg
    jmp ret_toliau 
    
  taip_ret:
    mov dx, offset ret_msg 
   ret_toliau:
    call spausdink_be_komandos_eilute
    
    mov dx, offset enteris
    call spausdink_teksta 
    jmp loopas
    
  taip_retf:
    mov dx, offset retf_msg
    mov komandosDydis, 03h 
    jmp taip_call_paprasti_toliau_kiti  
    
  taip_call_paprasti_toliau_kiti:
    call spausdink_be_komandos_eilute  
    call spausdink_2b
    jmp loopas
    
  taip_call_paprasti_toliau:
    call spausdink_be_komandos_eilute 
    call spausdink_2bPoslinki_vidinis_artimas  
    
    jmp loopas
    
  taip_es:
    mov dx, offset es_msg
    jmp bendras_seg
  taip_cs:         
    mov dx, offset cs_msg
    jmp bendras_seg
  taip_ss:         
    mov dx, offset ss_msg
    jmp bendras_seg
  taip_ds:         
    mov dx, offset ds_msg
        
        bendras_seg:
            mov komandosDydis, 01h
            call spausdink_be_komandos_eilute 
			push bx
			mov bx, offset ats
            mov byte ptr [bx+di], ':'
			inc di
			pop bx
            
    mov dx, offset enteris
    call spausdink_teksta     
    jmp loopas
    
  taip_loop:
    mov komandosDydis, 02h
    mov dx, offset loop_msg
    call spausdink_be_komandos_eilute 
    call spausdink_2bPoslinki_vidinis_artimas  
    jmp loopas  
    
  taip_int: 
    mov komandosDydis, 02h
    mov dx, offset int_msg
    call spausdink_be_komandos_eilute 
    mov bx, esamosKomandosPradzia
    xor ax, ax
    mov al, byte ptr [bx+1] 
    call spauskHex
    
    mov dx, offset enteris
    call spausdink_teksta
    jmp loopas
    
  taip_ilgieji:
    call gaukModRegRm
    
    cmp reg_dalis, 00000000b
    je ilgasis_add
    
    cmp reg_dalis, 10100000b
    je ilgasis_sub
    
    cmp reg_dalis, 11100000b
    je ilgasis_cmp
    jmp neatpazinau
    
        ilgasis_add:
            mov dx, offset add_msg
            jmp taip_ilgieji_toliau
            
        ilgasis_sub:
            mov dx, offset sub_msg
            jmp taip_ilgieji_toliau
            
        ilgasis_cmp:
            mov dx, offset cmp_msg
            
    taip_ilgieji_toliau:
    
        call gaukKomandosIlgi_modRegRm  
        call spausdink_be_komandos_eilute 
        call spausdink_mod_reg_rm_pilnas    
        jmp loopas
    
    jmp loopas
    
  taip_inc_rm:
    mov dx, offset inc_msg
    jmp taip_inc_dec_mul_div_bendras 
    
  taip_dec_rm:  
    mov dx, offset dec_msg   
    jmp taip_inc_dec_mul_div_bendras 
    
  taip_mul_div:
    call gaukModRegRm
    
    cmp reg_dalis, 10000000b
    je taip_mul
    
    cmp reg_dalis, 11000000b
    je taip_div
    jmp neatpazinau 
    
        taip_mul:
            mov dx, offset mul_msg
            jmp taip_inc_dec_mul_div_bendras
            
        taip_div:
            mov dx, offset div_msg
            jmp taip_inc_dec_mul_div_bendras
   
  taip_inc_dec_mul_div_bendras:
    call gaukKomandosIlgi_modRegRm
    call spausdink_be_komandos_eilute 
    call Spausdink_modRmPos
    jmp loopas 
  
  taip_add_akum:
    mov dx, offset add_msg
    jmp add_akum_bendras
  taip_sub_akum:
    mov dx, offset sub_msg 
    jmp add_akum_bendras
  taip_cmp_akum:
    mov dx, offset cmp_msg
    
  add_akum_bendras:                  
    push ax
    
    and ax, 00000001b
    cmp ax, 01h
    je akum_dydis_3
    mov komandosDydis, 02h
    pop ax 
    jmp akum_bendras_toliau
    
        akum_dydis_3:
            mov komandosDydis, 03h
            jmp akum_bendras_toliau 
        
   akum_bendras_toliau:
    call spausdink_be_komandos_eilute
    
    mov bx, esamosKomandosPradzia
    mov al, byte ptr [bx+1] ;bob1
    mov ah, byte ptr [bx+2] ;bob2
       
    mov bob1, al
    mov bob2, ah
        
    xor ax, ax
        
    cmp komandosDydis, 02h
    je akum_bendras_bob1   
    ; 3 baitai, 2 bobai
        mov dx, offset ax_msg
        call spausdink_teksta  
        
        mov dx, offset kablelis_tarpas
        call spausdink_teksta
            
        mov al, bob2
        call spauskHex  
        
        jmp tesk_akum_bendra
      akum_bendras_bob1:
        mov dx, offset al_msg
        call spausdink_teksta 
        
        mov dx, offset kablelis_tarpas
        call spausdink_teksta
        
      tesk_akum_bendra:
        
        mov al, bob1
        call spauskHex
        
     mov dx, offset enteris
     call spausdink_teksta
        
    jmp loopas        
  
  
  taip_mod_plet_rm:
    call gaukKomandosIlgi_modRegRm  
    cmp al, 08Fh
    je spausk_pop_modpletrm 
    
    cmp reg_dalis, 11000000b
    je spausk_push_modpletrm 
    
    cmp reg_dalis, 01000000b
    je spausk_call_modpletrm  
    
    cmp reg_dalis, 01100000b
    je spausk_call_modpletrm
    
    cmp reg_dalis, 10000000b
    je spausk_jmp_modpletrm 
    
    cmp reg_dalis, 10100000b
    je spausk_jmp_modpletrm 
    
    cmp reg_dalis, 00000000b
    je taip_inc_rm
    
    cmp reg_dalis, 00100000b
    je taip_dec_rm
    
            spausk_pop_modpletrm:
                mov dx, offset pop_msg
                jmp bendras_modPletRm 
                
            spausk_push_modpletrm:
                mov dx, offset push_msg
                jmp bendras_modPletRm
                
            spausk_call_modpletrm:
                mov dx, offset call_msg
                jmp bendras_modPletRm 
            
            spausk_jmp_modpletrm:
                mov dx, offset jmp_msg
                jmp bendras_modPletRm
    
        bendras_modPletRm:
            call spausdink_be_komandos_eilute 
            call gaukPoslinki
            
            mov al, rm_dalis
            call spausdink_ea_reiksme 
            
            mov dx, offset enteris
            call spausdink_teksta
            
            ;************************************
    
    jmp loopas
  taip_pop_segreg: 
    mov dx, offset pop_msg 
    jmp pop_segreg 
    
  taip_push_segreg: 
    mov dx, offset push_msg
  pop_segreg:    ;push/pop
    mov komandosDydis, 01h   
    
    call spausdink_be_komandos_eilute
    and al, 00011000b
    shl al, 02h           
    
    mov reg_dalis, al
    call spausdink_segmenta
    
    mov dx, offset enteris
    call spausdink_teksta
    
    jmp loopas
    
 taip_decreg:    
    mov dx, offset dec_msg
    jmp decreg
  
 taip_increg:
     mov dx, offset inc_msg
  
  decreg:     ;dec/inc
    mov komandosDydis, 01h
    call spausdink_be_komandos_eilute
    call stack_reg
    jmp loopas
            
 taip_popreg:      
    mov dx, offset pop_msg
    jmp popreg 
    
 taip_pushreg:
    mov dx, offset push_msg
  popreg:                     ;push/pop
    mov komandosDydis, 01h
    call spausdink_be_komandos_eilute
    call stack_reg
    jmp loopas
   
 taip_mov_ilgasis:
    call gaukKomandosIlgi_modRegRm
    mov dx, offset mov_msg
    call spausdink_be_komandos_eilute 
    call spausdink_mod_reg_rm_pilnas
    jmp loopas
       
    
 spausdink_mov_reg_rm:
 
 taip_mov_segreg:   
    mov dx, offset mov_msg
    jmp modregrm_bendras
 
 spausdink_add:   
    mov dx, offset add_msg
    jmp modregrm_bendras
    
 spausdink_cmp:
    mov dx, offset cmp_msg
    jmp modregrm_bendras
 taip_xor:
	mov dx, offset xor_msg
	jmp modregrm_bendras
 
 spausdink_sub:
    mov dx, offset sub_msg
     
   modregrm_bendras:
      
    call gaukKomandosIlgi_modRegRm 
    call spausdink_be_komandos_eilute  
    call spausdink_mod_reg_rm_pilnas
    jmp loopas     
    
 taip_mov_akum_atm:
    mov komandosDydis, 03h
    mov dx, offset mov_msg
    call spausdink_be_komandos_eilute
    call spausdink_mov_akum_ir_atm 
    jmp loopas
    
 taip_mov_wreg:
    call gauk_wreg_dydi
    mov dx, offset mov_msg
    call spausdink_be_komandos_eilute
    call spausdink_mov_wreg
    jmp loopas
    
  loopas: 
    mov dx, offset ats
    call Rasyk_faila
	sub cx, komandosDydis
	cmp cx, 0h   
	je pabaiga
	cmp cx, 0FFFFh
	jae pabaiga
	jmp mainloop
           
pabaiga: 
    mov dx, offset valio
    mov ah, 09h
    int 21h

    mov ah, 4Ch
    int 21h 
    
neatpazinau:
    mov dx, offset nezinau
    call spausdink_be_komandos_eilute
    
    mov dx, offset enteris
    call spausdink_teksta 
    
    mov dx, offset ats
    call Rasyk_faila
     
    dec cx 
    cmp cx, 0h   
	je pabaiga
	cmp cx, 0FFFFh
	jae pabaiga
    jmp mainloop 
    
    ; **********************************************
    ; **** PROCEDUROS ******************************
    ; **********************************************
    
PROC spausdink_2b 
    push ax
    push bx
    push dx
                 
    xor ax, ax
    
    mov bx, esamosKomandosPradzia
    mov al, byte ptr [bx+2]
    call spauskHex
    
    mov al, byte ptr [bx+1]
    call SpauskHex
    
    mov dx, offset enteris
    call spausdink_teksta 
    
    pop dx
    pop bx
    pop ax
    ret
                 
spausdink_2b ENDP

PROC skaiciuok_isorinis
    
    push ax
    push bx
    push dx
    
        mov bx, esamosKomandosPradzia
        
        mov al, byte ptr [bx+4]
        call spauskHex
        
        mov al, byte ptr [bx+3]
        call spauskHex
                        
        mov dx, offset dvitaskis
        call spausdink_teksta
    
        mov al, byte ptr [bx+2]
        call spauskHex

        mov al, byte ptr [bx+1]
        call spauskHex 
        
        mov dx, offset enteris
        call spausdink_teksta 
        
    pop dx
    pop bx
    pop ax
    ret
    
skaiciuok_isorinis ENDP 
    
PROC skaiciuok_vidinis_tiesioginis
    
    push ax
    push bx
    push cx
       
       mov bx, esamosKomandosPradzia
       
       mov al, byte ptr [bx+1]
       mov ah, byte ptr [bx+2]
       
       add ax, dabartinisIP
       
       call spauskHex
       
    mov dx, offset enteris
    call spausdink_teksta
    
    pop cx
    pop bx
    pop ax
    ret
    
skaiciuok_vidinis_tiesioginis ENDP
    
PROC spausdink_2bPoslinki_vidinis_artimas 
    
    push ax
    push bx
    push dx     
    
    mov bx, esamosKomandosPradzia
    
    xor ax, ax
  ;  mov al, byte ptr [bx+2] 
    
   ; call spauskHex 
    
    mov al, byte ptr [bx+1]  
    
    cmp al, 080h
    jae pleskFF
    jmp plesk00
    
        pleskFF:
            mov ah, 0FFh
            jmp spausdink_2bPoslinki_vidinis_artimas_toliau
        plesk00:
            mov ah, 000h
            jmp spausdink_2bPoslinki_vidinis_artimas_toliau 
            
        vidinis_artimas_pridek0:
            push ax
			push bx
            mov bx, offset ats
			mov byte ptr [bx+di], '0'
			inc di
			pop bx
            pop ax
            jmp vidinis_artimas_pridek0_toliau
            
    spausdink_2bPoslinki_vidinis_artimas_toliau:
        add ax, dabartinisIP 
        cmp ax, 1000h
        jb vidinis_artimas_pridek0 
    vidinis_artimas_pridek0_toliau:
        call spauskHex      
  
  spausdink_2bPoslinki_pabaiga: 
    mov dx, offset enteris
    call spausdink_teksta 
   
    pop dx
    pop bx
    pop ax
    ret
    
spausdink_2bPoslinki_vidinis_artimas ENDP
    
PROC Spausdink_modRmPos   
    
    push ax  
    push dx 
    
    call gaukPoslinki
    
    cmp mod_dalis, 03h
    je modRmPosMod3
    ; mod != 11
    mov al, rm_dalis
    call spausdink_ea_reiksme 
    jmp pabaiga_Spausdink_modRmPos
    
        modRmPosMod3: ;mod== 11
            and ax, 00000001b
            cmp ax, 01h
            je modRmPosMod3w1
            ;w != 1
            mov al, rm_dalis
            call spausdink_w0_operanda
            jmp pabaiga_Spausdink_modRmPos
            
                modRmPosMod3w1:
                    mov al, rm_dalis
                    call spausdink_w1_operanda
                    jmp pabaiga_Spausdink_modRmPos        
    
    
    pabaiga_Spausdink_modRmPos:
        mov dx, offset enteris
        call spausdink_teksta
        
        pop dx
        pop ax
        ret
    
    
Spausdink_modRmPos ENDP    
    
PROC stack_reg
    
    push cx 
    push ax      
    push dx
       
    mov cl, 05h
    shl al, cl
    
    mov reg_dalis, al
    
    call spausdink_w1_operanda 
    
    mov dx, offset enteris
    call spausdink_teksta
    
    pop dx
    pop ax   
    pop cx
    ret
    
stack_reg ENDP
    
PROC spausdink_mov_wreg 
    
    push ax
    push bx
    push cx
    push dx    
    
    mov bx, esamosKomandosPradzia
    mov al, byte ptr [bx] 
    mov cl, al
    
    shl cl, 5 ;xxx00000 reg 
    
    mov dl, byte ptr [bx+1] 
    mov dh, byte ptr [bx+2] 
    
    mov poslinkis1, dl
    mov poslinkis2, dh 
    xor dx, dx
       
    and al, 00001000b
    
    cmp al, 00000000b
    je w0reg
    
    ;w1reg
        xor ax, ax
        mov al, cl    ;reg dalis
        call spausdink_w1_operanda
        
        mov dx, offset kablelis_tarpas
        call spausdink_teksta
        
        mov al, poslinkis2
        call spauskHex
        
        mov al, poslinkis1
        call spauskHex          
        
        jmp spausdink_mov_wreg_pabaiga
        
     w0reg:
        xor ax, ax
        mov al, cl    ;reg dalis
        call spausdink_w0_operanda
        
        mov dx, offset kablelis_tarpas
        call spausdink_teksta
        
        mov al, poslinkis1
        call spauskHex 
        
        jmp spausdink_mov_wreg_pabaiga   
        
    spausdink_mov_wreg_pabaiga:
        
        mov dx, offset enteris
        call spausdink_teksta
        
        pop dx
        pop cx
        pop bx
        pop ax
        
        ret
    
spausdink_mov_wreg ENDP 
    
PROC gauk_wreg_dydi 
    push bx
    push ax
    
    mov bx, esamosKomandosPradzia
    mov al, byte ptr [bx]
       
    and al, 00001000b
    cmp al, 00000000b
    je wreg_dydis_2
    ;w=1
    mov komandosDydis, 03h
    jmp gauk_wreg_dydi_pabaiga
    
        wreg_dydis_2:
           mov komandosDydis, 02h
    gauk_wreg_dydi_pabaiga: 
    
    pop ax
    pop bx        
       
    ret
gauk_wreg_dydi ENDP  
    
    
PROC skaiciuokIP
    
    push ax
    
    mov ax, dabartinisIP     
    
    add ax, komandosDydis  
    mov dabartinisIP, ax
    
    pop ax
    ret
skaiciuokIP ENDP
    
PROC spausdink_mov_akum_ir_atm
    
    push ax
    push bx  
    push bp
    
    mov bx, esamosKomandosPradzia 
    
    mov bp, offset ats     
    
    mov al, byte ptr [bx+1]        
    mov ah, byte ptr [bx+2]
    
    mov poslinkis1, al
    mov poslinkis2, ah
    
    mov al, byte ptr [bx]
    
    cmp al, 0A0h
    je jmp_a0
    
    cmp al, 0A1h
    je jmp_a1
    
    cmp al, 0A2h
    je jmp_a2
    
    cmp al, 0A3h
    je jmp_a3
    jmp spausdink_mov_akum_ir_atm_pabaiga 
    
        jmp_a0: 
            xor ax, ax
            mov dx, offset al_msg
            call spausdink_teksta
            
            mov dx, offset kablelis_tarpas
            call spausdink_teksta  
            
            push ax
            
            mov byte ptr ds:[bp+di], '['
            inc di
            
            pop ax
            
            mov al, poslinkis2
            call spauskHex
            
            mov al, poslinkis1
            call spauskHex   
            
            push ax
            
            mov byte ptr ds:[bp+di], ']'
            inc di 
            
            pop ax
            
            jmp spausdink_mov_akum_ir_atm_pabaiga 
            
        jmp_a1: 
            xor ax, ax
            mov dx, offset ax_msg
            call spausdink_teksta
            
            mov dx, offset kablelis_tarpas
            call spausdink_teksta 
            
            push ax
            
            mov byte ptr ds:[bp+di], '['
            inc di 
            
            pop ax
            
            mov al, poslinkis2
            call spauskHex
            
            mov al, poslinkis1
            call spauskHex    
            
            push ax
            
            mov byte ptr ds:[bp+di], ']'
            inc di
            
            pop ax
            
            jmp spausdink_mov_akum_ir_atm_pabaiga  
            
        jmp_a2:  
            xor ax, ax
            
            push ax
            
            mov byte ptr ds:[bp+di], '['
            inc di 
            
            pop ax
            
            mov al, poslinkis2
            call spauskHex
            
            mov al, poslinkis1
            call spauskHex
            
            push ax
            
            mov byte ptr ds:[bp+di], ']'
            inc di
            
            pop ax

            mov dx, offset kablelis_tarpas
            call spausdink_teksta
            
            mov dx, offset al_msg
            call spausdink_teksta   
                                   
            jmp spausdink_mov_akum_ir_atm_pabaiga 
            
        jmp_a3:  
            xor ax, ax 
            push ax
            
            mov byte ptr ds:[bp+di], '['
            inc di 
            
            pop ax
            
            mov al, poslinkis2
            call spauskHex
            
            mov al, poslinkis1
            call spauskHex 
            
            push ax
            
            mov byte ptr ds:[bp+di], ']'
            inc di
            
            pop ax       
            
            mov dx, offset kablelis_tarpas
            call spausdink_teksta  
            
            mov dx, offset ax_msg
            call spausdink_teksta    
                                 
            jmp spausdink_mov_akum_ir_atm_pabaiga 
            
  spausdink_mov_akum_ir_atm_pabaiga: 
  
    mov dx, offset enteris
    call spausdink_teksta
    
    pop bp
    pop bx
    pop ax
    ret    
spausdink_mov_akum_ir_atm ENDP    
    
PROC spausdink_segmenta 
    
    ;************* 
    ; prielaida, kad reg_dalis jau suskaiciuota
    ;*************                                   
    
    push dx
       
    cmp reg_dalis, 00000000b
    je spausdink_es
    
    cmp reg_dalis, 00100000b
    je spausdink_cs
    
    cmp reg_dalis, 01000000b
    je spausdink_ss  
    
    cmp reg_dalis, 01100000b
    je spausdink_ds
    
    jmp spausdink_segmenta_pabaiga
                               
        spausdink_es:
            mov dx, offset es_msg
            jmp call_spausdink_segmenta
            
        spausdink_cs:
            mov dx, offset cs_msg
            jmp call_spausdink_segmenta 
            
        spausdink_ss:
            mov dx, offset ss_msg
            jmp call_spausdink_segmenta 
            
        spausdink_ds:
            mov dx, offset ds_msg
            jmp call_spausdink_segmenta  
            
    call_spausdink_segmenta:
        call spausdink_teksta
        jmp spausdink_segmenta_pabaiga
                               
    spausdink_segmenta_pabaiga:
        pop dx               
     
        ret   
spausdink_segmenta ENDP 
    
PROC spausdink_mod_reg_rm_pilnas
    
    push dx
    
    call Adresavimo_baitas_pilnas 
    
    mov dx, offset enteris
    call spausdink_teksta 
    
    pop dx
    ret   
    
spausdink_mod_reg_rm_pilnas ENDP
    
PROC gaukKomandosIlgi_modRegRm 
    
    push ax
       
    call gaukModRegRm 
    
    mov komandosDydis, 02h 
      
    cmp mod_dalis, 0h
    je gal_rm110
    
    cmp mod_dalis, 01h
    je kom3
    
    cmp mod_dalis, 02h
    je kom4
    
    cmp mod_dalis, 03h
    je kom2
    jmp pabaigaGaukIlgi
                    
  gal_rm110:
    cmp rm_dalis, 11000000b
    je kom4
    jmp pabaigaGaukIlgi
    
   kom3:
    mov komandosDydis, 03h
    jmp pabaigaGaukIlgi
    
   kom2:
    mov komandosDydis, 02h
    jmp pabaigaGaukIlgi
    
   kom4:
    mov komandosDydis, 04h
    jmp pabaigaGaukIlgi 
                    
   pabaigaGaukIlgi: 
   
    cmp al, 0C6h
    jae galIlgojoMov 
    jmp toliau_ilguju_add
    
   galIlgojoMov:
    cmp al, 0C7h
    jbe taipIlgojoMov
   
   toliau_ilguju_add:
    cmp al, 080h
    jae gal_ilguju_add
    jmp gauk_ilgi_ret  
    
   gal_ilguju_add:
    cmp al, 083h
    jbe taip_ilguju_add 
    jmp gauk_ilgi_ret
    
        taip_ilguju_add: 
            push bx    
            
            mov bx, esamosKomandosPradzia  
            add bx, komandosDydis
            and al, 00000011b
            
            cmp al, 00000000b
            je sw00
            
            cmp al, 00000001b
            je sw01
            
            cmp al, 00000010b
            je sw00
            ;sw11
            
            mov al, byte ptr [bx] ;*****ar tikrai??? BOB1 GAL REIKIA PLEST
            mov bob1, al
            inc komandosDydis 
            pop bx
            jmp gauk_ilgi_ret
            
                sw00:
                  mov al, byte ptr [bx]
                  mov bob1, al 
                  inc komandosDydis 
                  pop bx
                  jmp gauk_ilgi_ret
                
                sw01:                    
                    mov al, byte ptr [bx]
                    mov ah, byte ptr [bx+1]
                    
                    mov bob1, al
                    mov bob2, ah
                    
                    add komandosDydis, 02h 
                    pop bx
                    jmp gauk_ilgi_ret     
            
            
    
   taipIlgojoMov:
    shl al, 7
    cmp al, 10000000b
    je mov_ilgas_w1_dydis
    jmp mov_ilgas_w0_dydis
    
   gauk_ilgi_ret:
     
    pop ax
    ret     
    
   mov_ilgas_w1_dydis: 
     add komandosDydis, 02h    
     push bx
     push ax
     
     mov bx, esamosKOmandospradzia 
     
     mov al, byte ptr [bx+4]   
     mov ah, byte ptr [bx+5] 
     
     mov bob1, al
     mov bob2, ah
     
     pop ax
     pop bx
     jmp gauk_ilgi_ret 
     
   mov_ilgas_w0_dydis:  
     push ax
     push bx
     mov bx, esamosKomandosPradzia
   
     add komandosDydis, 01h 
     add bx, komandosDydis 
     dec bx
     mov al, byte ptr [bx]    
     mov bob1, al
     pop bx  
     pop ax
     
     jmp gauk_ilgi_ret
       
    
    
gaukKomandosIlgi_modRegRm ENDP
    
PROC gaukModRegRm
    
    push bx
    push cx
    push dx 
    push si
    
    xor si, si
    
    mov si, esamosKomandosPradzia 
    inc si
             
    mov bl, byte ptr [si]  ;mod  
    mov cl, byte ptr [si]  ;reg
    mov dl, byte ptr [si]  ;r/m  
    
    shr bl, 6           ;000000xxb MOD

    shr cl, 3
    shl cl, 5           ;xxx00000b REG
    
    shl dl, 5           ;xxx00000b r/m   
    
    mov mod_dalis, bl
    mov reg_dalis, cl
    mov rm_dalis, dl 
    
    pop si
    pop dx
    pop cx
    pop bx
                 
    ret    
gaukModRegRm ENDP
    
PROC Adresavimo_baitas_pilnas 
    
    push dx
    push cx
    push bx
    push ax
                            
   ; call gaukModRegRm
    
    call gaukPoslinki 
    
    push bx
    mov bx, esamosKomandosPradzia
    
    mov al, byte ptr [bx]
         
    pop bx 
    
    ; *********************
    ; gal mov segreg <-> rm ???
    ; *********************
    
    cmp al, 08Ch
    jae gal_proc_adr_baitas_seg
    jmp ilgmov
    
        gal_proc_adr_baitas_seg:
            cmp al, 08Eh
            jbe taip_proc_adr_baitas_seg  
            jmp ilgmov 
   ilgmov: 
    cmp al, 0C6h
    je ilgasis_mov_adr
    
    cmp al, 0C7h
    je ilgasis_mov_adr
    jmp toliau_gal_ilgiAddSub
    
  toliau_gal_ilgiAddSub:
    cmp al, 080h
    jae gal_ilgiAddSub2
    jmp raskdw
    
       gal_ilgiAddSub2:
            cmp al, 083h
            jbe taip_ilgiAddSub2     
    
    
             
raskdw:             
    shl al, 6  
    mov dw_dalis, al   
    
    
    cmp al, 00000000b
    je d0w0
    
    cmp al, 01000000b
    je d0w1
    
    cmp al, 10000000b
    je d1w0
    
    cmp al, 11000000b
    je d1w1               
    
d1w0:
    cmp mod_dalis, 0h
    je mod00  
    
    cmp mod_dalis, 02h  
    je mod10         
    
    cmp mod_dalis, 01h  
    je mod01
    
    ;mov komandosDydis, 02h
    
    mov al, reg_dalis
    call Spausdink_w0_operanda 
    
    mov dx, offset kablelis_tarpas
    call Spausdink_teksta   
    
    mov al, rm_dalis
    call Spausdink_w0_operanda   
    
    jmp pabaiga_adrbaitas_proc 
    
    
    
mod00:    
     
     mov al, dw_dalis
     and al, 11000000b
     
     cmp al, 00000000b
     je mod00d0w0
     
     cmp al, 11000000b
     je mod00d1w1  
     
     cmp al, 01000000b
     je mod00d0w1
     
    
     mov al, reg_dalis
     call SPausdink_w0_operanda
   
     mov dx, offset kablelis_tarpas
     call Spausdink_teksta
   
     mov al, rm_dalis
     call Spausdink_ea_reiksme
     jmp pabaiga_adrbaitas_proc
     
  mod00d0w1:
     mov al, rm_dalis
     call Spausdink_ea_reiksme
   
     mov dx, offset kablelis_tarpas
     call Spausdink_teksta
   
     mov al, reg_dalis
     call Spausdink_w1_operanda
     jmp pabaiga_adrbaitas_proc 
     
  mod00d0w0:
     mov al, rm_dalis
     call Spausdink_ea_reiksme
   
     mov dx, offset kablelis_tarpas
     call Spausdink_teksta
   
     mov al, reg_dalis
     call Spausdink_w0_operanda
     jmp pabaiga_adrbaitas_proc 
     
  mod00d1w1: 
     
  
     mov al, reg_dalis
     call SPausdink_w1_operanda
   
     mov dx, offset kablelis_tarpas
     call Spausdink_teksta
   
     mov al, rm_dalis
     call Spausdink_ea_reiksme
     jmp pabaiga_adrbaitas_proc
      
   
mod10: 

    ;mov komandosDydis, 04h 

    mov al, dw_dalis
    and al, 11000000b
     
    cmp al, 00000000b
    je mod10d0w0 
    
    cmp al, 10000000b
    je mod10d1w0 
    
    cmp al, 01000000b
    je mod00d0w1

    mov al, reg_dalis
    call Spausdink_w1_operanda
    
    mov dx, offset kablelis_tarpas
    call Spausdink_teksta
    
    mov al, rm_dalis
    call Spausdink_ea_reiksme  
    
    jmp pabaiga_adrbaitas_proc 
    
  mod10d0w0:
     mov al, rm_dalis
     call Spausdink_ea_reiksme
   
     mov dx, offset kablelis_tarpas
     call Spausdink_teksta
   
     mov al, reg_dalis
     call Spausdink_w0_operanda   
     
     jmp pabaiga_adrbaitas_proc 
     
  mod10d0w1:
     mov al, rm_dalis
     call Spausdink_ea_reiksme
   
     mov dx, offset kablelis_tarpas
     call Spausdink_teksta
   
     mov al, reg_dalis
     call Spausdink_w1_operanda   
     
     mov dx, offset enteris
     call spausdink_teksta
     
     jmp pabaiga_adrbaitas_proc  
     
  mod10d1w0:
     mov al, reg_dalis
     call Spausdink_w0_operanda
   
     mov dx, offset kablelis_tarpas
     call Spausdink_teksta
   
     mov al, rm_dalis
     call Spausdink_ea_reiksme  
     
     jmp pabaiga_adrbaitas_proc  
    
mod01:   

    ;mov komandosDydis, 03h

    mov al, dw_dalis
    and al, 10000000b
     
    cmp al, 00000000b
    je mod01d0 
    
    mov al, dw_dalis
    and al, 01000000b
    
    cmp al, 01000000b
    je mod01w1

    mov al, reg_dalis
    call Spausdink_w0_operanda 
    jmp mod01next
    
  mod01w1:
  
    mov al, reg_dalis
    call Spausdink_w1_operanda
    
  mod01next: 
   
    mov dx, offset kablelis_tarpas
    call Spausdink_teksta
    
    mov al, rm_dalis
    call Spausdink_ea_reiksme     
    
    jmp pabaiga_adrbaitas_proc  
    
  mod01d0:
     mov al, rm_dalis
     call Spausdink_ea_reiksme
   
     mov dx, offset kablelis_tarpas
     call Spausdink_teksta
   
     mov al, reg_dalis
     call Spausdink_w0_operanda      

     jmp pabaiga_adrbaitas_proc   
         
d0w0: 

    cmp mod_dalis, 0h
    je mod00  
    
    cmp mod_dalis, 02h  
    je mod10         
    
    cmp mod_dalis, 01h  
    je mod01 
             
    mov al, rm_dalis
    call Spausdink_w0_operanda 
    
    mov dx, offset kablelis_tarpas
    call Spausdink_teksta   
    
    mov al, reg_dalis
    call Spausdink_w0_operanda  
    
    jmp pabaiga_adrbaitas_proc    
    
d0w1:  

    cmp mod_dalis, 0h
    je mod00  
    
    cmp mod_dalis, 02h  
    je mod10         
    
    cmp mod_dalis, 01h  
    je mod01  
    
  ;  mov komandosDydis, 02h

    mov al, rm_dalis
    call Spausdink_w1_operanda
    
    mov dx, offset kablelis_tarpas
    call Spausdink_teksta
    
    mov al, reg_dalis
    call Spausdink_w1_operanda  
  
    jmp pabaiga_adrbaitas_proc 
    
d1w1:    

    cmp mod_dalis, 0h
    je mod00  
    
    cmp mod_dalis, 02h  
    je mod10         
    
    cmp mod_dalis, 01h  
    je mod01   
    
  ;  mov komandosDydis, 02h
    
    mov al, reg_dalis
    call Spausdink_w1_operanda
    
    mov dx, offset kablelis_tarpas
    call Spausdink_teksta
    
    mov al, rm_dalis
    call Spausdink_w1_operanda 
    
    jmp pabaiga_adrbaitas_proc 
    
 ; *************************
 ; jei komanda mov segreg <-> r/m      
 ; *************************
 
 taip_proc_adr_baitas_seg:  
 
    mov cl, 06h
    shl al, cl 
    
    cmp mod_dalis, 03h
    je segmod11
    
    cmp al, 00000000b
    je segd0modne11 
    
    
    ; d=1
    
    call spausdink_segmenta         
    
    mov dx, offset kablelis_tarpas
    call spausdink_teksta
    
    call spausdink_ea_reiksme
    jmp pabaiga_adrbaitas_proc 
    
        segd0modne11:
          call spausdink_ea_reiksme
          mov dx, offset kablelis_tarpas
          call spausdink_teksta
            
          call spausdink_segmenta
          jmp pabaiga_adrbaitas_proc   
  
  
    segmod11:
        cmp al,00000000b
        je segd0mod11
        
        call spausdink_segmenta   
        
        mov dx, offset kablelis_tarpas
        call spausdink_teksta
        
        mov al, rm_dalis
        call spausdink_w1_operanda
        jmp pabaiga_adrbaitas_proc   
        
            segd0mod11:  
                mov al, rm_dalis
                call spausdink_w1_operanda   
        
                mov dx, offset kablelis_tarpas
                call spausdink_teksta
                
                call spausdink_segmenta
                jmp pabaiga_adrbaitas_proc 
                
  ilgasis_mov_adr:
   
    mov al, rm_dalis
    call spausdink_ea_reiksme
    
    mov dx, offset kablelis_tarpas
    call spausdink_teksta 
      
    
    mov bx, esamosKomandosPradzia
    mov al, byte ptr [bx]
    and al, 00000001b      ; x00000000b w bitas
    cmp al, 00000001b
    je ilgasis_mov_w1 
    
    xor ax, ax   
    
    mov al, bob1
    call spauskHex
    
    jmp pabaiga_adrbaitas_proc
    
  ilgasis_mov_w1:
    
    xor ax, ax
    
    mov al, bob2
    call spauskHex 
    
    xor ax, ax   
    
    mov al, bob1
    call spauskHex 
   
    jmp pabaiga_adrbaitas_proc 
    
    
    ;****************
    ; ilgi add sub cmp
    ;****************
    
    taip_ilgiAddSub2:
        push ax; issaugom komkoda
        cmp mod_dalis, 03h
        je taip_ilgiAddSub2_mod3
        ;mod!=11:
        
        mov al, rm_dalis
        call spausdink_ea_reiksme    
        
      taip_ilgiAddSub2_spausk_bob: 
        
        mov dx, offset kablelis_tarpas
        call spausdink_teksta
        
        pop ax ;ax=komkodas
        
        and al, 00000010b
        cmp al, 00000010b
        je taip_ilgiAddSub2_s1
        ;s=0:
        xor ax, ax
        
        mov al, bob2
        call spauskHex
        
      taip_ilgiAddSub2_s1:
        xor ax, ax
        mov al, bob1
        call spauskHex 
        jmp pabaiga_adrbaitas_proc
        
            taip_ilgiAddSub2_mod3:
                and al, 00000001b ;gavom w
                cmp al, 00000001b
                je taip_ilgiAddSub2_mod3_w1
                ;w=0:
                mov al, rm_dalis
                call spausdink_w0_operanda
                jmp taip_ilgiAddSub2_spausk_bob  
                
            taip_ilgiAddSub2_mod3_w1:
                mov al, rm_dalis
                call spausdink_w1_operanda
                jmp taip_ilgiAddSub2_spausk_bob                      
    
    
  pabaiga_adrbaitas_proc:
    
    pop ax
    pop bx
    pop cx
    pop dx
    ret
    
Adresavimo_baitas_pilnas ENDP
    
PROC GaukPoslinki
    
    push ax
    push bx
    
    mov bx, esamosKomandosPradzia      
    
    mov al, byte ptr [bx+2]        
    mov ah, byte ptr [bx+3] 
       
    cmp mod_dalis, 0h
    je galTiesioginisAdr
    
    cmp mod_dalis, 01h
    je vienasPoslinkis
    
    cmp mod_dalis, 02h
    je duPoslinkiai
    
    jmp pabaigaGaukPoslinki  
    
  vienasPoslinkis:
    mov poslinkis1, al
    jmp pabaigaGaukPoslinki
    
  duPoslinkiai:    
    mov poslinkis1, al
    mov poslinkis2, ah
    jmp pabaigaGaukPoslinki
    
  galTiesioginisAdr:
    cmp rm_dalis, 11000000b
    je taipTiesioginisAdr
    jmp pabaigaGaukPoslinki
  
  taipTiesioginisAdr:  
  ;  mov komandosDydis, 04h
    mov poslinkis1, al
    mov poslinkis2, ah
    jmp pabaigaGaukPoslinki  
  
    
    pabaigaGaukPoslinki: 
    pop bx
    pop ax
    ret
    
GaukPoslinki ENDP
    
PROC SpauskHex  
    ; ax - spausdinamas skaicius
    
    push ax
    push cx
    push dx  
    push bx
    push 02424h  
    
    mov bx, offset ats   
    
    mov bp, ax 
    
    mov cx, 10h
    
  Dalink:
    mov dx, 0h
    div cx  
    cmp dx, 09h
    jg spauskRaide  
    add dl, 30h
    push dx
    cmp bp, 10h
    jb pridek0
    tesk:
        
    cmp ax, 0
    ja Dalink
    
    mov ah, 02h
  Spausdink:
    pop dx
    cmp dx, 02424h
    je procpabaiga   
    mov byte ptr [bx+di], dl
    inc di
    jmp Spausdink   
    
  spauskRaide:
    add dx, 37h
    push dx 
    
    cmp bp, 10h
    jb pridek01
  tesk1:
    cmp ax, 0
    ja Dalink  
    mov ah, 02h
    jmp spausdink 
    
  pridek0:
    push 00030h
    jmp tesk 
    
  pridek01:
    push 00030h
    jmp tesk1
    
  procpabaiga: 
    
    pop bx
    pop dx
    pop cx
    pop ax
       
    ret
    
SpauskHex ENDP
     
    
PROC Spausdink_ea_reiksme  
    
    ; SALYGA - JAU TURIM POSLINKI REIKSME
   
    push dx 
    push ax       
    
    mov al, rm_dalis 
    
    push ax
    
	push bx
	mov bx, offset ats
	mov byte ptr [bx+di], '['
	inc di
	pop bx
    
    pop ax
    
    cmp rm_dalis, 11000000b
    je galTiesioginis  
    jmp skipGalTiesioginis
     
  galTiesioginis:
    cmp mod_dalis, 0h
    je spausdink_pos
    
    skipGalTiesioginis:
    
    cmp al, 00000000b
        je spausdink_bxsipos
    
    cmp al, 00100000b
        je spausdink_bxdipos
    
    cmp al, 01000000b
        je spausdink_bpsipos 
    
    cmp al, 01100000b
        je spausdink_bpdipos   
    
    cmp al, 10000000b
        je spausdink_sipos   
    
    cmp al, 10100000b
        je spausdink_dipos
    
    cmp al, 11000000b
        je spausdink_bppos   
    
    cmp al, 11100000b
        je spausdink_bxpos
 ; ****************************   
  spausdink_bxsipos:  
    xor ax, ax
    
    mov dx, offset bx_msg
    call Spausdink_teksta  
    
    call SpauskPliusa
    
    mov dx, offset si_msg
    call Spausdink_teksta 
    
    cmp mod_dalis, 0h
    je Spausdink_ea_reiksme_pabaiga
    
    call SpauskPliusa 
    
    jmp Spausdink_poslinkius_ea
    
    jmp Spausdink_ea_reiksme_pabaiga 
    
  ; **************************    
  
  spausdink_bxdipos:  
    
    xor ax, ax
    mov dx, offset bx_msg
    call Spausdink_teksta  
    
    call SpauskPliusa
    
    mov dx, offset di_msg
    call Spausdink_teksta  
    
    cmp mod_dalis, 0h
    je Spausdink_ea_reiksme_pabaiga
    
    call SpauskPliusa 
    
    jmp Spausdink_poslinkius_ea
    
    jmp Spausdink_ea_reiksme_pabaiga
  ; ********************************   
  spausdink_bpsipos:    
    xor ax, ax 
    
    mov dx, offset bp_msg
    call Spausdink_teksta  
    
    call SpauskPliusa
    
    mov dx, offset si_msg
    call Spausdink_teksta  
    
    cmp mod_dalis, 0h
    je Spausdink_ea_reiksme_pabaiga
    
    call SpauskPliusa 
    
    jmp Spausdink_poslinkius_ea
    
    jmp Spausdink_ea_reiksme_pabaiga
    
  spausdink_bpdipos:  
   
    xor ax, ax
  
    mov dx, offset bp_msg
    call Spausdink_teksta  
    
    call SpauskPliusa
    
    mov dx, offset di_msg
    call Spausdink_teksta 
     
    cmp mod_dalis, 0h
    je Spausdink_ea_reiksme_pabaiga
    
    call SpauskPliusa 
    
    jmp Spausdink_poslinkius_ea
    
    jmp Spausdink_ea_reiksme_pabaiga
    
  ; ***************************
  ; kitos rm reiksmes
  ; ************************  
  
  spausdink_sipos: 
    xor ax, ax
  
    mov dx, offset si_msg
    call Spausdink_teksta  
    
    cmp mod_dalis, 0h
    je Spausdink_ea_reiksme_pabaiga
    
    call SpauskPliusa 
    
    jmp Spausdink_poslinkius_ea
    
    jmp Spausdink_ea_reiksme_pabaiga
    
  spausdink_dipos:  
    xor ax, ax
  
    mov dx, offset di_msg
    call Spausdink_teksta  
    
    cmp mod_dalis, 0h
    je Spausdink_ea_reiksme_pabaiga
    
    call SpauskPliusa 
    
    jmp Spausdink_poslinkius_ea
    
    jmp Spausdink_ea_reiksme_pabaiga  
    
  spausdink_bppos:   
    xor ax, ax
  
    mov dx, offset bp_msg
    call Spausdink_teksta  
    
    cmp mod_dalis, 0h
    je Spausdink_ea_reiksme_pabaiga
    
    call SpauskPliusa 
    
    jmp Spausdink_poslinkius_ea
                                      
 spausdink_bxpos:
    
    xor ax, ax
 
    mov dx, offset bx_msg
    call Spausdink_teksta  
    
    cmp mod_dalis, 0h
    je Spausdink_ea_reiksme_pabaiga
    
    call SpauskPliusa 
    
    jmp Spausdink_poslinkius_ea   
    
  spausdink_pos: 
                                      
  Spausdink_poslinkius_ea: 
    
    cmp mod_dalis, 01h
    je pos1_1
    
    mov al, poslinkis2
    call SpauskHex   
    
  pos1_1:
    
    mov al, poslinkis1
    call SpauskHex
    
    Spausdink_ea_reiksme_pabaiga:
    
    push bx
	mov bx, offset ats
	mov byte ptr [bx+di], ']'
	inc di
	pop bx
  
    pop ax        
    pop dx
    ret
    ;;;;;;;;;;;;;;;;;
                         
Spausdink_ea_reiksme ENDP

PROC Spausdink_w1_operanda
                          
    push dx
    
    cmp al, 00000000b
        je spausdink_ax
    
    cmp al, 00100000b
        je spausdink_cx
    
    cmp al, 01000000b
        je spausdink_dx 
    
    cmp al, 01100000b
        je spausdink_bx   
    
    cmp al, 10000000b
        je spausdink_sp   
    
    cmp al, 10100000b
        je spausdink_bp
    
    cmp al, 11000000b
        je spausdink_si   
    
    cmp al, 11100000b
        je spausdink_di
    
  spausdink_ax:
    mov dx, offset ax_msg
    jmp Spausdink_w1_operanda_pabaiga     
  
  spausdink_bx:
    mov dx, offset bx_msg
    jmp Spausdink_w1_operanda_pabaiga
    
  spausdink_cx:
    mov dx, offset cx_msg
    jmp Spausdink_w1_operanda_pabaiga
    
  spausdink_dx:
    mov dx, offset dx_msg
    jmp Spausdink_w1_operanda_pabaiga
    
  spausdink_sp:
    mov dx, offset sp_msg
    jmp Spausdink_w1_operanda_pabaiga     
  
  spausdink_bp:
    mov dx, offset bp_msg
    jmp Spausdink_w1_operanda_pabaiga
    
  spausdink_si:
    mov dx, offset si_msg
    jmp Spausdink_w1_operanda_pabaiga
    
  spausdink_di:
    mov dx, offset di_msg
    jmp Spausdink_w1_operanda_pabaiga  
    
  Spausdink_w1_operanda_pabaiga:   
	call Spausdink_teksta
    pop dx
    ret
    
Spausdink_w1_operanda endp    

    
PROC Spausdink_w0_operanda
                       
    push dx
       
    cmp al, 00000000b
        je spausdink_al
    
    cmp al, 00100000b
        je spausdink_cl
    
    cmp al, 01000000b
        je spausdink_dl 
    
    cmp al, 01100000b
        je spausdink_bl   
    
    cmp al, 10000000b
        je spausdink_ah   
    
    cmp al, 10100000b
        je spausdink_ch
    
    cmp al, 11000000b
        je spausdink_dh   
    
    cmp al, 11100000b
        je spausdink_bh
    
  spausdink_al:
    mov dx, offset al_msg
    call Spausdink_teksta
    jmp Spausdink_w0_operanda_pabaiga     
  
  spausdink_bl:
    mov dx, offset bl_msg
    call Spausdink_teksta
    jmp Spausdink_w0_operanda_pabaiga
    
  spausdink_cl:
    mov dx, offset cl_msg
    call Spausdink_teksta
    jmp Spausdink_w0_operanda_pabaiga
    
  spausdink_dl:
    mov dx, offset dl_msg
    call Spausdink_teksta
    jmp Spausdink_w0_operanda_pabaiga
    
  spausdink_ah:
    mov dx, offset ah_msg
    call Spausdink_teksta
    jmp Spausdink_w0_operanda_pabaiga     
  
  spausdink_bh:
    mov dx, offset bh_msg
    call Spausdink_teksta
    jmp Spausdink_w0_operanda_pabaiga
    
  spausdink_ch:
    mov dx, offset ch_msg
    call Spausdink_teksta
    jmp Spausdink_w0_operanda_pabaiga
    
  spausdink_dh:
    mov dx, offset dh_msg
    call Spausdink_teksta
    jmp Spausdink_w0_operanda_pabaiga    
  
Spausdink_w0_operanda_pabaiga:     
    pop dx
    ret
    
Spausdink_w0_operanda endp  

PROC Spausdink_teksta
    
    push ax 
    push bx
    
  cycle:    
    mov bx, dx
    mov al, byte ptr[bx]
    cmp al, 24h
    je pabaiga_cycle   
    
    push bx
    mov bx, offset ats
    
    mov byte ptr[bx+di], al
    inc dx
    inc di 
    pop bx
    jmp cycle
   
  pabaiga_cycle:
    
    pop bx   
    pop ax
    ret
    
Spausdink_teksta endp   

PROC SpauskPliusa
    
    push bx
    
    mov bx, offset ats
    mov byte ptr [bx+di], '+'
    inc di 
	
    pop bx
    ret          
    
SpauskPliusa ENDP   
                              
PROC spausdink_be_komandos_eilute
    
    push bx
    push cx
    push ax
    push dx
    push si 
    
    mov si, dx      
    
    cmp dabartinisIP, 1000h
    jb pridek0PrieIp 
    
  tesk_spausk_ip:
    
    mov ax, dabartinisIP
    call spauskHex   
  
    
    call skaiciuokIP
 
    push bx
    
    mov bx, offset ats
    
    mov dl, 3Ah     ; ':'
    mov ah, 02h
    mov byte ptr [bx+di], 3Ah 
    inc di
    
    mov byte ptr [bx+di], 20h 
    inc di
    pop bx
    
    xor cx, cx      ; kiek baitu uzima komanda
    mov cx, komandosDydis  
    mov bx, esamosKomandosPradzia
    
  komLoop:
    xor ax, ax
    mov al, byte ptr [bx]
    call spauskHex 
    
    push bx
    
    mov bx, offset ats
    
    mov byte ptr [bx+di], 20h
    inc di
    
    pop bx
    
    inc bx 
    loop komLoop    
    
    push si
    
    mov si, 21d
    xor ax, ax
    mov ax, komandosDydis
    mov dx, 02h
    mul dx
    mov cx, komandosDydis
    dec cx
    add cx, ax
    
    sub si, cx
    mov cx, si
    push bx
    mov bx, offset ats
    
  intend:
    
    mov byte ptr [bx+di], 20h 
    inc di  
    
    loop intend 
    pop bx
    pop si
    
    mov dx, si
    call spausdink_teksta  
    jmp spausdink_be_komandos_eilute_pabaiga
    
  pridek0PrieIp:
    push bx
    mov bx, offset ats
   
    mov byte ptr [bx+di], 30h 
    inc di  
    
    pop bx
    jmp tesk_spausk_ip
    
  spausdink_be_komandos_eilute_pabaiga:
    
    pop si
    pop dx
    pop ax
    pop cx
    pop bx                           
 
    ret     
     
    spausdink_be_komandos_eilute ENDP


PROC OpenFile 
    
    push ax
    push bx
    push cx
    push dx
    
    mov ah, 3Dh
    mov al, 00h
    mov dx, offset duomenuFailas
	int 21h
    jc klaidaAtidarant
    mov dFail, ax  
    
    ;duomenu skaitymas 
    
    xor ax, ax
    
    mov bx, dFail
    mov ah, 3Fh
    mov cx, skBufDydis  
    mov dx, offset baitai
    int 21h
    jc klaidaSkaitant
    
    mov failoDydis, ax
    
  openfile_pabaiga:  
    pop dx
    pop cx
    pop bx
    pop ax
    
    ret
    
  klaidaAtidarant:
    mov dx, offset klAtidarant
    mov ah, 09h
	int 21h
    jmp pabaiga
    
  klaidaSkaitant: 
    mov dx, offset klSkaitant
    mov ah, 09h
	int 21h
    jmp pabaiga
OpenFile ENDP 

PROC nusinulink_ats
    
    push bx
    push cx 
    push di
    
    mov bx, offset ats
    xor cx, cx 
    inc di
    mov cx, di
    
  varom:
    mov byte ptr [bx], 20h
    inc bx
    loop varom
    
    pop di
    pop cx
    pop bx
    
    ret
nusinulink_ats ENDP  

PROC rez_failo_sukurimas  
    
    push dx
    push cx
    push ax
    
    mov ah, 3Ch
    mov cx, 0
    mov dx, offset rezultatuFailas
    int 21h
    jc klaidaSukuriant
    mov rFail, ax 
    
    sukurimo_pabaiga:
    pop ax
    pop cx
    pop dx
    ret
    
  klaidaSukuriant:
    mov dx, offset klAtidarant
    call spausdink_teksta
    jmp pabaiga
    
rez_failo_sukurimas ENDP    

PROC Rasyk_faila 
    
    ; I DX PADUODAM KA RASYSIM 
    
    push ax
    push bx
    push cx
    
    mov cx, di ; ******** kiek baitu kist i faila
    mov bx, rFail
    mov ah, 40h
    int 21h
    jc klaidaRasatnt
    
  pabaiga_rasyk:
    pop cx
    pop bx
    pop ax
    
    ret
    
  klaidaRasatnt:
    mov dx, offset klSkaitant
    call spausdink_teksta
    jmp pabaiga
    
Rasyk_faila ENDP

PROC gaukParametrus
		
		
		push bp
		push si
		push dx
		push cx
		push bx
		push ax

		xor cx, cx
        mov cl, es:80h  ; i cl keliam kiek simboliu ivesta i komandine eilute
        dec cl          
        cmp cl, 0       ; jei nulis, spausdinam pagalba
        je pagalba  
        dec cl          ; sumazinam cl, kad neskaitytu tarpo
        
        mov bx, 82h     ; 81h-bus tarpas, tai ivesti simboliai prasideda nuo 82h
		; ================================================
		
		ieskokPagalbos:
        cmp word ptr [es:bx], '?/' 
        je pagalba
        inc bx          ; einam i kita baita
        loop ieskokPagalbos             ; pereinam visus simbolius. Jei nebuvo /?, tesiam darba
        
        xor cx, cx                
        mov cl, es:80h  ; atnaujiam cl 
        cmp cl, 0
        je pagalba  
        dec cl          ; del tarpo susimazinam
         
        mov bx, 82h 
        mov bp, offset duomenuFailas    ; bp laikysim temp duom failo pavadinimo adresa
        
    ieskokPirmoParametro:               
        mov ax, es:bx                   ; i ax keliam pirma (nu antra) eilutes simboli 
        mov ds:[bp+si], al              ; i duomenu segmente esanti d. failo pavadinimo adresa keliam po 1 simboli
        inc si                          ; rasysim i kita baita
        inc bx                          ; zurim kita baita         
             
        cmp al, 20h                     ; jei radom tarpa
        je pirmoParametroPabaiga        ; baigiam skaityt pirma parametra
        loop ieskokPirmoParametro       ; jei ne, perskaitom viska iki tarpo
               
     pirmoParametroPabaiga:
        dec si                          ; mazinam si, kad ziuretu i baito po paskutinio simbolio
        mov byte ptr ds:[bp+si], 0      ; irasom 0, ne failas skaito iki 0 zenklo. Realiai nereikia nes masyva uzpildem nuliais
        mov bp, offset rezultatuFailas  ; kartojam su antro failo pavadinimu
        
        xor si, si                      ; nusivalom si
        cmp cl, 0                       ; jei baigesi ivesti simboliai
        je vienas                       ; buvo ivestas tik 1 zodis
                                                              
    ieskokAntroParametro:   
        mov ax, es:bx                   ; nusiskaitom rez faila
        mov ds:[bp+si], al
        inc si
        inc bx
        
        cmp al, 20h
        je antroParametroPabaiga  
        loop ieskokAntroParametro
    antroParametroPabaiga:
        dec si
        mov byte ptr ds:[bp+si], 0 
		jmp pabaigaGaukParametrus
		
		pagalba:
			mov dx, offset pagalbosPranesimas
			mov ah, 09h
			int 21h
			jmp pabaiga
		vienas:
			mov dx, offset mazai_parametru
			mov ah, 09h
			int 21h
			jmp pabaiga
		
	pabaigaGaukParametrus:
	
		pop ax
		pop bx
		pop cx
		pop dx
		pop si
		pop bp
		ret

gaukParametrus ENDP
    

end start