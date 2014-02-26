unit HSharp.PEG.GrammarVisitor;

interface

uses
  System.Rtti,
  HSharp.Collections,
  HSharp.Collections.Interfaces,
  HSharp.PEG.GrammarVisitor.Attributes;

type
  TGrammarVisitor = class
  strict private
    FRules: IDictionary<string, TRttiMethod>;
  public
    constructor Create; reintroduce;
  end;

implementation

{ TGrammarVisitor }

constructor TGrammarVisitor.Create;
var
  Method: TRttiMethod;
  Attribute: TCustomAttribute;
begin
  FRules := Collections.CreateDictionary<string, TRttiMethod>;
  for Method in TRttiContext.Create.GetType(ClassType).GetMethods do
  begin
    for Attribute in Method.GetAttributes do
    begin
      if Attribute is RuleAttribute then
        FRules.Add(RuleAttribute(Attribute).Rule, Method);
    end;
  end;
end;

end.
