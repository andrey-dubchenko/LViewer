program LViewer;

{$R *.RES}
{$R 'Icons.res' 'Icons.rc'}
{$R 'Menu.res' 'Menu.rc'}

uses
 Windows,
 Messages,
 ShellApi;

//==============================================================================
const
 WM_SHOW_MENU       = WM_USER + 1;
 NUM_ICON           = 1;
 CAPS_ICON          = 2;
 SCROLL_ICON        = 3;
//==============================================================================
var
 hWindow            :HWND;
 hInst              :HWND;
 hNumIconOn         :HICON;
 hNumIconOff        :HICON;
 hCapsIconOn        :HICON;
 hCapsIconOff       :HICON;
 hScrollIconOn      :HICON;
 hScrollIconOff     :HICON;
 Menu               :HMENU;
 TrackMenu          :HMENU;
 hTimer             :THandle;
 Msg                :TMsg;
 wc                 :TWndClass;
//==============================================================================
//
//==============================================================================
procedure AddToTray(n:integer; Icon:HICON; ID:UINT);
var
 Nim                :TNotifyIconData;
begin
 with Nim do
  begin
   cbSize := sizeof(Nim);
   Wnd := hWindow;
   hIcon := Icon;
   uID := ID;
   uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
   uCallbackMessage := WM_SHOW_MENU;
   szTip := 'Монитор lock клавиш';
  end;
 case n of
  1:Shell_NotifyIcon(Nim_Add, @Nim);
  2:Shell_NotifyIcon(Nim_Delete, @Nim);
  3:Shell_NotifyIcon(Nim_Modify, @Nim);
 end;
end;
//==============================================================================
//
//==============================================================================
procedure ExitProc;
begin
 FreeResource(hNumIconOn);
 FreeResource(hNumIconOff);
 FreeResource(hCapsIconOn);
 FreeResource(hCapsIconOff);
 FreeResource(hScrollIconOn);
 FreeResource(hScrollIconOff);
 KillTimer(hWindow, hTimer);
 DestroyMenu(TrackMenu);
 DestroyMenu(Menu);
 UnRegisterClass('LViewer Class', hInst);
 AddToTray(2, 0, NUM_ICON);
 AddToTray(2, 0, CAPS_ICON);
 AddToTray(2, 0, SCROLL_ICON);
 ExitProcess(hInst);
end;
//==============================================================================
//
//==============================================================================
procedure IconMenu;
var
 p                  :TPoint;
begin
 if GetAsyncKeyState(VK_RBUTTON) < 0 then
  begin
   GetCursorPos(p);
   SetForegroundWindow(hWindow);
   TrackPopupMenuEx(TrackMenu, TPM_LEFTBUTTON or TPM_RIGHTALIGN, p.x, p.y, hWindow, nil);
   PostMessage(hWindow, WM_NULL, 0, 0);
  end;
end;
//==============================================================================
//
//==============================================================================
procedure TimerProc;
begin
 if GetKeyState(VK_CAPITAL) = 1 then
  AddToTray(3, hCapsIconOn, CAPS_ICON)
 else
  AddToTray(3, hCapsIconOff, CAPS_ICON);
 if GetKeyState(VK_NUMLOCK) = 1 then
  AddToTray(3, hNumIconOn, NUM_ICON)
 else
  AddToTray(3, hNumIconOff, NUM_ICON);
 if GetKeyState(VK_SCROLL) = 1 then
  AddToTray(3, hScrollIconOn, SCROLL_ICON)
 else
  AddToTray(3, hScrollIconOff, SCROLL_ICON);
end;
//==============================================================================
//
//==============================================================================
function SetAutorun(Flag:byte):boolean;
var
 Key                :HKEY;
 FilePath           :array[0..MAX_PATH] of char;
 Param              :string;
