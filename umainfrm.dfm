object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Test application LSI'
  ClientHeight = 618
  ClientWidth = 1066
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsMDIForm
  Menu = MM
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 20
  object MM: TMainMenu
    Left = 156
    Top = 80
    object P1: TMenuItem
      Caption = 'Program'
      object Options1: TMenuItem
        Action = aOptions
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object C1: TMenuItem
        Caption = 'Close'
        ShortCut = 32883
        OnClick = C1Click
      end
    end
    object rReports: TMenuItem
      Caption = 'Reports'
      object Report1: TMenuItem
        Action = aReport
      end
    end
  end
  object AL: TActionList
    Left = 204
    Top = 92
    object aOptions: TAction
      Caption = 'Options...'
      ShortCut = 16463
      OnExecute = aOptionsExecute
    end
    object aReport: TAction
      Caption = 'Report'
      OnExecute = aReportExecute
      OnUpdate = aReportUpdate
    end
  end
end
