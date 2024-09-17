*-----------------------------------------------------------
* Title      : Endless Runner
* Written by : Conor Hendley
* Date       : 19/02/2024
* Description: Endless Runner Project
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    
*--------------------------
* Section       : Trap Codes
* Description   : Trap Codes used throughout StarterKit
*-----------------------------------------------------------
* Trap CODES
TC_SCREEN   EQU         33          ; Screen size information trap code
TC_S_SIZE   EQU         00          ; Places 0 in D1.L to retrieve Screen width and height in D1.L
                                    ; First 16 bit Word is screen Width and Second 16 bits is screen Height
TC_KEYCODE  EQU         19          ; Check for pressed keys
TC_DBL_BUF  EQU         92          ; Double Buffer Screen Trap Code
TC_CURSR_P  EQU         11          ; Trap code cursor position

TC_EXIT     EQU         09          ; Exit Trapcode

*-----------------------------------------------------------
* Section       : Charater Setup
* Description   : Size of Player and Enemy and properties
* of these characters e.g Starting Positions and Sizes
*-----------------------------------------------------------
PLYR_W_INIT EQU         08          ; Players initial Width
PLYR_H_INIT EQU         08          ; Players initial Height
PLYR_HEALT_INIT EQU     100         ; PLAYER INITIAL HEALTH

PLYR_DFLT_V EQU         00          ; Default Player Velocity
PLYR_JUMP_V EQU        -20          ; Player Jump Velocity
PLYR_DFLT_G EQU         02          ; Player Default Gravity

GND_TRUE    EQU         01          ; Player on Ground True
GND_FALSE   EQU         00          ; Player on Ground False

RUN_INDEX   EQU         00          ; Player Run Sound Index  
JMP_INDEX   EQU         01          ; Player Jump Sound Index  
OPPS_INDEX  EQU         02          ; Player Opps Sound Index
PICKUP_INDEX    EQU     03          ; Player Pickup Sound Index

ENMY_W_INIT EQU         08          ; Enemy initial Width
ENMY_H_INIT EQU         30          ; Enemy initial Height

ENMY_W_INIT_2 EQU       06          ; Second Enemy initial Width
ENMY_H_INIT_2 EQU       06          ; Second Enemy initial Height

HELTH_PU_W_INIT     EQU     10      ; Health pickup initial width
HELTH_PU_H_INIT     EQU     10      ; Health pickup initial hight

DAMAGE_INIT EQU         20          ; Initial damage for first enemy

DAMAGE_INIT_2 EQU       100         ; Initial damage for second enemy

HEALTH_PU_INIT  EQU     10          ; Initial health pickup

FLAG_TRUE_INIT   EQU     1          ; True flag, collision flag set to true when collision first occures and false by default, stops collission occuring multiple times
FLAG_FALSE_INIT  EQU     0          ; False flag


*-----------------------------------------------------------
* Section       : Health bar Setup
* Description   : loaction of Player health bar
*-----------------------------------------------------------
BAR_X_INIT     EQU         420 ; These are the corodinates for the health bar on the screen
BAR_Y_INIT     EQU         60
BAR_X_2_INIT   EQU         520
BAR_Y_2_INIT   EQU         80

*-----------------------------------------------------------
* Section       : Ground Setup
* Description   : loaction of Player health bar
*-----------------------------------------------------------
GROUND_X_INIT     EQU         0
GROUND_Y_INIT     EQU         240
GROUND_X_2_INIT   EQU         640
GROUND_Y_2_INIT   EQU         480

*-----------------------------------------------------------
* Section       : SKY Setup
* Description   : loaction of Player health bar
*-----------------------------------------------------------
SKY_X_INIT     EQU         0
SKY_Y_INIT     EQU         0
SKY_X_2_INIT   EQU         640
SKY_Y_2_INIT   EQU         240

*-----------------------------------------------------------
* Section       : Game Stats
* Description   : Points
*-----------------------------------------------------------
POINTS      EQU         01          ; Points added

*-----------------------------------------------------------
* Section       : Keyboard Keys
* Description   : Spacebar and Escape or two functioning keys
* Spacebar to JUMP and Escape to Exit Game
*-----------------------------------------------------------
SPACEBAR    EQU         $20         ; Spacebar ASCII Keycode
ESCAPE      EQU         $1B         ; Escape ASCII Keycode

