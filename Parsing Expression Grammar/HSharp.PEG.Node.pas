unit HSharp.PEG.Node;

interface

uses
  System.RegularExpressions,
  System.Rtti,
  HSharp.Collections,
  HSharp.Collections.Interfaces,
  HSharp.PEG.Node.Interfaces;

type
  TNode = class(TInterfacedObject, INode)
  strict private
    FValue: TValue;
    FText: string;
    FIndex: Integer;
    FChildren: IList<INode>;
  strict protected
    procedure SetValue(const aValue: TValue);
  public
    constructor Create(const aText: string; aIndex: Integer;
      const aChildren: IList<INode> = nil); reintroduce;
    { INode }
    function GetValue: TValue;
    function GetText: string;
    function GetIndex: Integer;
    function GetChildren: IList<INode>;
    function ToString(aLevel: Integer = 0): string; reintroduce;
  end;

  TRegexNode = class(TNode, IRegexNode)
  strict private
    FMatch: TMatch;
  strict protected
    function GetMatch: TMatch;
  public
    constructor Create(aMatch: TMatch; aIndex: Integer;
       const aChildren: IList<INode> = nil); reintroduce;
  end;

implementation

uses
  System.SysUtils,
  HSharp.Core.ArrayString;

{ TNode }

constructor TNode.Create(const aText: string; aIndex: Integer;
  const aChildren: IList<INode>);
begin
  inherited Create;
  FValue := aText;
  FText := aText;
  FIndex := aIndex;
  FChildren := aChildren;
end;

function TNode.GetChildren: IList<INode>;
begin
  Result := FChildren;
end;

function TNode.GetIndex: Integer;
begin
  Result := FIndex;
end;

function TNode.GetText: string;
begin
  Result := FText;
end;

function TNode.GetValue: TValue;
begin
  Result := FValue;
end;

procedure TNode.SetValue(const aValue: TValue);
begin
  FValue := aValue;
end;

function TNode.ToString(aLevel: Integer): string;
var
  Arr: TArrayString;
  Child: INode;
begin
  Arr := TArrayString.Create;
  Arr.Add('<node>');
  Arr.Add('  <value>' + FValue.AsString + '</value>');
  Arr.Add('  <text>' + FText + '</text>');
  Arr.Add('  <index>' + FIndex.ToString + '</index>');
  if Assigned(FChildren) then
  begin
    Arr.Add('  <children>');
    for Child in FChildren do
      Arr.Add(Child.ToString(aLevel + 1));
    Arr.Add('  </children>');
  end;
  Arr.Add('</node>');
  Arr.Indent(aLevel);
  Result := Arr.AsString;
end;

{ TRegexNode }

constructor TRegexNode.Create(aMatch: TMatch; aIndex: Integer;
  const aChildren: IList<INode>);
begin
  inherited Create(aMatch.Value, aIndex, aChildren);
  FMatch := aMatch;
end;

function TRegexNode.GetMatch: TMatch;
begin
  Result := FMatch;
end;

end.
