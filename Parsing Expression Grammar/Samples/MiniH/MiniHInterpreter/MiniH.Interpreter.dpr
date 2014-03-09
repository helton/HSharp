program MiniH.Interpreter;

uses
  FMX.Forms,
  MiniHInterpreter.Form.Main in 'MiniHInterpreter.Form.Main.pas' {FormInterpreter},
  Language.MiniH in '..\Language.MiniH.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TFormInterpreter, FormInterpreter);
  Application.Run;
end.