*-----------------------------------------------------------
* Subroutine    : Initialise
* Description   : Initialise game data into memory such as 
* sounds and screen size
*-----------------------------------------------------------
INITIALISE:
    ; Initialise Sounds
    BSR     RUN_LOAD                ; Load Run Sound into Memory
    BSR     JUMP_LOAD               ; Load Jump Sound into Memory
    BSR     OPPS_LOAD               ; Load Opps (Collision) Sound into Memory
    BSR     PICKUP_LOAD

    ; Screen Size
    MOVE.B  #TC_SCREEN, D0          ; access screen information
    MOVE.L  #TC_S_SIZE, D1          ; placing 0 in D1 triggers loading screen size information
    TRAP    #15                     ; interpret D0 and D1 for screen size
    MOVE.W  D1,         SCREEN_H    ; place screen height in memory location
    SWAP    D1                      ; Swap top and bottom word to retrive screen size
    MOVE.W  D1,         SCREEN_W    ; place screen width in memory location
    
    ;BAR SIZE
    MOVE.W  #BAR_X_INIT, BAR_X
    MOVE.W  #BAR_Y_INIT, BAR_Y
    MOVE.W  #BAR_X_2_INIT, BAR_X_2
    MOVE.W  #BAR_Y_2_INIT, BAR_Y_2
    
    ;GROUND SIZE
    MOVE.W  #GROUND_X_INIT, GROUND_X
    MOVE.W  #GROUND_Y_INIT, GROUND_Y
    MOVE.W  #GROUND_X_2_INIT, GROUND_X_2
    MOVE.W  #GROUND_Y_2_INIT, GROUND_Y_2
    
    ;SKY SIZE
    MOVE.W  #SKY_X_INIT, SKY_X
    MOVE.W  #SKY_Y_INIT, SKY_Y
    MOVE.W  #SKY_X_2_INIT, SKY_X_2
    MOVE.W  #SKY_Y_2_INIT, SKY_Y_2

    ; Place the Player at the center of the screen
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on X Axis
    MOVE.L  D1,         PLAYER_X    ; Players X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         PLAYER_Y    ; Players Y Position
    
    ; Initialise Player Health
    CLR.L   D1                      ;CLEAR D1
    MOVE.L  #PLYR_HEALT_INIT,   D1  ;INIT PLAYER HEALTH
    MOVE.L  D1,         PLAYER_HEALTH

    ; Initialise Player Score
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  #00,        D1          ; Init Score
    MOVE.L  D1,         PLAYER_SCORE
    
    ; Initialise Health Pickup
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  #HEALTH_PU_INIT,        D1          ; Init Score
    MOVE.L  D1,         HEALTH_PICKUP

    ; Initialise Player Velocity
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.B  #PLYR_DFLT_V,D1         ; Init Player Velocity
    MOVE.L  D1,         PLYR_VELOCITY

    ; Initialise Player Gravity
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  #PLYR_DFLT_G,D1         ; Init Player Gravity
    MOVE.L  D1,         PLYR_GRAVITY

    ; Initialize Player on Ground
    MOVE.L  #GND_TRUE,  PLYR_ON_GND ; Init Player on Ground

    ; Initial Position for Enemy
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_X     ; Enemy X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         ENEMY_Y     ; Enemy Y Position
    
    ; Initial Position for second Enemy
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_X_2     ; Enemy X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         ENEMY_Y_2     ; Enemy Y Position
    
    ; INITILISE ENEMGY DAMAGE
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  #DAMAGE_INIT,   D1          ; Init Score
    MOVE.L  D1,         DAMAGE
    
    ; INITILISE second ENEMGY DAMAGE
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  #DAMAGE_INIT_2,   D1          ; Init Score
    MOVE.L  D1,         DAMAGE_2
    
    ; Initial Position for Health pickup
    CLR.L   D1                          ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1              ; Place Screen width in D1
    MOVE.L  D1,         HEALTH_PU_X     ; Health pick up X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #03,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         HEALTH_PU_Y ; Health pick up Y Position
    
    ;INITILISE COLLISION FLAGS FOR ENIMIES AND PICKUPS
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  #FLAG_TRUE_INIT,   D1          ; Init Score
    MOVE.L  D1,         FLAG_TRUE
    
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  #FLAG_FALSE_INIT,   D1          ; Init Score
    MOVE.L  D1,         FLAG_FALSE
    
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  FLAG_FALSE,   D1          ; Init Score
    MOVE.L  D1,         ENEMY_FLAG_1
    
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  FLAG_FALSE,   D1          ; Init Score
    MOVE.L  D1,         ENEMY_FLAG_2
    
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  FLAG_FALSE,   D1          ; Init Score
    MOVE.L  D1,         HEALTH_FLAG_1

    ; Enable the screen back buffer(see easy 68k help)
	MOVE.B  #TC_DBL_BUF,D0          ; 92 Enables Double Buffer
    MOVE.B  #17,        D1          ; Combine Tasks
	TRAP	#15                     ; Trap (Perform action)

    ; Clear the screen (see easy 68k help)
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
	MOVE.W  #$FF00,     D1          ; Fill Screen Clear
	TRAP	#15                     ; Trap (Perform action)

*-----------------------------------------------------------
* Subroutine    : Game
* Description   : Game including main GameLoop. GameLoop is like
* a while loop in that it runs forever until interupted
* (Input, Update, Draw). The Enemies Run at Player Jump to Avoid
*-----------------------------------------------------------
GAME:
    BSR     PLAY_RUN                ; Play Run Wav
GAMELOOP:
    ; Main Gameloop
    BSR     GAME_DELAY
    BSR     INPUT                   ; Check Keyboard Input
    BSR     UPDATE                  ; Update positions and points
    BSR     IS_PLAYER_ON_GND        ; Check if player is on ground
    BSR     CHECK_COLLISIONS        ; Check for Collisions
    BSR     CHECK_COLLISIONS_2      ; Check for Collisions
    BSR     CHECK_COLLISIONS_PU     ; Check for Collisions
    BSR     DRAW                    ; Draw the Scene
    BRA     GAMELOOP                ; Loop back to GameLoop
    
*-----------------------------------------------------------
* Subroutine    : GAME_DELAY
* Description   : DELAYS GAME MAKING IT EASIER TO PLAY
*-----------------------------------------------------------
GAME_DELAY:
    MOVE.L #1, D1
    MOVE.L #23, D0
    TRAP #15
    RTS

*-----------------------------------------------------------
* Subroutine    : Input
* Description   : Process Keyboard Input
*-----------------------------------------------------------
INPUT:
    ; Process Input
    CLR.L   D1                      ; Clear Data Register
    MOVE.B  #TC_KEYCODE,D0          ; Listen for Keys
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  D1,         D2          ; Move last key D1 to D2
    CMP.B   #00,        D2          ; Key is pressed
    BEQ     PROCESS_INPUT           ; Process Key
    TRAP    #15                     ; Trap for Last Key
    ; Check if key still pressed
    CMP.B   #$FF,       D1          ; Is it still pressed
    BEQ     PROCESS_INPUT           ; Process Last Key
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Process Input
* Description   : Branch based on keys pressed
*-----------------------------------------------------------
PROCESS_INPUT:
    MOVE.L  D2,         CURRENT_KEY ; Put Current Key in Memory
    CMP.L   #ESCAPE,    CURRENT_KEY ; Is Current Key Escape
    BEQ     EXIT                    ; Exit if Escape
    CMP.L   #SPACEBAR,  CURRENT_KEY ; Is Current Key Spacebar
    BEQ     JUMP                    ; Jump
    BRA     IDLE                    ; Or Idle
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Update
* Description   : Main update loop update Player and Enemies
*-----------------------------------------------------------
UPDATE:
    ; Update the Players Positon based on Velocity and Gravity
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  PLYR_VELOCITY, D1       ; Fetch Player Velocity
    MOVE.L  PLYR_GRAVITY, D2        ; Fetch Player Gravity
    ADD.L   D2,         D1          ; Add Gravity to Velocity
    MOVE.L  D1,         PLYR_VELOCITY ; Update Player Velocity
    ADD.L   PLAYER_Y,   D1          ; Add Velocity to Player
    MOVE.L  D1,         PLAYER_Y    ; Update Players Y Position 

    ; Move the Enemy
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    CLR.L   D0                      ; Clear the contents of D0
    MOVE.L  ENEMY_X,    D1          ; Move the Enemy X Position to D0
    CMP.L   #00,        D1
    BLE     RESET_ENEMY_POSITION    ; Reset Enemy if off Screen
    BRA     MOVE_ENEMY              ; Move the Enemy
   
