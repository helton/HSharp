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
    tcGrammar: TTabControl;
    tiGrammar: TTabItem;
    tiGrammar_AST: TTabItem;
    mmGrammar: TMemo;
    btnGenerateGrammarAST: TButton;
    mmAST: TMemo;
    tcAST: TTabControl;
    tiAST_Grammar: TTabItem;
    tiAST_Input: TTabItem;
    tcInput: TTabControl;
    tiInput: TTabItem;
    tiInput_AST: TTabItem;
    mmInput: TMemo;
    mmInput_AST: TMemo;
    btnGenerateInputAST: TButton;
    StyleBook1: TStyleBook;
    procedure btnGenerateGrammarASTClick(Sender: TObject);
    procedure btnGenerateInputASTClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mmGrammarKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure mmInputKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
  private
    { Private declarations }
    procedure GenerateGrammarAST;
    procedure GenerateInputAST;
  public
    { Public declarations }
  end;

var
  FormGrammarAST: TFormGrammarAST;

implementation

uses
  HSharp.Core.Lazy;

var
  BootstrappingGrammar: Lazy<IBootstrappingGrammar, TBootstrappingGrammar>;
  Visitor: Lazy<INodeVisitor, TPrinterNodeVisitor>;

{$R *.fmx}

procedure TFormGrammarAST.btnGenerateGrammarASTClick(Sender: TObject);
begin
  GenerateGrammarAST;
end;

procedure TFormGrammarAST.btnGenerateInputASTClick(Sender: TObject);
begin
  GenerateInputAST;
end;

procedure TFormGrammarAST.FormCreate(Sender: TObject);
begin
  tcAST.ActiveTab     := tiAST_Grammar;
  tcGrammar.ActiveTab := tiGrammar;
end;

procedure TFormGrammarAST.GenerateGrammarAST;
var
  GrammarTree: INode;
begin
  mmAST.Lines.Clear;
  mmAST.BeginUpdate;
  GrammarTree := BootstrappingGrammar.Instance.Parse(mmGrammar.Text);
  mmAST.Lines.Text := (GrammarTree as IVisitableNode).Accept(Visitor).AsString;
  mmAST.EndUpdate;
  tcAST.ActiveTab     := tiAST_Grammar;
  tcGrammar.ActiveTab := tiGrammar_AST;
end;

procedure TFormGrammarAST.GenerateInputAST;
var
  Grammar: IGrammar;
  GrammarTree: INode;
begin
  Grammar := TGrammar.Create(BootstrappingGrammar.Instance.GetRules(mmGrammar.Text));
  mmInput_AST.Lines.Clear;
  mmInput_AST.BeginUpdate;
  GrammarTree := Grammar.Parse(mmInput.Text);
  mmInput_AST.Lines.Text := (GrammarTree as IVisitableNode).Accept(Visitor).AsString;
  mmInput_AST.EndUpdate;
  tcAST.ActiveTab   := tiAST_Input;
  tcInput.ActiveTab := tiInput_AST;
end;

procedure TFormGrammarAST.mmGrammarKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (Key = vkReturn) then
    GenerateGrammarAST;
end;

procedure TFormGrammarAST.mmInputKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (Key = vkReturn) then
    GenerateInputAST;
end;

end.
