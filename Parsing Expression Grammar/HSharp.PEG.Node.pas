unit HSharp.PEG.Node;

interface

uses
  System.RegularExpressions,
  System.Rtti,
  HSharp.Collections,
  HSharp.Collections.Interfaces,
  HSharp.PEG.Node.Interfaces;

type
  TNode = class(TInterfacedObject, INode, IVisitableNode)
  strict private
    FName: string;
    FText: string;
    FIndex: Integer;
    FChildren: IList<INode>;
  strict protected
    { INode }
    function GetChildren: IList<INode>;
    function GetIndex: Integer;
    function GetName: string;
    function GetText: string;
    { IVisitableNode }
    function Accept(const aVisitor: INodeVisitor): TValue;
  public
    constructor Create(const aName, aText: string; aIndex: Integer;
      const aChildren: IList<INode> = nil); reintroduce;
    function ToString(aLevel: Integer = 0): string; reintroduce;
  end;

  TRegexNode = class(TNode, IRegexNode)
  strict private
    FMatch: TMatch;
  strict protected
    function GetMatch: TMatch;
  public
    constructor Create(const aName: string; aMatch: TMatch; aIndex: Integer;
       const aChildren: IList<INode> = nil); reintroduce;
  end;

implementation

uses
  System.SysUtils,
  HSharp.Core.ArrayString;

{ TNode }

function TNode.Accept(const aVisitor: INodeVisitor): TValue;
begin
  Result := aVisitor.Visit(Self);
end;

constructor TNode.Create(const aName, aText: string; aIndex: Integer;
  const aChildren: IList<INode>);
begin
  inherited Create;
  FName := aName;
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

function TNode.GetName: string;
begin
  Result := FName;
end;

function TNode.GetText: string;
begin
  Result := FText;
end;

function TNode.ToString(aLevel: Integer): string;
var
  Arr: IArrayString;
  Child: INode;
begin
  Arr := TArrayString.Create;
  if FName.IsEmpty then
    Arr.Add('<node>')
  else
    Arr.Add('<node "' + FName + '">');
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

constructor TRegexNode.Create(const aName: string; aMatch: TMatch;
  aIndex: Integer; const aChildren: IList<INode>);
begin
  inherited Create(aName, aMatch.Value, aIndex, aChildren);
  FMatch := aMatch;
end;

function TRegexNode.GetMatch: TMatch;
begin
  Result := FMatch;
end;

end.