ENEMY_2_UPDATE:
    ; Move the second Enemy
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    CLR.L   D0                      ; Clear the contents of D0
    MOVE.L  ENEMY_X_2,    D1          ; Move the Enemy X Position to D0
    CMP.L   #00,        D1
    BLE     RESET_ENEMY_POSITION_2    ; Reset Enemy if off Screen
    BRA     MOVE_ENEMY_2              ; Move the Enemy
    
PICKUP_UPDATE:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    CLR.L   D0                      ; Clear the contents of D0
    MOVE.L  HEALTH_PU_X,    D1      ; Move the Enemy X Position to D0
    CMP.L   #00,        D1
    BLE     RESET_PICKUP_POSITION    ; Reset Enemy if off Screen
    BRA     MOVE_PICKUP              ; Move the Enemy

    RTS                             ; Return to subroutine  

*-----------------------------------------------------------
* Subroutine    : Move Enemy
* Description   : Move Enemy Right to Left
*-----------------------------------------------------------
MOVE_ENEMY:
    SUB.L   #05,        ENEMY_X     ; Move enemy by X Value
    BRA     ENEMY_2_UPDATE
    
*-----------------------------------------------------------
* Subroutine    : Move second Enemy
* Description   : Move Enemy Right to Left
*-----------------------------------------------------------
MOVE_ENEMY_2:
    SUB.L   #03,        ENEMY_X_2     ; Move enemy by X Value
    BRA     PICKUP_UPDATE
    
*-----------------------------------------------------------
* Subroutine    : Move Health pickup
* Description   : Move Health pickup Right to Left
*-----------------------------------------------------------
MOVE_PICKUP:
    SUB.L   #04,        HEALTH_PU_X     ; Move pickup by X Value
    RTS

*-----------------------------------------------------------
* Subroutine    : Reset Enemy
* Description   : Reset Enemy if to passes 0 to Right of Screen
*-----------------------------------------------------------
RESET_ENEMY_POSITION:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_X     ; Enemy X Position
    CLR.L   ENEMY_FLAG_1
    BRA     PICKUP_UPDATE
    
*-----------------------------------------------------------
* Subroutine    : Reset second Enemy
* Description   : Reset Enemy if to passes 0 to Right of Screen
*-----------------------------------------------------------
RESET_ENEMY_POSITION_2:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_X_2     ; Enemy X Position
    CLR.L   ENEMY_FLAG_2
    BRA     PICKUP_UPDATE
    
*-----------------------------------------------------------
* Subroutine    : Reset Pickup
* Description   : Reset Pickup if to passes 0 to Right of Screen
*-----------------------------------------------------------
RESET_PICKUP_POSITION:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         HEALTH_PU_X ; Pickup X Position
    CLR.L   HEALTH_FLAG_1
    RTS

*-----------------------------------------------------------
* Subroutine    : Draw
* Description   : Draw Screen
*-----------------------------------------------------------
DRAW: 
    ; Enable back buffer
    MOVE.B  #94,        D0
    TRAP    #15

    ; Clear the screen
    MOVE.B	#TC_CURSR_P,D0          ; Set Cursor Position
	MOVE.W	#$FF00,     D1          ; Clear contents
	TRAP    #15                     ; Trap (Perform action)

    BSR     DRAW_SKY
    BSR     DRAW_PLYR_DATA          ; Draw Draw Score, HUD, Player X and Y
    BSR     DRAW_PLAYER             ; Draw Player
    BSR     DRAW_ENEMY              ; Draw Enemy
    BSR     DRAW_ENEMY_2            ;DRAW SECOND ENEMY
    BSR     DRAW_PICKUP
    BSR     DRAW_GROUND
    BSR     DRAW_BAR
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Draw Player Data
* Description   : Draw Player X, Y, Velocity, Gravity and OnGround
*-----------------------------------------------------------
DRAW_PLYR_DATA:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    
    ; Player Helath msg
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$2004,     D1          ; Col 02, Row 01
    TRAP    #15
    LEA     HEALTH_MSG,  A1         ; Score Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)


    ; Player Helath VALUE
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$3004,     D1          ; Col 02, Row 01
    TRAP    #15
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLAYER_HEALTH,  D1
    TRAP    #15                     ; Trap (Perform action)
    
    
    ; Player Score Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0201,     D1          ; Col 02, Row 01
    TRAP    #15                     ; Trap (Perform action)
    LEA     SCORE_MSG,  A1          ; Score Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Player Score Value
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0901,     D1          ; Col 09, Row 01
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLAYER_SCORE,D1         ; Move Score to D1.L
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player X Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0202,     D1          ; Col 02, Row 02
    TRAP    #15                     ; Trap (Perform action)
    LEA     X_MSG,      A1          ; X Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player X
    MOVE.B  #TC_CURSR_P, D0          ; Set Cursor Position
    MOVE.W  #$0502,     D1          ; Col 05, Row 02
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLAYER_X,   D1          ; Move X to D1.L
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Y Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1002,     D1          ; Col 10, Row 02
    TRAP    #15                     ; Trap (Perform action)
    LEA     Y_MSG,      A1          ; Y Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Y
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1202,     D1          ; Col 12, Row 02
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLAYER_Y,   D1          ; Move X to D1.L
    TRAP    #15                     ; Trap (Perform action) 

    ; Player Velocity Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0203,     D1          ; Col 02, Row 03
    TRAP    #15                     ; Trap (Perform action)
    LEA     V_MSG,      A1          ; Velocity Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Velocity
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0503,     D1          ; Col 05, Row 03
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLYR_VELOCITY,D1        ; Move X to D1.L
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Gravity Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1003,     D1          ; Col 10, Row 03
    TRAP    #15                     ; Trap (Perform action)
    LEA     G_MSG,      A1          ; G Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Gravity
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1203,     D1          ; Col 12, Row 03
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLYR_GRAVITY,D1         ; Move Gravity to D1.L
    TRAP    #15                     ; Trap (Perform action)

    ; Player On Ground Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0204,     D1          ; Col 10, Row 03
    TRAP    #15                     ; Trap (Perform action)
    LEA     GND_MSG,    A1          ; On Ground Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player On Ground
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0604,     D1          ; Col 06, Row 04
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLYR_ON_GND,D1          ; Move Play on Ground ? to D1.L
    TRAP    #15                     ; Trap (Perform action)

    ; Show Keys Pressed
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$2001,     D1          ; Col 20, Row 1
    TRAP    #15                     ; Trap (Perform action)
    LEA     KEYCODE_MSG, A1         ; Keycode
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Show KeyCode
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$3001,     D1          ; Col 30, Row 1
    TRAP    #15                     ; Trap (Perform action)    
    MOVE.L  CURRENT_KEY,D1          ; Move Key Pressed to D1
    MOVE.B  #03,        D0          ; Display the contents of D1
    TRAP    #15                     ; Trap (Perform action)

    ; Show if Update is Running
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0205,     D1          ; Col 02, Row 05
    TRAP    #15                     ; Trap (Perform action)
    LEA     UPDATE_MSG, A1          ; Update
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Show if Draw is Running
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0206,     D1          ; Col 02, Row 06
    TRAP    #15                     ; Trap (Perform action)
    LEA     DRAW_MSG,   A1          ; Draw
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Show if Idle is Running
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0207,     D1          ; Col 02, Row 07
    TRAP    #15                     ; Trap (Perform action)
    LEA     IDLE_MSG,   A1          ; Move Idle Message to A1
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Colour RED
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0208,     D1          ; Col 02, Row 08
    TRAP    #15                     ; Trap (Perform action)
    LEA     COL_MSG_RED,    A1      ; On Ground Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Colour YELLOW
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0209,     D1          ; Col 02, Row 09
    TRAP    #15                     ; Trap (Perform action)
    LEA     COL_MSG_YELLOW,    A1          ; On Ground Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Colour BLUE
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$2008,     D1          ; Col 20, Row 08
    TRAP    #15                     ; Trap (Perform action)
    LEA     COL_MSG_BLUE,    A1          ; On Ground Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Colour WHITE
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$2009,     D1          ; Col 20, Row 09
    TRAP    #15                     ; Trap (Perform action)
    LEA     COL_MSG_WHITE,    A1          ; On Ground Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    RTS  
    
