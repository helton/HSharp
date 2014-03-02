unit HSharp.PEG.Node.Interfaces;

interface

uses
  System.RegularExpressions,
  System.Rtti,
  HSharp.Collections.Interfaces;

type
  INode = interface;

  INodeVisitor = interface
    ['{EF39DA2D-7849-4C72-92C9-915AEF6848C4}']
    function Visit(const aNode: INode): TValue;
  end;

  IVisitableNode = interface
    ['{1D7B2F86-CD22-4299-8F24-982B32150B99}']
    function Accept(const aVisitor: INodeVisitor): TValue;
  end;

  INode = interface
    ['{7F8983C7-D49A-4B8F-9696-B1EA19909452}']
    { property accessors }
    function GetChildren: IList<INode>;
    function GetIndex: Integer;
    function GetName: string;
    function GetText: string;
    function ToString(aLevel: Integer = 0): string;
    { properties }
    property Name: string read GetName;
    property Text: string read GetText;
    property Index: Integer read GetIndex;
    property Children: IList<INode> read GetChildren;
  end;

  IRegexNode = interface(INode)
    ['{136B89D9-EBDB-4E6C-A116-7A88D1E59DB0}']
    { property accessors }
    function GetMatch: TMatch;
    { properties }
    property Match: TMatch read GetMatch;
  end;

implementation

end.
