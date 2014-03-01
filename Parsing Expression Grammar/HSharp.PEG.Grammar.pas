unit HSharp.PEG.Grammar;

interface

uses
  HSharp.Collections,
  HSharp.Collections.Interfaces,
  HSharp.PEG.Context,
  HSharp.PEG.Context.Interfaces,
  HSharp.PEG.Grammar.Interfaces,
  HSharp.PEG.Node.Interfaces,
  HSharp.PEG.Rule.Interfaces;

type
  TGrammar = class(TInterfacedObject, IGrammar)
  strict private
    FDefaultRule: IRule; //should be a weak reference?
    FRules: IList<IRule>;
  public
    constructor Create(const aRules: array of IRule; const aDefaultRule: IRule = nil); reintroduce;
    function Parse(const aText: string): INode;
    function AsString: string;
  end;

implementation

uses
  HSharp.Core.Arrays,
  HSharp.Core.ArrayString;

{ TGrammar }

function TGrammar.AsString: string;
var
  Rule: IRule;
  Grammar: IArrayString;
begin
  Grammar := TArrayString.Create;
  Grammar.Add(FDefaultRule.AsString);
  for Rule in FRules do
  begin
    if Rule <> FDefaultRule then
      Grammar.Add(Rule.AsString);
  end;
  Result := Grammar.AsString;
end;

constructor TGrammar.Create(const aRules: array of IRule;
  const aDefaultRule: IRule);
begin
  inherited Create;
  FRules := Collections.CreateList<IRule>;
  FRules.AddRange(aRules);
  if Assigned(aDefaultRule) then
    FDefaultRule := aDefaultRule
  else
    FDefaultRule := FRules.First;
end;

function TGrammar.Parse(const aText: string): INode;
begin
  Result := FDefaultRule.Parse(TContext.Create(aText));
end;

end.