*-----------------------------------------------------------
* Subroutine    : Player is on Ground
* Description   : Check if the Player is on or off Ground
*-----------------------------------------------------------
IS_PLAYER_ON_GND:
    ; Check if Player is on Ground
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    CLR.L   D2                      ; Clear contents of D2 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  PLAYER_Y,   D2          ; Player Y Position
    CMP     D1,         D2          ; Compare middle of Screen with Players Y Position 
    BGE     SET_ON_GROUND           ; The Player is on the Ground Plane
    BLT     SET_OFF_GROUND          ; The Player is off the Ground
    RTS                             ; Return to subroutine


*-----------------------------------------------------------
* Subroutine    : On Ground
* Description   : Set the Player On Ground
*-----------------------------------------------------------
SET_ON_GROUND:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         PLAYER_Y    ; Reset the Player Y Position
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  #00,        D1          ; Player Velocity
    MOVE.L  D1,         PLYR_VELOCITY ; Set Player Velocity
    MOVE.L  #GND_TRUE,  PLYR_ON_GND ; Player is on Ground
    RTS

*-----------------------------------------------------------
* Subroutine    : Off Ground
* Description   : Set the Player Off Ground
*-----------------------------------------------------------
SET_OFF_GROUND:
    MOVE.L  #GND_FALSE, PLYR_ON_GND ; Player if off Ground
    RTS                             ; Return to subroutine
*-----------------------------------------------------------
* Subroutine    : Jump
* Description   : Perform a Jump
*-----------------------------------------------------------
JUMP:
    CMP.L   #GND_TRUE,PLYR_ON_GND   ; Player is on the Ground ?
    BEQ     PERFORM_JUMP            ; Do Jump
    BRA     JUMP_DONE               ;
PERFORM_JUMP:
    BSR     PLAY_JUMP               ; Play jump sound
    MOVE.L  #PLYR_JUMP_V,PLYR_VELOCITY ; Set the players velocity to true
    RTS                             ; Return to subroutine
JUMP_DONE:
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Idle
* Description   : Perform a Idle
*----------------------------------------------------------- 
IDLE:
    BSR     PLAY_RUN                ; Play Run Wav
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutines   : Sound Load and Play
* Description   : Initialise game sounds into memory 
* Current Sounds are RUN, JUMP and Opps for Collision
*-----------------------------------------------------------
RUN_LOAD:
    LEA     RUN_WAV,    A1          ; Load Wav File into A1
    MOVE    #RUN_INDEX, D1          ; Assign it INDEX
    MOVE    #71,        D0          ; Load into memory
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_RUN:
    MOVE    #RUN_INDEX, D1          ; Load Sound INDEX
    MOVE    #72,        D0          ; Play Sound
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

JUMP_LOAD:
    LEA     JUMP_WAV,   A1          ; Load Wav File into A1
    MOVE    #JMP_INDEX, D1          ; Assign it INDEX
    MOVE    #71,        D0          ; Load into memory
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_JUMP:
    MOVE.L  #3,     D2
    MOVE.L  #76,    D0
    TRAP    #15

    MOVE    #JMP_INDEX, D1          ; Load Sound INDEX
    MOVE    #72,        D0          ; Play Sound
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

