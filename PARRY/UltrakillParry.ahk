#Requires AutoHotkey v2.0
  #SingleInstance Force

  ; ==============================================================================
  ; INITIALIZATION
  ; ==============================================================================

  ; Path to the folder containing your sounds
  SoundFolder := "C:\Users\Windows11\Desktop\PARRY"
  ; Path to the VLC executable
  vlcPath := "C:\Program Files\VideoLAN\VLC\vlc.exe"

  ; Pre-load sound files once at startup to avoid lag during the parry
  SoundFiles := []
  Loop Files, SoundFolder "\*.*" {
      if (A_LoopFileExt = "wav" or A_LoopFileExt = "mp3" or A_LoopFileExt = "ogg") {
          SoundFiles.Push(A_LoopFileFullPath)
      }
  }

  ; Create the Haze GUI
  ; +AlwaysOnTop: Keeps it above the game
  ; -Caption: Removes the title bar and borders
  ; +ToolWindow: Hides it from the taskbar
  ; +E0x20: Makes it "Click-Through" (Prevents the security system from thinking it's blocking input)
  ; +E0x80: Makes it a "Layered Window" (The magic fix—makes Windows treat it as an overlay, not a window)
  ; +Disabled: Makes it non-interactive (Prevents focus-stealing dings)
  Global MyGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20 +E0x80 +Disabled")
  MyGui.BackColor := "FFFFFF"

  ; STEALTH START:
  ; Start as a tiny invisible dot so Windows doesn't flag the full-screen jump later.
  MyGui.Show("x0 y0 w1 h1 NoActivate")
  WinSetTransparent 0, MyGui

  ; ==============================================================================
  ; HOTKEY TRIGGER
  ; ==============================================================================

  ~g:: {
      ; Check if setup is correct
      if (SoundFiles.Length = 0 or !FileExist(vlcPath)) {
          ToolTip "Setup missing (Sounds or VLC)!"
          SetTimer () => ToolTip(), -3000
          return
      }

      ; --- STEP 1: THE IMPACT (SOUND) ---
      try {
          Run('"' vlcPath '" --intf dummy --play-and-exit "' SoundFiles[1] '"', , "Hide")
      }

      ; --- STEP 2: THE WHITE-OUT HAZE ---
      ; Set transparency BEFORE showing full-screen to avoid a "flash" that triggers security.
      WinSetTransparent 120, MyGui
      MyGui.Show("x0 y0 w" . A_ScreenWidth . " h" . A_ScreenHeight " NoActivate")

      ; --- STEP 3: THE DURATION ---
      Sleep 800

      ; Hide the GUI and reset transparency for the next use
      MyGui.Hide()
      WinSetTransparent 0, MyGui

      ; --- STEP 4: THE AFTER-SOUND ---
      if (SoundFiles.Length >= 2) {
          try {
              Run('"' vlcPath '" --intf dummy --play-and-exit "' SoundFiles[2] '"', , "Hide")
          }
      }
  }