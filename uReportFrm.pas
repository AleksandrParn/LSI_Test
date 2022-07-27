unit uReportFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uDM, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.ExtCtrls, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles, dxSkinsCore,
  dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee,
  dxSkinDarkroom, dxSkinDarkSide, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinMcSkin, dxSkinMetropolis, dxSkinMetropolisDark, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinOffice2019Colorful, dxSkinPumpkin, dxSkinSeven,
  dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver,
  dxSkinSpringtime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld,
  dxSkinTheBezier, dxSkinsDefaultPainters, dxSkinValentine,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinXmas2008Blue, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, dxDateRanges, cxDBData, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGridLevel, cxClasses, cxGridCustomView, cxGrid,
  Vcl.StdCtrls, cxTextEdit, cxCalendar, cxTimeEdit, Vcl.ComCtrls;

type
  TReportForm = class(TForm)
    p_LSIReports_Get: TFDStoredProc;
    dsp_LSIReports_Get: TDataSource;
    Panel1: TPanel;
    gView: TcxGridDBTableView;
    GridLevel1: TcxGridLevel;
    Grid: TcxGrid;
    gExportName: TcxGridDBColumn;
    gData: TcxGridDBColumn;
    gTime: TcxGridDBColumn;
    gPerson: TcxGridDBColumn;
    gLokal: TcxGridDBColumn;
    bSearch: TButton;
    cbLocal: TComboBox;
    Label1: TLabel;
    lOD: TLabel;
    dtOD: TDateTimePicker;
    Label2: TLabel;
    dtDo: TDateTimePicker;
    p_LSILokals_Get: TFDStoredProc;
    cbOD: TCheckBox;
    cbDo: TCheckBox;
    procedure bSearchClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure cbDoClick(Sender: TObject);
    procedure cbODClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ReportForm: TReportForm;

implementation

uses UITypes, IniFiles;

{$R *.dfm}

procedure TReportForm.bSearchClick(Sender: TObject);
var
  SP : TFDStoredProc;
  I  : integer;
begin
  Screen.Cursor:=crSQLWait;
  try
    SP:=p_LSIReports_Get;
    if NOT SP.Prepared then
      SP.Prepare
    else if SP.Active then
      SP.Close;
    try
      if cbLocal.ItemIndex>-1 then
        I:=Integer(cbLocal.Items.Objects[cbLocal.ItemIndex])
      else
        I:=-1;
      if I=-1 then
        SP.FindParam('LokalID').Clear
      else
        SP.FindParam('LokalID').AsInteger:=I;
      if cbOD.Checked then
        SP.FindParam('FromDate').Value:=dtOD.DateTime
      else
        SP.FindParam('FromDate').Clear;
      if cbDO.Checked then
        SP.FindParam('ToDate').Value:=dtDo.DateTime
      else
        SP.FindParam('ToDate').Clear;
      SP.Open
    except
      on E:Exception do
        MessageDlg(E.Message, mtError, [mbOK], 0)
    end
  finally
    Screen.Cursor:=crDefault
  end
end;

procedure TReportForm.cbODClick(Sender: TObject);
begin
  dtOD.Enabled:=cbOD.Checked
end;

procedure TReportForm.cbDoClick(Sender: TObject);
begin
  dtDo.Enabled:=cbDo.Checked
end;

procedure TReportForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  F  : TIniFile;
  FN : TFileName;
  X  : integer;
begin
  if p_LSIReports_Get.Active then
    p_LSIReports_Get.Close;
  FN:=ChangeFileExt(ParamStr(0),'.ini');
  F:=TIniFile.Create(FN);
  try
    F.WriteString('Report', 'FromD', DateToStr(dtOD.Date));
    F.WriteString('Report', 'ToD', DateToStr(dtDO.Date));
    F.WriteBool('Report', 'From', cbOD.Checked);
    F.WriteBool('Report', 'To', cbDO.Checked);
    if cbLocal.ItemIndex>-1 then
      X:=Integer(cbLocal.Items.Objects[cbLocal.ItemIndex])
    else
      X:=-1;
    F.WriteInteger('Report', 'Lokal', X)
  finally
    F.Free
  end;
  Action:=caFree
end;

procedure TReportForm.FormCreate(Sender: TObject);
var
  SP   : TFDStoredProc;
  F    : TIniFile;
  FN   : TFileName;
  I, X : integer;
  s    : string;
  D    : TDateTime;
begin
  dtOD.DateTime:=Now;
  dtDO.DateTime:=Now;
  SP:=p_LSILokals_Get;
  Screen.Cursor:=crSQLWait;
  try
    cbLocal.Items.AddObject('(Wszystkie)', Pointer(-1));
    if NOT SP.Prepared then
      SP.Prepare;
    SP.Open();
    try
      SP.First;
      while NOT SP.Eof do begin
        cbLocal.Items.AddObject(SP.FindField('LokalName').AsString, Pointer(SP.FindField('LokalID').AsInteger));
        SP.Next
      end
    finally
      SP.Close
    end;
    cbLocal.ItemIndex:=0;
    FN:=ChangeFileExt(ParamStr(0),'.ini');
    if FileExists(FN) then begin
      F:=TIniFile.Create(FN);
      try
        s:=F.ReadString('Report', 'FromD', DateToStr(dtOD.Date));
        if TryStrToDate(s, D) then
          dtOD.Date:=D;
        s:=F.ReadString('Report', 'ToD', DateToStr(dtDO.Date));
        if TryStrToDate(s, D) then
          dtDO.Date:=D;
        cbOD.Checked:=F.ReadBool('Report', 'From', cbOD.Checked);
        cbDO.Checked:=F.ReadBool('Report', 'To', cbDO.Checked);
        X:=F.ReadInteger('Report', 'Lokal', 0);
        for I := 0 to cbLocal.Items.Count-1 do begin
          if Integer(cbLocal.Items.Objects[I])=X then begin
            cbLocal.ItemIndex:=I;
            Break
          end
        end
      finally
        F.Free
      end;
    end
  finally
    Screen.Cursor:=crDefault
  end;
end;

end.