OPPS_LOAD:
    LEA     OPPS_WAV,   A1          ; Load Wav File into A1
    MOVE    #OPPS_INDEX,D1          ; Assign it INDEX
    MOVE    #71,        D0          ; Load into memory
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_OPPS:
    MOVE.L  #3,     D2
    MOVE.L  #76,    D0
    TRAP    #15

    MOVE    #OPPS_INDEX,D1          ; Load Sound INDEX
    MOVE    #72,        D0          ; Play Sound
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine
    
PICKUP_LOAD:
    LEA     PICKUP_WAV,   A1          ; Load Wav File into A1
    MOVE    #PICKUP_INDEX,D1          ; Assign it INDEX
    MOVE    #71,        D0          ; Load into memory
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_PICKUP:
    MOVE.L  #3,     D2
    MOVE.L  #76,    D0
    TRAP    #15
    
    MOVE    #PICKUP_INDEX,D1        ; Load Sound INDEX
    MOVE    #72,        D0          ; Play Sound
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Draw Player
* Description   : Draw Player Square
*-----------------------------------------------------------
DRAW_PLAYER:
    ; Set Pixel Colors
    MOVE.L  #WHITE,     D1          ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #81,        D0
    TRAP    #15

    ; Set X, Y, Width and Height
    MOVE.L  PLAYER_X,   D1          ; X
    MOVE.L  PLAYER_Y,   D2          ; Y
    MOVE.L  PLAYER_X,   D3
    ADD.L   #PLYR_W_INIT,   D3      ; Width
    MOVE.L  PLAYER_Y,   D4 
    SUB.L   #PLYR_H_INIT,   D4      ; Height
    
    ; Draw Player
    MOVE.B  #87,        D0          ; Draw Player
    TRAP    #15                     ; Trap (Perform action)
    BSR     CLEAR_FILL
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Draw Enemy
* Description   : Draw Enemy Square
*-----------------------------------------------------------
DRAW_ENEMY:
    ; Set Pixel Colors
    MOVE.L  #YELLOW ,       D1          ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #81,        D0
    TRAP    #15

    ; Set X, Y, Width and Height
    MOVE.L  ENEMY_X,    D1          ; X
    MOVE.L  ENEMY_Y,    D2          ; Y
    MOVE.L  ENEMY_X,    D3
    ADD.L   #ENMY_W_INIT,   D3      ; Width
    MOVE.L  ENEMY_Y,    D4 
    SUB.L   #ENMY_H_INIT,   D4      ; Height
    
    ; Draw Enemy    
    MOVE.B  #87,        D0          ; Draw Enemy
    TRAP    #15                     ; Trap (Perform action)
    BSR     CLEAR_FILL
    RTS                             ; Return to subroutine
    
*-----------------------------------------------------------
* Subroutine    : Draw SECOND Enemy
* Description   : Draw Enemy Square
*-----------------------------------------------------------
DRAW_ENEMY_2:
    ; Set Pixel Colors
    MOVE.L  #RED,       D1          ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #81,        D0
    TRAP    #15

    ; Set X, Y, Width and Height
    MOVE.L  ENEMY_X_2,    D1          ; X
    MOVE.L  ENEMY_Y_2,    D2          ; Y
    MOVE.L  ENEMY_X_2,    D3
    ADD.L   #ENMY_W_INIT_2,   D3      ; Width
    MOVE.L  ENEMY_Y_2,    D4 
    SUB.L   #ENMY_H_INIT_2,   D4      ; Height
    
    ; Draw Enemy    
    MOVE.B  #87,        D0          ; Draw Enemy
    TRAP    #15                     ; Trap (Perform action)
    BSR     CLEAR_FILL
    RTS                             ; Return to subroutine
    
*-----------------------------------------------------------
* Subroutine    : Draw Pickup
* Description   : Draw Pickup Square
*-----------------------------------------------------------
DRAW_PICKUP:
    ; Set Pixel Colors
    MOVE.L  #BLUE,     D1        ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #81,        D0
    TRAP    #15

    ; Set X, Y, Width and Height
    MOVE.L  HEALTH_PU_X,    D1          ; X
    MOVE.L  HEALTH_PU_Y,    D2          ; Y
    MOVE.L  HEALTH_PU_X,    D3
    ADD.L   #HELTH_PU_W_INIT,   D3      ; Width
    MOVE.L  HEALTH_PU_Y,    D4 
    SUB.L   #HELTH_PU_H_INIT,   D4      ; Height
    
    ; Draw PICKUP    
    MOVE.B  #87,        D0          ; Draw PICKUP
    TRAP    #15                     ; Trap (Perform action)
    BSR     CLEAR_FILL
    RTS                             ; Return to subroutine
    
*-----------------------------------------------------------
* Subroutine    : Draw Ground
* Description   : Draw
*-----------------------------------------------------------
DRAW_GROUND:
    ; Set Pixel Colors
    MOVE.L  #SAND_YELLOW,     D1        ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #81,        D0
    TRAP    #15
    
    ; Set X, Y, Width and Height
    MOVE.W  GROUND_X,    D1          ; X
    MOVE.W  GROUND_Y,    D2          ; Y
    MOVE.W  GROUND_X_2,  D3
    MOVE.W  GROUND_Y_2,  D4
    
    ; Draw BAR    
    MOVE.B  #87,        D0          ; Draw BAR
    TRAP    #15                     ; Trap (Perform action)
    BSR     CLEAR_FILL
    RTS                             ; Return to subroutine
    
*-----------------------------------------------------------
* Subroutine    : Draw SKY
* Description   : Draw
*-----------------------------------------------------------
DRAW_SKY:
    ; Set Pixel Colors
    MOVE.L  #SKY_BLUE,     D1        ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #81,        D0
    TRAP    #15
    
    ; Set X, Y, Width and Height
    MOVE.W  SKY_X,    D1          ; X
    MOVE.W  SKY_Y,    D2          ; Y
    MOVE.W  SKY_X_2,  D3
    MOVE.W  SKY_Y_2,  D4
    
    ; Draw SKY    
    MOVE.B  #87,        D0          ; Draw BAR
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine
    
    
*-----------------------------------------------------------
* Subroutine    : Draw Health Bar
* Description   : Draw Player Health as a bar
*-----------------------------------------------------------
DRAW_BAR:
    ; Set Pixel Colors
    MOVE.L  #GREEN,     D1          ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #81,        D0
    TRAP    #15
    
    ; Set X, Y, Width and Height
    MOVE.W  BAR_X,    D1          ; X
    MOVE.W  BAR_Y,    D2          ; Y
    MOVE.W  BAR_X_2,  D3
    MOVE.W  BAR_Y_2,  D4
    
    ; Draw BAR    
    MOVE.B  #87,        D0          ; Draw BAR
    TRAP    #15                     ; Trap (Perform action)
    BSR     CLEAR_FILL
    RTS                             ; Return to subroutine
    