begin
 result := false;
 ZeroMemory(@FilePath, sizeof(FilePath));
 ZeroMemory(@Param, sizeof(Param));
 GetModuleFileName(hInst, FilePath, sizeof(FilePath));
 if (RegOpenKeyEx(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Run', 0, KEY_SET_VALUE or KEY_QUERY_VALUE, Key) = ERROR_SUCCESS) then
  begin
   case Flag of
    1:
     begin
      Param := FilePath;
      RegSetValueEx(Key, 'LViewer', 0, REG_SZ, PChar(Param), length(Param) + 1);
      SetAutoRun(3);
      result := true;
     end;
    2:
     begin
      RegDeleteValue(Key, 'LViewer');
      SetAutoRun(3);
      result := true;
     end;
    3:
     begin
      if (RegQueryValueEx(Key, 'LViewer', nil, nil, nil, nil) = ERROR_SUCCESS) then
       begin
        CheckMenuItem(TrackMenu, 111, MF_CHECKED);
        result := true;
       end
      else
       begin
        CheckMenuItem(TrackMenu, 111, MF_UNCHECKED);
        result := false;
       end;
     end;
   end;
  end;
 if Key <> 0 then
  RegCloseKey(Key);
end;
//==============================================================================
//
//==============================================================================
function WindowProc(hWnd, Msg, wParam, lParam:longint):longint; stdcall;
begin
 case Msg of
  WM_CLOSE:ExitProc;
  WM_SHOW_MENU:IconMenu;
  WM_COMMAND:
   begin
    case LOWORD(wParam) of
     110:ExitProc;
     111:if not SetAutoRun(3) then
       SetAutoRun(1)
      else
       SetAutoRun(2);
    end;
   end;
 end;
 result := DefWindowProc(hWnd, Msg, wParam, lParam);
end;
//==============================================================================
//
//==============================================================================
begin
 hInst := GetModuleHandle(nil);
 
 with wc do
  begin
   Style := CS_PARENTDC;
   lpfnWndProc := @WindowProc;
   hInstance := hInst;
   lpszClassName := 'LVIewer Class';
  end;
 
 RegisterClass(wc);
 hWindow := CreateWindow('LViewer Class', 'LViewer', WS_OVERLAPPED, 0, 0, 20, 20, 0, 0, hInst, nil);
 Menu := LoadMenu(hInst, 'FIRSTMENU');
 TrackMenu := GetSubMenu(Menu, 0);
 SetAutoRun(3);
 hTimer := SetTimer(hWindow, 0, 1000, @TimerProc);
 
 hNumIconOn := LoadImage(hInst, MAKEINTRESOURCE(104), IMAGE_ICON, 32, 32, LR_DEFAULTCOLOR);
 hNumIconOff := LoadImage(hInst, MAKEINTRESOURCE(105), IMAGE_ICON, 32, 32, LR_DEFAULTCOLOR);
 hCapsIconOn := LoadImage(hInst, MAKEINTRESOURCE(102), IMAGE_ICON, 32, 32, LR_DEFAULTCOLOR);
 hCapsIconOff := LoadImage(hInst, MAKEINTRESOURCE(103), IMAGE_ICON, 32, 32, LR_DEFAULTCOLOR);
 hScrollIconOn := LoadImage(hInst, MAKEINTRESOURCE(106), IMAGE_ICON, 32, 32, LR_DEFAULTCOLOR);
 hScrollIconOff := LoadImage(hInst, MAKEINTRESOURCE(107), IMAGE_ICON, 32, 32, LR_DEFAULTCOLOR);
 
 AddToTray(1, hScrollIconOff, SCROLL_ICON);
 AddToTray(1, hCapsIconOff, CAPS_ICON);
 AddToTray(1, hNumIconOff, NUM_ICON);
 
 while (GetMessage(Msg, hWindow, 0, 0)) do
  begin
   TranslateMessage(Msg);
   DispatchMessage(Msg);
  end;
 ExitProc;
//==============================================================================
end.

