object ReportForm: TReportForm
  Left = 0
  Top = 0
  Caption = 'Report'
  ClientHeight = 519
  ClientWidth = 842
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Visible = True
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 20
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 221
    Height = 519
    Align = alLeft
    TabOrder = 0
    ExplicitTop = 8
    DesignSize = (
      221
      519)
    object Label1: TLabel
      Left = 8
      Top = 27
      Width = 38
      Height = 20
      Caption = 'Lokal:'
    end
    object lOD: TLabel
      Left = 8
      Top = 68
      Width = 23
      Height = 20
      Caption = 'Od:'
    end
    object Label2: TLabel
      Left = 8
      Top = 106
      Width = 23
      Height = 20
      Caption = 'Do:'
    end
    object cbDo: TCheckBox
      Left = 44
      Top = 108
      Width = 17
      Height = 17
      TabOrder = 5
      OnClick = cbDoClick
    end
    object cbOD: TCheckBox
      Left = 44
      Top = 70
      Width = 17
      Height = 17
      TabOrder = 4
      OnClick = cbODClick
    end
    object bSearch: TButton
      Left = 28
      Top = 480
      Width = 161
      Height = 25
      Anchors = [akLeft, akRight]
      Caption = 'Zatwierd'#380
      Default = True
      TabOrder = 0
      OnClick = bSearchClick
      ExplicitWidth = 113
    end
    object cbLocal: TComboBox
      Left = 60
      Top = 24
      Width = 145
      Height = 28
      Style = csDropDownList
      TabOrder = 1
    end
    object dtOD: TDateTimePicker
      Left = 59
      Top = 66
      Width = 146
      Height = 28
      Date = 44769.000000000000000000
      Time = 0.748443020835111400
      Enabled = False
      TabOrder = 2
    end
    object dtDo: TDateTimePicker
      Left = 60
      Top = 100
      Width = 146
      Height = 28
      Date = 44769.000000000000000000
      Time = 0.748443020835111400
      Enabled = False
      TabOrder = 3
    end
  end
  object Grid: TcxGrid
    Left = 221
    Top = 0
    Width = 621
    Height = 519
    Align = alClient
    TabOrder = 1
    ExplicitLeft = 173
    ExplicitTop = 8
    ExplicitWidth = 595
    object gView: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      Navigator.InfoPanel.DisplayMask = '[RecordIndex] : [RecordCount]'
      Navigator.InfoPanel.Visible = True
      DataController.DataSource = dsp_LSIReports_Get
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsData.Deleting = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsView.CellEndEllipsis = True
      OptionsView.NoDataToDisplayInfoText = '<Brak danych do wy'#347'wietlenia>'
      OptionsView.ColumnAutoWidth = True
      OptionsView.GroupByBox = False
      OptionsView.HeaderEndEllipsis = True
      object gExportName: TcxGridDBColumn
        Caption = 'Nazwa'
        DataBinding.FieldName = 'ExportName'
        PropertiesClassName = 'TcxTextEditProperties'
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Width = 126
      end
      object gData: TcxGridDBColumn
        Caption = 'Data'
        DataBinding.FieldName = 'ExportDate'
        PropertiesClassName = 'TcxDateEditProperties'
        Properties.DisplayFormat = 'yyyy-mm-dd'
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Width = 97
      end
      object gTime: TcxGridDBColumn
        Caption = 'Godzina'
        DataBinding.FieldName = 'ExportDate'
        PropertiesClassName = 'TcxTimeEditProperties'
        Properties.TimeFormat = tfHourMin
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Width = 116
      end
      object gPerson: TcxGridDBColumn
        Caption = 'U'#380'ytkownik'
        DataBinding.FieldName = 'PersonName'
        PropertiesClassName = 'TcxTextEditProperties'
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Width = 145
      end
      object gLokal: TcxGridDBColumn
        Caption = 'Lokal'
        DataBinding.FieldName = 'LokalName'
        PropertiesClassName = 'TcxTextEditProperties'
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Width = 85
      end
    end
    object GridLevel1: TcxGridLevel
      GridView = gView
    end
  end
  object p_LSIReports_Get: TFDStoredProc
    Connection = DM.Connect
    StoredProcName = 'p_LSIReports_Get'
    Left = 236
    Top = 108
  end
  object dsp_LSIReports_Get: TDataSource
    DataSet = p_LSIReports_Get
    Left = 144
    Top = 68
  end
  object p_LSILokals_Get: TFDStoredProc
    Connection = DM.Connect
    StoredProcName = 'p_LSILokals_Get'
    Left = 288
    Top = 256
  end
end