*-----------------------------------------------------------
* Subroutine    : CLEAR_FILL
* Description   : CLEARS FILL COLOUR
*-----------------------------------------------------------
CLEAR_FILL:
    MOVE.L  #BLACK,     D1          ; Set Fill Color
    MOVE.B  #81,        D0          ; Task for Fill Color
    TRAP    #15                     ; Trap (Perform Action)
    RTS

*-----------------------------------------------------------
* Subroutine    : Collision Check
* Description   : Axis-Aligned Bounding Box Collision Detection
* Algorithm checks for overlap on the 4 sides of the Player and 
* Enemy rectangles
* PLAYER_X <= ENEMY_X + ENEMY_W &&
* PLAYER_X + PLAYER_W >= ENEMY_X &&
* PLAYER_Y <= ENEMY_Y + ENEMY_H &&
* PLAYER_H + PLAYER_Y >= ENEMY_Y
*-----------------------------------------------------------
CHECK_COLLISIONS:
    CLR.L   D1                      ; Clear D1
    CLR.L   D2                      ; Clear D2
    TST.L   ENEMY_FLAG_1
    BNE     COLLISION_CHECK_DONE
    
PLAYER_X_LTE_TO_ENEMY_X_PLUS_W:
    MOVE.L  PLAYER_X,   D1          ; Move Player X to D1
    MOVE.L  ENEMY_X,    D2          ; Move Enemy X to D2
    ADD.L   #ENMY_W_INIT,D2          ; Set Enemy width X + Width
    CMP.L   D2,         D1          ; Do the Overlap ?
    BLE     PLAYER_X_PLUS_W_LTE_TO_ENEMY_X  ; Less than or Equal ?
    BRA     COLLISION_CHECK_DONE    ; If not no collision
PLAYER_X_PLUS_W_LTE_TO_ENEMY_X:     ; Check player is not  
    ADD.L   #PLYR_W_INIT,D1          ; Move Player Width to D1
    MOVE.L  ENEMY_X,    D2          ; Move Enemy X to D2
    CMP.L   D1,         D2          ; Do they OverLap ?
    BLE     PLAYER_Y_LTE_TO_ENEMY_Y_PLUS_H  ; Less than or Equal
    BRA     COLLISION_CHECK_DONE    ; If not no collision   
PLAYER_Y_LTE_TO_ENEMY_Y_PLUS_H:     
    MOVE.L  PLAYER_Y,   D1          ; Move Player Y to D1
    MOVE.L  ENEMY_Y,    D2          ; Move Enemy Y to D2
    SUB.L   #ENMY_H_INIT,D2          ; Set Enemy Height to D2
    CMP.L   D1,         D2          ; Do they Overlap ?
    BLE     PLAYER_Y_PLUS_H_LTE_TO_ENEMY_Y  ; Less than or Equal
    BRA     COLLISION_CHECK_DONE    ; If not no collision 
PLAYER_Y_PLUS_H_LTE_TO_ENEMY_Y:     ; Less than or Equal ?
    SUB.L   #PLYR_H_INIT,D1          ; Add Player Height to D1
    MOVE.L  ENEMY_Y,    D2          ; Move Enemy Height to D2  
    CMP.L   D1,         D2          ; Do they OverLap ?
    BGE     COLLISION               ; Collision !
    BRA     COLLISION_CHECK_DONE    ; If not no collision
COLLISION_CHECK_DONE:               ; No Collision Update points
    MOVE.L   #POINTS,    D1          ; Move points upgrade to D1
    ADD.L   PLAYER_SCORE,D1         ; Add to current player score
    MOVE.L  D1, PLAYER_SCORE        ; Update player score in memory
    RTS                             ; Return to subroutine

COLLISION:
    MOVE.L  FLAG_TRUE,     D1
    MOVE.L  D1,     ENEMY_FLAG_1
    BSR     PLAY_OPPS               ; Play Opps Wav
    MOVE.L  #00, PLAYER_SCORE       ; Reset Player Score
    LEA DAMAGE, A1
    MOVE.L (A1), D1
    SUB.L D1, PLAYER_HEALTH
    SUB.W D1, BAR_X_2
    TST.L   PLAYER_HEALTH
    BLT     EXIT
    RTS                             ; Return to subroutine
    
*-----------------------------------------------------------
* Subroutine    : Collision Check
* Description   : Axis-Aligned Bounding Box Collision Detection
* Algorithm checks for overlap on the 4 sides of the Player and 
* Enemy rectangles
* PLAYER_X <= ENEMY_X + ENEMY_W &&
* PLAYER_X + PLAYER_W >= ENEMY_X &&
* PLAYER_Y <= ENEMY_Y + ENEMY_H &&
* PLAYER_H + PLAYER_Y >= ENEMY_Y
*-----------------------------------------------------------
CHECK_COLLISIONS_2:
    CLR.L   D1                      ; Clear D1
    CLR.L   D2                      ; Clear D2
    TST.L   ENEMY_FLAG_2
    BNE     COLLISION_CHECK_DONE
    
PLAYER_X_LTE_TO_ENEMY_X_PLUS_W_2:
    MOVE.L  PLAYER_X,   D1          ; Move Player X to D1
    MOVE.L  ENEMY_X_2,    D2          ; Move Enemy X to D2
    ADD.L   #ENMY_W_INIT_2,D2          ; Set Enemy width X + Width
    CMP.L   D2,         D1          ; Do the Overlap ?
    BLE     PLAYER_X_PLUS_W_LTE_TO_ENEMY_X_2  ; Less than or Equal ?
    BRA     COLLISION_CHECK_DONE_2    ; If not no collision
