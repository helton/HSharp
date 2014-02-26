unit Test.ExpressionGrammar;

interface

uses
  System.Rtti,
  HSharp.PEG.Context,
  HSharp.PEG.Context.Interfaces,
  HSharp.PEG.Exceptions,
  HSharp.PEG.Expression,
  HSharp.PEG.Expression.Interfaces,
  HSharp.PEG.Grammar,
  HSharp.PEG.Grammar.Interfaces,
  HSharp.PEG.GrammarVisitor,
  HSharp.PEG.GrammarVisitor.Attributes,
  HSharp.PEG.Node,
  HSharp.PEG.Node.Interfaces,
  HSharp.PEG.Rule,
  HSharp.PEG.Rule.Interfaces;

type
  TExpressionGrammarVisitor = class(TGrammarVisitor)
  public
    [Rule('integer = /[0-9]+/')]
    function VisitInteger(const aNode: INode): TValue;
  end;

implementation

uses
  Vcl.Dialogs;

{ TExpressionGrammarVisitor }

function TExpressionGrammarVisitor.VisitInteger(const aNode: INode): TValue;
begin
  Result := aNode.Children[0].Value;
  ShowMessage('integer = ' + Result.AsString); {TODO -oHelton -cRemove : Remove}
end;

end.
