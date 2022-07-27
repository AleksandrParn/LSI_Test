program test_lsi;

uses
  Vcl.Forms,
  umainfrm in 'umainfrm.pas' {MainForm},
  uDM in 'uDM.pas' {DM: TDataModule},
  uReportFrm in 'uReportFrm.pas' {ReportForm};

{$R *.res}

begin
  {$WARNINGS OFF}
  ReportMemoryLeaksOnShutDown:= (DebugHook<>0);
  {$WARNINGS ON}
  Application.Initialize;
  Application.Title:='LSI test application by Aleksandr Pern';
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