PLAYER_X_PLUS_W_LTE_TO_ENEMY_X_2:     ; Check player is not  
    ADD.L   #PLYR_W_INIT,D1          ; Move Player Width to D1
    MOVE.L  ENEMY_X_2,    D2          ; Move Enemy X to D2
    CMP.L   D1,         D2          ; Do they OverLap ?
    BLE     PLAYER_Y_LTE_TO_ENEMY_Y_PLUS_H_2  ; Less than or Equal
    BRA     COLLISION_CHECK_DONE_2    ; If not no collision   
PLAYER_Y_LTE_TO_ENEMY_Y_PLUS_H_2:     
    MOVE.L  PLAYER_Y,   D1          ; Move Player Y to D1
    MOVE.L  ENEMY_Y_2,    D2          ; Move Enemy Y to D2
    SUB.L   #ENMY_H_INIT_2,D2          ; Set Enemy Height to D2
    CMP.L   D1,         D2          ; Do they Overlap ?
    BLE     PLAYER_Y_PLUS_H_LTE_TO_ENEMY_Y_2  ; Less than or Equal
    BRA     COLLISION_CHECK_DONE_2    ; If not no collision 
PLAYER_Y_PLUS_H_LTE_TO_ENEMY_Y_2:     ; Less than or Equal ?
    SUB.L   #PLYR_H_INIT,D1          ; Add Player Height to D1
    MOVE.L  ENEMY_Y_2,    D2          ; Move Enemy Height to D2  
    CMP.L   D1,         D2          ; Do they OverLap ?
    BGE     COLLISION_2               ; Collision !
    BRA     COLLISION_CHECK_DONE_2    ; If not no collision
COLLISION_CHECK_DONE_2:               ; No Collision Update points
    RTS                             ; Return to subroutine

COLLISION_2:
    MOVE.L  FLAG_TRUE,     D1
    MOVE.L  D1,     ENEMY_FLAG_2
    BSR     PLAY_OPPS               ; Play Opps Wav
    MOVE.L  #00, PLAYER_SCORE       ; Reset Player Score
    LEA DAMAGE_2, A1
    MOVE.L (A1), D1
    SUB.L D1, PLAYER_HEALTH
    SUB.W D1, BAR_X_2
    TST.L   PLAYER_HEALTH
    BLT     EXIT
    RTS                             ; Return to subroutine
    
*-----------------------------------------------------------
* Subroutine    : Pick up Collision Check
* Description   : Axis-Aligned Bounding Box Collision Detection
* Algorithm checks for overlap on the 4 sides of the Player and 
* Enemy rectangles
* PLAYER_X <= HEALTH_PU_X + HELTH_PU_W_INIT &&
* PLAYER_X + PLAYER_W >= HEALTH_PU_X &&
* PLAYER_Y <= HEALTH_PU_Y + HELTH_PU_H_INIT &&
* PLAYER_H + PLAYER_Y >= HEALTH_PU_Y
*-----------------------------------------------------------
CHECK_COLLISIONS_PU:
    CLR.L   D1                                      ; Clear D1
    CLR.L   D2                                      ; Clear D2
    TST.L   HEALTH_FLAG_1
    BNE     COLLISION_CHECK_DONE
    
PLAYER_X_LTE_TO_H_PU_X_PLUS_W:
    MOVE.L  PLAYER_X,           D1                      ; Move Player X to D1
    MOVE.L  HEALTH_PU_X,        D2                  ; Move Enemy X to D2
    ADD.L   #HELTH_PU_W_INIT,    D2                 ; Set Enemy width X + Width
    CMP.L   D2,                 D1                      ; Do the Overlap ?
    BLE     PLAYER_X_PLUS_W_LTE_TO_H_PU_X       ; Less than or Equal ?
    BRA     COLLISION_CHECK_DONE_PU             ; If not no collision
PLAYER_X_PLUS_W_LTE_TO_H_PU_X:                  ; Check player is not  
    ADD.L   #PLYR_W_INIT,        D1                      ; Move Player Width to D1
    MOVE.L  HEALTH_PU_X,        D2                  ; Move Enemy X to D2
    CMP.L   D1,                 D2                      ; Do they OverLap ?
    BLE     PLAYER_Y_LTE_TO_H_PU_Y_PLUS_H       ; Less than or Equal
    BRA     COLLISION_CHECK_DONE_PU             ; If not no collision   
PLAYER_Y_LTE_TO_H_PU_Y_PLUS_H:     
    MOVE.L  PLAYER_Y,           D1                      ; Move Player Y to D1
    MOVE.L  HEALTH_PU_Y,        D2                  ; Move Enemy Y to D2
    SUB.L   #HELTH_PU_H_INIT     ,D2                  ; Set Enemy Height to D2
    CMP.L   D1,                 D2                      ; Do they Overlap ?
    BLE     PLAYER_Y_PLUS_H_LTE_TO_H_PU_Y       ; Less than or Equal
    BRA     COLLISION_CHECK_DONE_PU             ; If not no collision 
PLAYER_Y_PLUS_H_LTE_TO_H_PU_Y:                  ; Less than or Equal ?
    SUB.L   #PLYR_H_INIT,        D1                      ; Add Player Height to D1
    MOVE.L  HEALTH_PU_Y,        D2                  ; Move Enemy Height to D2  
    CMP.L   D1,                 D2                      ; Do they OverLap ?
    BGE     COLLISION_PU                        ; Collision !
    BRA     COLLISION_CHECK_DONE_PU             ; If not no collision
COLLISION_CHECK_DONE_PU:                        ; No Collision Update points
    RTS                                         ; Return to subroutine

COLLISION_PU:
    MOVE.L  FLAG_TRUE,     D1
    MOVE.L  D1,     HEALTH_FLAG_1
    BSR     PLAY_PICKUP                           ; Play Opps Wav
    LEA HEALTH_PICKUP, A1
    MOVE.L (A1), D1
    ADD.L D1, PLAYER_HEALTH
    ADD.W D1, BAR_X_2
    RTS                                         ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : EXIT
