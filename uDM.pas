unit uDM;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Phys.MSSQL,  FireDAC.Phys.MSSQLDef,
  FireDAC.Comp.ScriptCommands, FireDAC.Stan.Util, FireDAC.Comp.Script;

type
  TDM = class(TDataModule)
    Connect: TFDConnection;
    Script: TFDScript;
    procedure DataModuleCreate(Sender: TObject);
  strict private
    FServerExists    : boolean;
    FHost            : string;
    FOSAuthorization : boolean;
    FLogin           : string;
    FPassword        : string;
  public
    function LoadParams : boolean;
    function SetParams : boolean;
    procedure SaveParams;
    function CheckConnection : boolean;
    function CheckDataBase : boolean;
    procedure ExecuteScript(FN : TFileName);
    property ServerExists : boolean read FServerExists;
    property Host : string read FHost;
  end;

var
  DM: TDM;

//const
//  RegKey  = 'SOFTWARE\LSI\Test';

implementation

uses VCL.Dialogs, UITypes, IniFiles, Windows, ZLib, VCL.Forms;

{$R *.dfm}

function TDM.CheckConnection: boolean;
begin
  Screen.Cursor:=crSQLWait;
  try
    Result:=false;
    FServerExists:=false;
    Connect.LoginPrompt:=false;
    Connect.Params.Clear;
    Connect.Params.Add('DriverID=MSSQL');
    Connect.Params.Add('Server='+FHost);
    Connect.Params.Add('User_Name='+FLogin);
    Connect.Params.Add('Password='+FPassword);
    Connect.Params.Add('LoginTimeOut=100');
    if FOSAuthorization then
      Connect.Params.Add('OSAuthent=Yes')
    else
      Connect.Params.Add('OSAuthent=No');
    try
      Connect.Connected:=true;
      Connect.Connected:=false;
      FServerExists:=true;
      Result:=true
    except
      on E:Exception do
        MessageDlg('Open connect: '+E.Message, mtError, [mbOK], 0, mbOK)
    end
  finally
    Screen.Cursor:=crDefault
  end
end;

function TDM.CheckDataBase: boolean;
var
  L : TStringList;
  b : boolean;
begin
  Result:=false;
  Screen.Cursor:=crSQLWait;
  L:=TStringList.Create;
  try
    try
      Connect.Connected:=true;
      try
        Connect.GetCatalogNames('',L);
        b:=L.IndexOf('TestLSI')>-1;
        if b then begin
          Connect.Connected:=false;
          Connect.Params.DataBase:='TestLSI';
          Connect.Connected:=true;
          Result:=true
        end
      finally
        Connect.Connected:=false
      end;
    except
      on E:Exception do begin
        FServerExists:=false;
        MessageDlg('Check DB: '+E.Message, mtError, [mbOK], 0, mbOK)
      end
    end;
  finally
    L.Free;
    Screen.Cursor:=crDefault
  end
end;

procedure TDM.DataModuleCreate(Sender: TObject);
var
  b    : boolean;
