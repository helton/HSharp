unit AST.Form;

interface

uses
  System.Rtti,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Graphics,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.TreeView,
  FMX.Layouts,
  FMX.Memo,
  FMX.TabControl,
  HSharp.PEG.Node,
  HSharp.PEG.Node.Interfaces,
  HSharp.PEG.Node.Visitors,
  HSharp.PEG.Grammar,
  HSharp.PEG.Grammar.Interfaces,
  HSharp.PEG.Grammar.Bootstrapping;

type
  TFormGrammarAST = class(TForm)
    TabControl1: TTabControl;
    tiGrammar: TTabItem;
    tiGrammarAST: TTabItem;
    mmGrammar: TMemo;
    btnGenerateAST: TButton;
    mmAST: TMemo;
    procedure btnGenerateASTClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormGrammarAST: TFormGrammarAST;

implementation


{$R *.fmx}

procedure TFormGrammarAST.btnGenerateASTClick(Sender: TObject);
var
  Boot: IBootstrappingGrammar;
  Tree: INode;
  Visitor: INodeVisitor;
begin
  mmAST.Lines.Clear;
  mmAST.BeginUpdate;

  Boot := TBootstrappingGrammar.Create;
  Tree := Boot.Parse(mmGrammar.Text);
  Visitor := TPrinterNodeVisitor.Create;
  mmAST.Lines.Text := (Tree as IVisitableNode).Accept(Visitor).AsString;

  mmAST.EndUpdate;
end;

end.
