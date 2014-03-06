program AST;

uses
  FMX.Forms,
  AST.Form in 'AST.Form.pas' {FormGrammarAST};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormGrammarAST, FormGrammarAST);
  Application.Run;
end.