begin
  FServerExists:=false;
  FHost:='127.0.0.1';
  FOsAuthorization:=true;
  FLogin:='';
  FPassword:='';
  Connect.DriverName:='MSSQL';
  Connect.FetchOptions.Mode:=fmAll;
  Connect.FetchOptions.RecordCountMode:=cmTotal;
  Connect.FetchOptions.LiveWindowFastFirst:=True;
  Connect.FormatOptions.ADOCompatibility:=True;
  Connect.Params.DataBase:='TestLSI';
  Connect.Params.DriverID:='MSSQL';
  Connect.UpdateOptions.CheckReadOnly:=false;
  Connect.UpdateOptions.CheckRequired:=false;
  Connect.UpdateOptions.CheckUpdatable:=false;
  Connect.UpdateOptions.EnableDelete:=true;
  Connect.UpdateOptions.EnableInsert:=false;
  Connect.UpdateOptions.EnableUpdate:=false;
  Connect.UpdateOptions.LockWait:=true;
  Connect.UpdateOptions.RefreshMode:=rmManual;
  b:=LoadParams;
  if b then begin
    b:=CheckConnection;
    if NOT b then
      if MessageDlg(Format('Can''t connect to server %s!'#13#10'Would you like to chose another server?', [FHost]), mtWarning, [mbYes, mbNo], 0, mbYes)=ID_No then
        Exit
  end
  else if MessageDlg('No connection params found!'#13#10'Would you like to chose them now?', mtWarning, [mbYes, mbNo], 0, mbYes)=ID_No then
    Exit;
  if NOT b then
    b:=SetParams;
  if b then
    SaveParams
end;

procedure TDM.ExecuteScript(FN: TFileName);
begin
  Script.ExecuteFile(FN);
  CheckDataBase
end;

procedure DoEncode(M: TMemoryStream);
var
  P, C : Pointer;
  i ,j : integer;
begin
  M.Seek(0,0);
  GetMem(P,M.Size);
  M.Read(P^,M.Size);
  ZCompress(P,M.Size,C,i);
  FreeMem(P);
  for j:=0 to i-1 do begin
    if PByteArray(C)[j]>=128 then
      PByteArray(C)[j]:=PByteArray(C)[j]-128
    else
      PByteArray(C)[j]:=PByteArray(C)[j]+128;
    if Odd(j) then
      PByteArray(C)[j]:=PByteArray(C)[j] XOR 1
    else
      PByteArray(C)[j]:=PByteArray(C)[j] XOR 2
  end;
  M.Clear;
  M.Write(C^,i);
  FreeMem(C);
  M.Seek(0,0)
end;

procedure DoDecode(M: TMemoryStream);
var
  P,C : Pointer;
  i   : integer;
begin
  M.Seek(0,0);
  GetMem(P, M.Size);
  M.Read(P^, M.Size);
  for i:=0 to M.Size-1 do begin
    if Odd(i) then
      PByteArray(P)[i]:=PByteArray(P)[i] XOR 1
    else
      PByteArray(P)[i]:=PByteArray(P)[i] XOR 2;
    if PByteArray(P)[i]>=128 then
      PByteArray(P)[i]:=PByteArray(P)[i]-128
    else
      PByteArray(P)[i]:=PByteArray(P)[i]+128;
  end;
  ZDecompress(P, M.Size, C, i, 0);
  FreeMem(P);
  M.Clear;
  M.Write(C^,i);
  FreeMem(C);
  M.Seek(0,0)
end;

function TDM.LoadParams: boolean;
var
  F  : TIniFile;
  Fn : string;
  s  : ansistring;
  I  : integer;
  M  : TMemoryStream;
begin
  FN:=ChangeFileExt(ParamStr(0),'.ini');
  Result:=FileExists(FN);
  if Result then try
    F:=TIniFile.Create(FN);
    try
      FHost:=F.ReadString('Connection','Host', FHost);
      M:=TMemoryStream.Create;
      try
        I:=F.ReadBinaryStream('Main', 'OptionsA', M);
        if I>0 then begin
          M.Seek(0,0);
          DoDecode(M);
          M.Read(FOsAuthorization, SizeOf(FOsAuthorization));
          M.Read(I, SizeOf(I));
          SetLength(s, I);
          if I>0 then
           M.Read(s[1], i);
          FLogin := String(s);
          M.Read(I, SizeOf(I));
          SetLength(s, I);
          if I>0 then
            M.Read(s[1], i);
          FPassword := String(s)
        end
      finally
        M.Free
      end
    finally
      F.Free
    end
  except
    on E:Exception do begin
      MessageDlg('Load ini: '+E.Message, mtError, [mbOK], 0, mbOK);
      Result:=false
    end;
  end
end;

procedure TDM.SaveParams;
var
  F  : TIniFile;
  Fn : string;
  s  : ansistring;
  I  : integer;
  M  : TMemoryStream;
begin
  FN:=ChangeFileExt(ParamStr(0),'.ini');
  try
    F:=TIniFile.Create(FN);
    try
      F.WriteString('Connection','Host', FHost);
      M:=TMemoryStream.Create;
      try
        M.Write(FOsAuthorization, SizeOf(FOsAuthorization));
        s:=ANSIString(FLogin);
        I:=Length(s);
        M.Write(I, SizeOf(I));
        if I>0 then
          M.Write(s[1], I);
        s:=ANSIString(FPassword);
        I:=Length(s);
        M.Write(I, SizeOf(I));
        if I>0 then
          M.Write(s[1], I);
        DoEncode(M);
        F.WriteBinaryStream('Main', 'OptionsA', M)
      finally
        M.Free
      end
    finally
      F.Free
    end
  except
    on E:Exception do
      MessageDlg('Store ini: '+E.Message, mtError, [mbOK], 0, mbOK)
  end
end;

function TDM.SetParams: boolean;
var
  Vals : TArray<string>;
begin
  SetLength(Vals,3);
  try
    Result:=false;
    while NOT Result do begin
      Vals[0]:=FHost;
      if FOsAuthorization then begin
        Vals[1]:=FLogin;
        Vals[2]:=FPassword
      end
      else begin
        Vals[1]:='';
        Vals[2]:=''
      end;
      if InputQuery('Connection params', ['HostName:', 'User (empty in case of Window authorization):', 'Password:'], Vals) then begin
        FHost:=Trim(Vals[0]);
        FOsAuthorization:=Trim(Vals[1])='';
        if NOT FOsAuthorization then begin
          FLogin:=Trim(Vals[1]);
          FPassword:=Trim(Vals[2])
        end
        else begin
          FLogin:='';
          FPassword:=''
        end
      end
      else
        Break;
      Result:=CheckConnection
    end
  finally
    SetLength(Vals, 0)
  end
end;

end.
