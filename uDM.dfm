object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 208
  Width = 284
  object Connect: TFDConnection
    Params.Strings = (
      'DriverID=MSSQL'
      'LoginTimeout=100'
      'Server=DESKTOP-DLI1FP2\P4D'
      'User_Name=ss1'
      'Password=ss1'
      'OSAuthent=Yes')
    ResourceOptions.AssignedValues = [rvUnifyParams]
    ResourceOptions.UnifyParams = True
    ConnectedStoredUsage = []
    Connected = True
    LoginPrompt = False
    Left = 92
    Top = 48
  end
  object Script: TFDScript
    SQLScripts = <>
    Connection = Connect
    ScriptOptions.BreakOnError = True
    ScriptOptions.CommandSeparator = 'go'
    Params = <>
    Macros = <>
    Left = 92
    Top = 136
  end
end
