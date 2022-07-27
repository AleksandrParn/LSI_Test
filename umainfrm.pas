unit umainfrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList, Vcl.Menus, uDM;

type
  TMainForm = class(TForm)
    MM: TMainMenu;
    P1: TMenuItem;
    AL: TActionList;
    aOptions: TAction;
    Options1: TMenuItem;
    N1: TMenuItem;
    C1: TMenuItem;
    aReport: TAction;
    rReports: TMenuItem;
    Report1: TMenuItem;
    procedure aOptionsExecute(Sender: TObject);
    procedure aReportUpdate(Sender: TObject);
    procedure C1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure aReportExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses IOUtils, UITypes, uReportFrm;

{$R *.dfm}

procedure TMainForm.aOptionsExecute(Sender: TObject);
begin
  if DM.SetParams then
    DM.SaveParams
end;

procedure TMainForm.aReportExecute(Sender: TObject);
var
  I : integer;
begin
  for I := 0 to MDIChildCount-1 do begin
    if MDIChildren[I] IS TReportForm then begin
      MDIChildren[I].BringToFront;
      Exit
    end
  end;
  Application.CreateForm(TReportForm, ReportForm)
end;

procedure TMainForm.aReportUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled:=DM.ServerExists
end;

procedure TMainForm.C1Click(Sender: TObject);
begin
  Close
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  FN : TFileName;
begin
  if DM.ServerExists then begin
    if NOT DM.CheckDataBase then begin
      FN:=IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'_test creation script.sql';
      if TFile.Exists(FN) then begin
        if MessageDlg(Format('There is no TestLSI Database on the server %s!'
                             +#13#10'Execute script to create Database?', [DM.Host]), mtConfirmation, [mbYes, mbNo], 0, mbYes)=ID_Yes then
          DM.ExecuteScript(FN)
      end
      else
        MessageDlg(Format('There is no TestLSI Database on the server %s'
                         +#13#10'and no script file found (%s)!', [FN]), mtError, [mbOK], 0, mbOK)
    end;
  end;
  WindowMenu:=rReports
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  if DM.ServerExists then
    aReportExecute(aReport)
end;

end.