* Description   : Exit message and End Game
*-----------------------------------------------------------
EXIT:
    ; Show if Exiting is Running
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$4004,     D1          ; Col 40, Row 1
    TRAP    #15                     ; Trap (Perform action)
    LEA     EXIT_MSG,   A1          ; Exit
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #TC_EXIT,   D0          ; Exit Code
    TRAP    #15                     ; Trap (Perform action)
    SIMHALT

*-----------------------------------------------------------
* Section       : Messages
* Description   : Messages to Print on Console, names should be
* self documenting
*-----------------------------------------------------------
SCORE_MSG       DC.B    'Score : ', 0       ; Score Message
KEYCODE_MSG     DC.B    'KeyCode : ', 0     ; Keycode Message
JUMP_MSG        DC.B    'Jump....', 0       ; Jump Message

IDLE_MSG        DC.B    'Idle....', 0       ; Idle Message
UPDATE_MSG      DC.B    'Update....', 0     ; Update Message
DRAW_MSG        DC.B    'Draw....', 0       ; Draw Message

X_MSG           DC.B    'X:', 0             ; X Position Message
Y_MSG           DC.B    'Y:', 0             ; Y Position Message
V_MSG           DC.B    'V:', 0             ; Velocity Position Message
G_MSG           DC.B    'G:', 0             ; Gravity Position Message
GND_MSG         DC.B    'GND:', 0           ; On Ground Position Message

HEALTH_MSG      DC.B    'Player Health...:', 0  ;Player health message

EXIT_MSG        DC.B    'Exiting....', 0    ; Exit Message

COL_MSG_RED          DC.B    'RED = 100 DAMAGE',  0
COL_MSG_YELLOW       DC.B    'YELLOW = 20 DAMAGE',  0
COL_MSG_BLUE         DC.B    'BLUE = HEALTH PICKUP',  0
COL_MSG_WHITE        DC.B    'WHITE = YOU',  0

*-----------------------------------------------------------
* Section       : Graphic Colors
* Description   : Screen Pixel Color
*-----------------------------------------------------------
WHITE           EQU     $00FFFFFF
RED             EQU     $000000FF
GREEN           EQU     $0000FF00
BLACK           EQU     $00000000
BLUE            EQU     $00FF0000
YELLOW          EQU     $0000FFFF
SAND_YELLOW     EQU     $00ADDEFF
SKY_BLUE        EQU     $00FFD4B5

*-----------------------------------------------------------
* Section       : Screen Size
* Description   : Screen Width and Height
*-----------------------------------------------------------
SCREEN_W        DS.W    01  ; Reserve Space for Screen Width
SCREEN_H        DS.W    01  ; Reserve Space for Screen Height

*-----------------------------------------------------------
* Section       : Keyboard Input
* Description   : Used for storing Keypresses
*-----------------------------------------------------------
CURRENT_KEY     DS.L    01  ; Reserve Space for Current Key Pressed

*-----------------------------------------------------------
* Section       : Character Positions
* Description   : Player and Enemy Position Memory Locations
*-----------------------------------------------------------
PLAYER_X        DS.L    01  ; Reserve Space for Player X Position
PLAYER_Y        DS.L    01  ; Reserve Space for Player Y Position
PLAYER_SCORE    DS.L    01  ; Reserve Space for Player Score

PLYR_VELOCITY   DS.L    01  ; Reserve Space for Player Velocity
PLYR_GRAVITY    DS.L    01  ; Reserve Space for Player Gravity
PLYR_ON_GND     DS.L    01  ; Reserve Space for Player on Ground

ENEMY_X         DS.L    01  ; Reserve Space for Enemy X Position
ENEMY_Y         DS.L    01  ; Reserve Space for Enemy Y Position

ENEMY_X_2         DS.L    01  ; Reserve Space for Enemy X Position
ENEMY_Y_2         DS.L    01  ; Reserve Space for Enemy Y Position

*-----------------------------------------------------------
* Section       : Enemy Damage
* Description   : Reserved Space of damage
*-----------------------------------------------------------
DAMAGE          DS.L    01
DAMAGE_2        DS.L    01

*-----------------------------------------------------------
* Section       : Player Health
* Description   : Reserved Space of player health
*-----------------------------------------------------------
PLAYER_HEALTH   DS.L    01  ;RESERVER SPACE FOR PLAYER HEALTH
BAR_X    DS.L    01
BAR_Y    DS.L    01
BAR_X_2  DS.L    01
BAR_Y_2  DS.L    01

*-----------------------------------------------------------
* Section       : Ground
* Description   : Reserved Space of player health
*-----------------------------------------------------------
GROUND_X    DS.L    01
GROUND_Y    DS.L    01
GROUND_X_2  DS.L    01
GROUND_Y_2  DS.L    01

*-----------------------------------------------------------
* Section       : SKY
* Description   : Reserved Space of player health
*-----------------------------------------------------------
SKY_X    DS.L    01
SKY_Y    DS.L    01
SKY_X_2  DS.L    01
SKY_Y_2  DS.L    01

*-----------------------------------------------------------
* Section       : Health PICKUP
* Description   : Reserved Space of health PICKUP
*-----------------------------------------------------------
HEALTH_PICKUP DS.L    01
HEALTH_PU_X   DS.L    01
HEALTH_PU_Y   DS.L    01

*-----------------------------------------------------------
* Section       : FLAG COLLISION CHECK
* Description   : Reserved Space of health PICKUP
*-----------------------------------------------------------
FLAG_TRUE   DS.L    01
FLAG_FALSE  DS.L    01
ENEMY_FLAG_1    DS.L    01
ENEMY_FLAG_2    DS.L    01
HEALTH_FLAG_1   DS.L    01


*-----------------------------------------------------------
* Section       : Sounds
* Description   : Sound files, which are then loaded and given
* an address in memory, they take a longtime to process and play
* so keep the files small. Used https://voicemaker.in/ to 
* generate and Audacity to convert MP3 to WAV
*-----------------------------------------------------------
JUMP_WAV        DC.B    'jump.wav',0        ; Jump Sound
RUN_WAV         DC.B    'run.wav',0         ; Run Sound
OPPS_WAV        DC.B    'opps.wav',0        ; Collision Opps
PICKUP_WAV      DC.B    'pickup.wav',0      ;Pickup Sound

    END    START        ; last line of source














*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
