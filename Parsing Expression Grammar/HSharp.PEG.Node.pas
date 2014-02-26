unit HSharp.PEG.Node;

interface

uses
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
    procedure SetValue(aValue: TValue);
  public
    constructor Create(const aText: string; aIndex: Integer; const aChildren: IList<INode> = nil); reintroduce;
    { INode }
    function GetValue: TValue;
    function GetText: string;
    function GetIndex: Integer;
    function GetChildren: IList<INode>;
  end;

implementation

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

procedure TNode.SetValue(aValue: TValue);
begin
  FValue := aValue;
end;

end.
